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

  /// 所属 Tab 是否激活：离场时不再随 model 高频通知全量重建。
  final bool active;
  const FolderPage({super.key, required this.model, this.active = true});

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
      body: ActiveModelBuilder(
        model: m,
        active: widget.active,
        builder: (context) => _seg == 0 ? _categoryTree(context) : _tagList(context),
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
    // 展平为行数据，ListView.builder 惰性构建（目录数百条时避免全量首帧构建）
    final rows = <(Category?, int)>[(null, 0)];
    void addSubtree(Category c, int depth) {
      rows.add((c, depth));
      for (final child in m.childCategories(c.id)) {
        addSubtree(child, depth + 1);
      }
    }

    for (final c in roots) {
      addSubtree(c, 0);
    }
    return ListView.builder(
      itemCount: rows.length + 1, // 尾部说明行
      itemBuilder: (context, i) {
        if (i == rows.length) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Text('点按进入分类列表，在右上角管理名称。',
                style: TextStyle(
                    fontSize: 12,
                    color: appColors(context, Theme.of(context).brightness).muted)),
          );
        }
        final (c, depth) = rows[i];
        return _categoryRow(context, c, depth: depth);
      },
    );
  }

  Widget _categoryRow(BuildContext context, Category? c, {int depth = 0}) {
    final m = widget.model;
    final a = appColors(context, Theme.of(context).brightness);
    // 未分类行（含指向已删目录的 Todo）显示总数（缓存）；目录行显示“N 项未完成”
    final count = c == null ? m.uncategorizedTodoCount : m.openTodoCountInCategory(c.id);
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
            // 目录行带色板彩色圆角块（设计稿 .folder-leading）
            if (c != null)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _parseColor(c.color).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.folder_outlined,
                    size: 20, color: _parseColor(c.color)),
              )
            else
              Icon(Icons.inbox_outlined, size: 22, color: a.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                c?.name ?? '未分类',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              c == null ? '$count 项 Todo' : '$count 项未完成',
              style: TextStyle(color: a.muted, fontSize: 13),
            ),
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
      message: '将删除“${c.name}”及其 ${subtree.length - 1} 个子目录、'
          '$todoCount 条任务（任务随同进入回收站）。可在回收站恢复。',
      confirmText: '删除',
      destructive: true,
    );
    if (ok) await m.trashCategory(c.id);
  }

  // ---------- 标签 ----------

  /// 标签列表行模型：组标题 / 空分组占位 / 标签行。
  /// 展平后交给 ListView.builder 惰性构建。
  static const _tagHeader = '__header__';
  static const _tagEmptyGroup = '__empty__';

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
    final rows = <({String kind, String group, Tag? tag})>[];
    for (final e in groups.entries) {
      rows.add((kind: _tagHeader, group: e.key, tag: null));
      if (e.value.isEmpty) {
        rows.add((kind: _tagEmptyGroup, group: e.key, tag: null));
      } else {
        for (final tag in e.value) {
          rows.add((kind: 'tag', group: e.key, tag: tag));
        }
      }
    }
    final openByTag = m.openCountByTag;
    return ListView.builder(
      itemCount: rows.length,
      itemBuilder: (context, i) {
        final r = rows[i];
        if (r.kind == _tagHeader) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 4, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(r.group,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: a.muted)),
                ),
                // 默认组不可重命名/删除（桌面 classification_service 语义）
                if (r.group != kDefaultTagGroup)
                  PopupMenuButton<String>(
                    tooltip: '管理分组',
                    icon: Icon(Icons.more_horiz,
                        size: 20, color: a.muted),
                    onSelected: (v) {
                      if (v == 'rename') {
                        _editTagGroup(context, r.group);
                      } else {
                        _deleteTagGroup(context, r.group);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                          value: 'rename', child: Text('重命名分组')),
                      PopupMenuItem(
                          value: 'delete', child: Text('删除分组')),
                    ],
                  ),
              ],
            ),
          );
        }
        if (r.kind == _tagEmptyGroup) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text('空分组',
                style: TextStyle(fontSize: 12, color: a.muted)),
          );
        }
        final tag = r.tag!;
        return InkWell(
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
                Text('${openByTag[tag.name] ?? 0} 项未完成',
                    style: TextStyle(color: a.muted, fontSize: 13)),
                PopupMenuButton<String>(
                  onSelected: (v) async {
                    switch (v) {
                      case 'rename':
                        _editTag(context, tag);
                      case 'color':
                        _pickColor(context, isCategory: false, id: tag.id);
                      case 'group':
                        _setTagGroup(context, tag);
                      case 'delete':
                        _deleteTag(context, tag);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'rename', child: Text('重命名')),
                    PopupMenuItem(value: 'color', child: Text('颜色')),
                    PopupMenuItem(value: 'group', child: Text('设置分组')),
                    PopupMenuItem(value: 'delete', child: Text('删除')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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

  /// 设置单标签分组：弹层列出现有分组或新建（1-20 字符，空白归“其他”）。
  Future<void> _setTagGroup(BuildContext context, Tag tag) async {
    final m = widget.model;
    final groups = m.tagsByGroup.keys.toList();
    final ctrl = TextEditingController();
    final choice = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
              left: 16, right: 16, top: 16,
              bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('设置分组（${tag.name}）',
                  style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final g in groups)
                    FilterChip(
                      label: Text(g),
                      selected: AppModel.normalizeTagGroup(tag.group) == g,
                      onSelected: (_) => Navigator.pop(ctx, g),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                decoration:
                    const InputDecoration(hintText: '新建分组（1-20 个字符）'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, '::new::${ctrl.text}'),
                child: const Text('确定'),
              ),
            ],
          ),
        ),
      ),
    );
    ctrl.dispose();
    if (choice == null) return;
    final group =
        choice.startsWith('::new::') ? choice.substring(7) : choice;
    final err = await m.setTagGroup(tag.id, group);
    if (err != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  Future<void> _editTagGroup(BuildContext context, String group) async {
    final m = widget.model;
    final ctrl = TextEditingController(text: group);
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
            Text('重命名分组', style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(controller: ctrl, autofocus: true),
            const SizedBox(height: 12),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('保存')),
          ],
        ),
      ),
    );
    final name = ctrl.text;
    ctrl.dispose();
    if (ok != true) return;
    final err = await m.renameTagGroup(group, name);
    if (err != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  Future<void> _deleteTagGroup(BuildContext context, String group) async {
    final m = widget.model;
    final ok = await confirmDialog(
      context,
      title: '删除分组',
      message: '将删除分组“$group”，组内标签将移入“其他”。标签本身保留。',
      confirmText: '删除',
      destructive: true,
    );
    if (!ok) return;
    final err = await m.deleteTagGroup(group);
    if (err != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  Future<void> _pickColor(BuildContext context,
      {required bool isCategory, required String id}) async {
    // 桌面 32 色板中取 6 常用色（hex 值与桌面序列化一致）
    const palette = [
      '#4a9eff', '#6ccb5f', '#fb923c', '#a78bfa', '#f97066', '#8a8a8a',
    ];
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            for (final c in palette)
              ListTile(
                leading: Icon(Icons.circle, color: _parseHex(c)),
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

Color _parseHex(String hex) {
  final h = hex.replaceFirst('#', '');
  return Color(int.parse('FF$h', radix: 16));
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
      // 从分类列表新建继承当前目录（未分类视图则不带目录）
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final t = await model.createTodo(
              categoryId: category?.id,);
          if (context.mounted) openDetailPage(context, model, t.id, isNew: true);
        },
        child: const Icon(Icons.add),
      ),
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
      // 从标签列表新建继承当前标签
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final t = await model.createTodo(tagName: tag.name);
          if (context.mounted) openDetailPage(context, model, t.id, isNew: true);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// 色板 hex（#rrggbb）→ Color；非法值回退默认灰。
/// 色板值经规范化为有限集合，缓存避免列表每行重复解析。
final _hexColorCache = <String, Color>{};
Color _parseColor(String hex) => _hexColorCache.putIfAbsent(hex, () {
      final h = hex.replaceFirst('#', '');
      if (h.length == 6) {
        final v = int.tryParse(h, radix: 16);
        if (v != null) return Color(0xFF000000 | v);
      }
      return const Color(0xFF8A8A8A);
    });
