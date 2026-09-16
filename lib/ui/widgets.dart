/// 共享列表组件：Todo 行（复选框、标题、摘要、标签、优先级、日期）。
library;

import 'package:flutter/material.dart';

import '../app/app_model.dart';
import '../domain/todo.dart';
import 'theme.dart';

class TodoTile extends StatelessWidget {
  final AppModel model;
  final Todo todo;
  final VoidCallback onOpen;
  final bool showCategory;

  const TodoTile({
    super.key,
    required this.model,
    required this.todo,
    required this.onOpen,
    this.showCategory = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = appColors(context, Theme.of(context).brightness);
    final overdue = todo.isOverdue;
    final title = todo.title.isEmpty ? '未命名 Todo' : todo.title;
    final excerpt = _excerpt(todo.body);
    return Semantics(
      label: '${todo.isCompleted ? "已完成" : "未完成"}，$title',
      button: true,
      child: InkWell(
        onTap: onOpen,
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: a.line)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Semantics(
                label: todo.isCompleted ? '取消完成' : '完成',
                button: true,
                child: InkWell(
                  customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  onTap: () => model.setCompleted(todo.id, !todo.isCompleted),
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: todo.isCompleted ? a.brand : a.muted,
                          width: 2,
                        ),
                        color: todo.isCompleted ? a.brandContainer : null,
                      ),
                      child: todo.isCompleted
                          ? Icon(Icons.check, size: 16, color: a.brand)
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: todo.isCompleted ? a.muted : a.text,
                        decoration:
                            todo.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (excerpt.isNotEmpty)
                      Text(
                        excerpt,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: a.muted),
                      ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (todo.priority > 0)
                          _chip(
                            context,
                            label: priorityLabel(todo.priority),
                            fg: todo.priority == 3
                                ? a.danger
                                : todo.priority == 2
                                    ? a.warn
                                    : a.muted,
                            bg: todo.priority == 3
                                ? a.dangerContainer
                                : todo.priority == 2
                                    ? a.warnContainer
                                    : a.surface,
                          ),
                        if (todo.dueDate != null)
                          _chip(
                            context,
                            label: _formatDue(todo.dueDate!),
                            fg: overdue ? a.danger : a.muted,
                            bg: overdue ? a.dangerContainer : a.surface,
                          ),
                        if (showCategory && todo.categoryId != null)
                          _chip(context,
                              label: model.classification
                                  .categoryPath(todo.categoryId),
                              fg: a.muted,
                              bg: a.surface),
                        for (final tag in todo.tags.take(3))
                          _chip(context,
                              label: '#$tag',
                              fg: a.purple,
                              bg: a.purpleContainer),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _excerpt(String body) {
    final lines = body
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .skip(1) // 首行是标题
        .join(' ');
    return lines;
  }

  String _formatDue(String d) {
    final today = model.today;
    if (d == today) return '今天';
    if (d.compareTo(today) < 0) return '已过期 $d';
    return d;
  }
}

Widget _chip(BuildContext c, {required String label, required Color fg, required Color bg}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(label, style: TextStyle(fontSize: 12, color: fg)),
  );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  const EmptyState({super.key, required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final a = appColors(context, Theme.of(context).brightness);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: a.muted),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: 16, color: a.muted)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: TextStyle(fontSize: 13, color: a.muted)),
            ],
          ],
        ),
      ),
    );
  }
}

/// 确认对话框；destructive 用于永久删除/清空。
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = '确定',
  bool destructive = false,
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error)
              : null,
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return r ?? false;
}
