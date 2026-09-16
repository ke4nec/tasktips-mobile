import 'package:flutter/material.dart';

import '../../app/app_model.dart';
import '../../domain/classification.dart';
import '../../domain/query.dart';
import '../app.dart';
import '../theme.dart';
import '../widgets.dart';

/// 分类页：目录/标签分段切换，管理目录树与标签；点分类进入筛选列表。
class FolderPage extends StatefulWidget {
  final AppModel model;
  const FolderPage({super.key, required this.model});

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  int _seg = 0; // 0 目录 1 标签

  @override
  Widget build(BuildContext context) {
    final m = widget.model;
    return Scaffold(
      appBar: AppBar(
        title: const Text('目录与标签'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('目录')),
                      ButtonSegment(value: 1, label: Text('标签')),
                    ],
                    selected: {_seg},
                    onSelectionChanged: (s) => setState(() => _seg = s.first),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: _seg == 0 ? '新建目录' : '新建标签',
                  onPressed: () =>
                      _seg == 0 ? _editCategory(context, null) : _editTag(context, null),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: m,
        builder: (context, _) => _seg == 0 ? _categoryTree(context) : _tagList(context),
      ),
    );
  }

  // ---------- 目录 ----------

  Widget _categoryTree(BuildContext context) {
    final m = widget.model;
    final roots = m.rootCategories;
    if (roots.isEmpty) {
      return EmptyState(
        icon: Icons.folder_outlined,
        title: '还没有目录',
        subtitle: '点右上角 + 新建目录，最多三级',
      );
    }
    return ListView(
      children: [
        _categoryRow(context, null),
        for (final c in roots) ..._categorySubtree(context, c, 0),
      ],
    );
  }

  List<Widget> _categorySubtree(BuildContext context, Category c, int depth) {
    final m = widget.model;
    return [
      _categoryRow(context, c, depth: depth),
      for (final child in m.childCategories(c.id))
        ..._categorySubtree(context, child, depth + 1),
    ];
  }

  Widget _categoryRow(BuildContext context, Category? c, {int depth = 0}) {
    final m = widget.model;
    final a = appColors(context, Theme.of(context).brightness);
    final count = c == null
        ? m.todos.where((t) => !t.isDeleted && (t.categoryId == null || t.categoryId!.isEmpty)).length
        : m.todoCountInCategory(c.id);
    return InkWell(
      onTap: () => openSecondaryPage(
        context,
        CategoryTodoList(model: m, category: c),
      ),
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: EdgeInsets.only(left: 16.0 + depth * 20, right: 8),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: a.line))),
        child: Row(
          children: [
            Icon(c == null
                ? Icons.inbox_outlined
                : Icons.folder_outlined,
                size: 22, color: a.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                c?.name ?? '未分类',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            Text('$count', style: TextStyle(color: a.muted, fontSize: 13)),
            if (c != null)
              PopupMenuButton<String>(
                onSelected: (v) async {
                  switch (v) {
                    case 'rename':
                      _editCategory(context, c);
                    case 'move':
                      _moveCategory(context, c);
                    case 'color':
                      _pickColor(context, isCategory: true, id: c.id);
                    case 'delete':
                      _deleteCategory(context, c);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'rename', child: Text('重命名')),
                  PopupMenuItem(value: 'move', child: Text('调整父目录')),
                  PopupMenuItem(value: 'color', child: Text('颜色')),
                  PopupMenuItem(value: 'delete', child: Text('删除')),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _editCategory(BuildContext context, Category? existing,
      {String? parentId}) async {
    final m = widget.model;
    final ctrl =
        TextEditingController(text: existing?.name ?? '');
    final err = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(existing == null ? '新建目录' : '重命名目录',
                style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: const InputDecoration(hintText: '目录名称'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
    if (err == null) return;
    final name = ctrl.text.trim();
    String? result;
    if (existing == null) {
      result = await m.createCategory(name, parentId: parentId);
    } else {
      result = await m.renameCategory(existing.id, name);
    }
    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result)));
    }
    ctrl.dispose();
  }

  Future<void> _moveCategory(BuildContext context, Category c) async {
    final m = widget.model;
    final target = await showModalBottomSheet<String?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('（顶级）'),
              onTap: () => Navigator.pop(ctx, ''),
            ),
            for (final e in m.classification.categories.where((e) =>
                !e.isDeleted && e.id != c.id &&
                !m.expandCategoryIds(c.id).contains(e.id)))
              ListTile(
                title: Text(m.classification.categoryPath(e.id)),
                onTap: () => Navigator.pop(ctx, e.id),
              ),
          ],
        ),
      ),
    );
    if (target == null) return;
    final err = await m.moveCategory(c.id, target.isEmpty ? null : target);
    if (err != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  Future<void> _deleteCategory(BuildContext context, Category c) async {
    final m = widget.model;
    final subtree = m.expandCategoryIds(c.id);
    final todoCount = m.todos
        .where((t) => !t.isDeleted && t.categoryId != null && subtree.contains(t.categoryId))
        .length;
    final ok = await confirmDialog(
      context,
      title: '删除目录',
      message: '将删除“${c.name}”及其 $todoCount 条任务中的 ${subtree.length - 1} 个子目录。'
          '任务保留并显示为未分类。可在回收站恢复。',
      confirmText: '删除',
      destructive: true,
    );
    if (ok) await m.trashCategory(c.id);
  }

  // ---------- 标签 ----------

  Widget _tagList(BuildContext context) {
    final m = widget.model;
    final a = appColors(context, Theme.of(context).brightness);
    final groups = m.tagsByGroup;
    if (groups.isEmpty) {
      return EmptyState(
        icon: Icons.tag,
        title: '还没有标签',
        subtitle: '点右上角 + 新建标签',
      );
    }
    return ListView(
      children: [
        for (final e in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(e.key,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: a.muted)),
          ),
          for (final tag in e.value)
            InkWell(
              onTap: () => openSecondaryPage(
                context,
                TagTodoList(model: m, tag: tag),
              ),
              child: Container(
                constraints: const BoxConstraints(minHeight: 72),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: a.line))),
                child: Row(
                  children: [
                    Icon(Icons.tag, size: 22, color: a.purple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(tag.name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                    Text('${m.todos.where((t) => !t.isDeleted && t.tags.contains(tag.name)).length}',
                        style: TextStyle(color: a.muted, fontSize: 13)),
                    PopupMenuButton<String>(
                      onSelected: (v) async {
                        switch (v) {
                          case 'rename':
                            _editTag(context, tag);
                          case 'color':
                            _pickColor(context, isCategory: false, id: tag.id);
                          case 'delete':
                            _deleteTag(context, tag);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'rename', child: Text('重命名')),
                        PopupMenuItem(value: 'color', child: Text('颜色')),
                        PopupMenuItem(value: 'delete', child: Text('删除')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }

  Future<void> _editTag(BuildContext context, Tag? existing) async {
    final m = widget.model;
    final ctrl = TextEditingController(text: existing?.name ?? '');
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(existing == null ? '新建标签' : '重命名标签',
                style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: const InputDecoration(hintText: '标签名称'),
            ),
            if (existing != null) ...[
              const SizedBox(height: 8),
              Text('重命名会同步更新所有关联 Todo。',
                  style: TextStyle(fontSize: 12, color: Theme.of(ctx).hintColor)),
            ],
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    String? result;
    if (existing == null) {
      result = await m.createTag(ctrl.text.trim());
    } else {
      result = await m.renameTag(existing.id, ctrl.text.trim());
    }
    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    }
    ctrl.dispose();
  }

  Future<void> _deleteTag(BuildContext context, Tag tag) async {
    final m = widget.model;
    final ok = await confirmDialog(
      context,
      title: '删除标签',
      message: '将删除标签“${tag.name}”。关联关系保留，彻底删除后才从 Todo 中移除。',
      confirmText: '删除',
      destructive: true,
    );
    if (ok) await m.trashTag(tag.id);
  }

  Future<void> _pickColor(BuildContext context,
      {required bool isCategory, required String id}) async {
    const palette = [
      'blue', 'green', 'orange', 'purple', 'red', 'gray',
    ];
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            for (final c in palette)
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: Text(c),
                onTap: () => Navigator.pop(ctx, c),
              ),
            ListTile(
              leading: const Icon(Icons.format_color_reset),
              title: const Text('默认'),
              onTap: () => Navigator.pop(ctx, ''),
            ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    final v = choice.isEmpty ? null : choice;
    if (isCategory) {
      await widget.model.setCategoryColor(id, v);
    } else {
      await widget.model.setTagColor(id, v);
    }
  }
}

/// 目录筛选 Todo 列表（含子目录）；FAB 新建继承目录。
class CategoryTodoList extends StatelessWidget {
  final AppModel model;
  final Category? category;
  const CategoryTodoList({super.key, required this.model, required this.category});

  @override
  Widget build(BuildContext context) {
    final ids = category == null
        ? null
        : model.expandCategoryIds(category!.id);
    return SecondaryScaffold(
      title: category?.name ?? '未分类',
      body: AnimatedBuilder(
        animation: model,
        builder: (context, _) {
          final list = model.query(TodoQuery(
            view: TodoView.all,
            categoryIds: ids?.toList(),
            uncategorized: category == null,
          )).where((t) => !t.isDeleted).toList();
          return list.isEmpty
              ? const EmptyState(icon: Icons.folder_off, title: '此分类下暂无任务')
              : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) => TodoTile(
                    model: model,
                    todo: list[i],
                    onOpen: () => openDetailPage(context, model, list[i].id),
                  ),
                );
        },
      ),
      // SecondaryScaffold 无 FAB 参数，用 FloatingActionButton 包一层
      actions: null,
    );
  }
}

/// 标签筛选 Todo 列表；FAB 新建继承标签。
class TagTodoList extends StatelessWidget {
  final AppModel model;
  final Tag tag;
  const TagTodoList({super.key, required this.model, required this.tag});

  @override
  Widget build(BuildContext context) {
    return SecondaryScaffold(
      title: '#${tag.name}',
      body: AnimatedBuilder(
        animation: model,
        builder: (context, _) {
          final list = model.query(TodoQuery(
            view: TodoView.all,
            tagNames: [tag.name],
          ));
          return list.isEmpty
              ? const EmptyState(icon: Icons.tag, title: '此标签下暂无任务')
              : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) => TodoTile(
                    model: model,
                    todo: list[i],
                    onOpen: () => openDetailPage(context, model, list[i].id),
                  ),
                );
        },
      ),
    );
  }
}
