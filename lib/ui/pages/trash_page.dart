import 'package:flutter/material.dart';

import '../../app/app_model.dart';
import '../app.dart';
import '../theme.dart';
import '../widgets.dart';

/// 回收站：Todo/目录/标签类型筛选，恢复优先，永久删除与清空需确认。
class TrashPage extends StatefulWidget {
  final AppModel model;
  const TrashPage({super.key, required this.model});

  @override
  State<TrashPage> createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
  int _seg = 0; // 0 Todo 1 目录 2 标签

  @override
  Widget build(BuildContext context) {
    final m = widget.model;
    final a = appColors(context, Theme.of(context).brightness);
    return SecondaryScaffold(
      title: '回收站',
      actions: [
        IconButton(
          tooltip: '清空回收站',
          onPressed: () async {
            final ok = await confirmDialog(context,
                title: '清空回收站',
                message: '将彻底删除回收站中的全部 Todo、目录和标签，不可恢复。',
                confirmText: '清空',
                destructive: true);
            if (ok) {
              await m.emptyTrash();
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('回收站已清空')));
              }
            }
          },
          icon: const Icon(Icons.delete_sweep_outlined),
        ),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('Todo')),
                      ButtonSegment(value: 1, label: Text('目录')),
                      ButtonSegment(value: 2, label: Text('标签')),
                    ],
                    selected: {_seg},
                    onSelectionChanged: (s) => setState(() => _seg = s.first),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('删除后保留 30 天，到期自动清理。',
                  style: TextStyle(fontSize: 12, color: a.muted)),
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: m,
              builder: (context, _) {
                switch (_seg) {
                  case 0:
                    return _todoList(context);
                  case 1:
                    return _categoryList(context);
                  default:
                    return _tagList(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemShell(BuildContext context,
      {required Widget leading,
      required String title,
      required String subtitle,
      required VoidCallback onRestore,
      required VoidCallback onPurge,
      required bool Function() canPurgeNow}) {
    final a = appColors(context, Theme.of(context).brightness);
    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration:
          BoxDecoration(border: Border(bottom: BorderSide(color: a.line))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(children: [
                  leading,
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500)),
                  ),
                ]),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(fontSize: 12, color: a.muted)),
              ],
            ),
          ),
          IconButton(
            tooltip: '恢复',
            onPressed: onRestore,
            icon: Icon(Icons.restore, color: a.brand),
          ),
          IconButton(
            tooltip: '彻底删除',
            onPressed: onPurge,
            icon: Icon(Icons.delete_forever_outlined, color: a.danger),
          ),
        ],
      ),
    );
  }

  Widget _todoList(BuildContext context) {
    final m = widget.model;
    final items = m.trashedTodos;
    if (items.isEmpty) return _empty();
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, i) {
        final t = items[i];
        return _itemShell(
          context,
          leading: Icon(
            t.isCompleted ? Icons.task_alt : Icons.description_outlined,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          title: t.title.isEmpty ? '未命名 Todo' : t.title,
          subtitle:
              '删除于 ${t.deletedAt!.toLocal().toString().substring(0, 16)} · 剩余 ${m.remainingDays(t.deletedAt!)} 天 · ${m.classification.categoryPath(t.categoryId)}',
          onRestore: () => m.restoreTodo(t.id),
          onPurge: () async {
            final ok = await confirmDialog(context,
                title: '彻底删除',
                message: '将永久删除“${t.title.isEmpty ? '未命名 Todo' : t.title}”，不可恢复。',
                confirmText: '彻底删除',
                destructive: true);
            if (ok) await m.purgeTodo(t.id);
          },
          canPurgeNow: () => true,
        );
      },
    );
  }

  Widget _categoryList(BuildContext context) {
    final m = widget.model;
    final items = m.trashedCategories;
    if (items.isEmpty) return _empty();
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, i) {
        final c = items[i];
        return _itemShell(
          context,
          leading: const Icon(Icons.folder_delete_outlined, size: 20),
          title: m.classification.categoryPath(c.id),
          subtitle:
              '删除于 ${c.deletedAt!.toLocal().toString().substring(0, 16)} · 剩余 ${m.remainingDays(c.deletedAt!)} 天',
          onRestore: () async {
            await m.restoreCategory(c.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('目录已恢复')));
            }
          },
          onPurge: () async {
            final ok = await confirmDialog(context,
                title: '彻底删除',
                message: '将永久删除目录“${c.name}”，不可恢复。',
                confirmText: '彻底删除',
                destructive: true);
            if (ok) await m.purgeCategory(c.id);
          },
          canPurgeNow: () => true,
        );
      },
    );
  }

  Widget _tagList(BuildContext context) {
    final m = widget.model;
    final items = m.trashedTags;
    if (items.isEmpty) return _empty();
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, i) {
        final t = items[i];
        return _itemShell(
          context,
          leading: const Icon(Icons.tag, size: 20),
          title: t.name,
          subtitle:
              '删除于 ${t.deletedAt!.toLocal().toString().substring(0, 16)} · 剩余 ${m.remainingDays(t.deletedAt!)} 天 · 关联 ${m.todos.where((e) => e.tags.contains(t.name)).length} 条',
          onRestore: () async {
            await m.restoreTag(t.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('标签已恢复')));
            }
          },
          onPurge: () async {
            final ok = await confirmDialog(context,
                title: '彻底删除',
                message: '将永久删除标签“${t.name}”，并从所有 Todo 中移除该标签。',
                confirmText: '彻底删除',
                destructive: true);
            if (ok) await m.purgeTag(t.id);
          },
          canPurgeNow: () => true,
        );
      },
    );
  }

  Widget _empty() => const EmptyState(icon: Icons.delete_outline, title: '回收站为空');
}
