/// 共享列表组件：Todo 卡片（复选框、标题、摘要 1 行、标签、优先级、日期、更多操作）。
library;

import 'package:flutter/material.dart';

import '../app/app_model.dart';
import '../domain/todo.dart';
import 'theme.dart';

/// 设计稿 friendlyDate：今天/明天/N 月 N 日/未设置。
String friendlyDate(String today, String? d) {
  if (d == null || d.isEmpty) return '未设置';
  if (d == today) return '今天';
  final t = DateTime.tryParse(today);
  if (t != null) {
    final tomorrow = DateTime(t.year, t.month, t.day + 1);
    if (d == tomorrow.toIso8601String().substring(0, 10)) return '明天';
  }
  if (d.length >= 10) {
    final m = int.tryParse(d.substring(5, 7));
    final day = int.tryParse(d.substring(8, 10));
    if (m != null && day != null) return '$m 月 $day 日';
  }
  return d;
}

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
    // 设计稿 .task：panel 底、line 边框、圆角 16、内边距 4，
    // 三列 48 | 自适应 | 48
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: a.panel,
        border: Border.all(color: a.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 完成勾选（48×48，圆角 12）
          Semantics(
            label: todo.isCompleted ? '取消完成：$title' : '完成：$title',
            button: true,
            checked: todo.isCompleted,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => model.setCompleted(todo.id, !todo.isCompleted),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: todo.isCompleted ? a.brandInk : a.muted,
                        width: 1.5,
                      ),
                      color: todo.isCompleted ? a.brandContainer : null,
                    ),
                    child: todo.isCompleted
                        ? Icon(Icons.check, size: 17, color: a.brandInk)
                        : null,
                  ),
                ),
              ),
            ),
          ),
          // 主体：标题 + 摘要 1 行 + meta
          Expanded(
            child: InkWell(
              onTap: onOpen,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                        color: todo.isCompleted ? a.muted : a.text,
                        decoration: todo.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (excerpt.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        excerpt,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14, height: 1.5, color: a.muted),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (final tag in todo.tags.take(3))
                          _tag(a, label: tag),
                        if (todo.priority == 3)
                          _tag(a, label: '高优先级', warn: true),
                        if (showCategory && todo.categoryId != null)
                          _tag(a,
                              label: model.classification
                                  .categoryPath(todo.categoryId),
                              purple: true),
                        if (todo.dueDate != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.today_outlined,
                                  size: 14,
                                  color: overdue ? a.danger : a.muted),
                              const SizedBox(width: 4),
                              Text(
                                overdue
                                    ? '已过期 · ${friendlyDate(model.today, todo.dueDate)}'
                                    : friendlyDate(model.today, todo.dueDate),
                                style: TextStyle(
                                    fontSize: 12,
                                    height: 1.5,
                                    color: overdue ? a.danger : a.muted),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 更多操作（48×48）
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              tooltip: '更多操作：$title',
              onPressed: () => _showTodoMenu(context, a, title),
              icon: Icon(Icons.more_horiz, size: 20, color: a.muted),
            ),
          ),
        ],
      ),
    );
  }

  /// 单卡“更多操作”底部面板：标记完成 / 移入回收站。
  Future<void> _showTodoMenu(
      BuildContext context, AppColors a, String title) async {
    final action = await showSheetOptions<String>(
      context,
      title: title,
      options: [
        SheetOption(
            todo.isCompleted ? '取消完成' : '标记完成',
            todo.isCompleted ? Icons.task_alt_outlined : Icons.check,
            'toggle'),
        SheetOption('移入回收站', Icons.delete_outline, 'trash'),
      ],
    );
    if (action == null) return;
    switch (action) {
      case 'toggle':
        await model.setCompleted(todo.id, !todo.isCompleted);
      case 'trash':
        if (!context.mounted) return;
        final ok = await confirmDialog(context,
            title: '移入回收站',
            message: '“$title”将移入回收站，30 天后自动删除。',
            confirmText: '移入回收站');
        if (ok) await model.trashTodo(todo.id);
    }
  }

  /// 设计稿 .tag：圆角 6，brand-container 底；purple/warn 两个变体。
  Widget _tag(AppColors a,
      {required String label, bool purple = false, bool warn = false}) {
    final (bg, fg) = purple
        ? (a.purpleContainer, a.purple)
        : warn
            ? (a.warnContainer, a.warn)
            : (a.brandContainer, a.brandInk);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 12, height: 1.5, color: fg)),
    );
  }

  String _excerpt(String body) {
    // Expando 按 Todo 对象身份缓存；writeTodo/pull 落盘都会替换对象实例，
    // 旧摘要随对象一起丢弃，无需手动失效。
    final cached = _excerptCache[todo];
    if (cached != null) return cached;
    final s = body
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .skip(1) // 首行是标题
        .join(' ');
    return _excerptCache[todo] = s;
  }
}

final _excerptCache = Expando<String>();

class SheetOption<T> {
  final String label;
  final IconData icon;
  final T value;
  const SheetOption(this.label, this.icon, this.value);
}

/// 底部选项面板（设计稿 .sheet / .sheet-option：56dp 行、圆角 28 顶部）。
Future<T?> showSheetOptions<T>(
  BuildContext context, {
  String? title,
  required List<SheetOption<T>> options,
}) {
  final a = appColors(context, Theme.of(context).brightness);
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: a.panel,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              decoration: BoxDecoration(
                color: a.muted.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w500)),
            ),
          for (final o in options)
            ListTile(
              minLeadingWidth: 24,
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: Icon(o.icon, size: 20, color: a.text),
              title: Text(o.label, style: const TextStyle(fontSize: 15)),
              onTap: () => Navigator.pop(ctx, o.value),
            ),
          const SizedBox(height: 12),
        ],
      ),
    ),
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
            Text(title,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w500, color: a.muted)),
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

/// 确认弹层：设计稿全 app 统一为底部 sheet（danger 用 danger-container 底）。
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = '确定',
  bool destructive = false,
}) async {
  final a = appColors(context, Theme.of(context).brightness);
  final r = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: a.panel,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: a.muted.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Text(title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(message,
                style: TextStyle(fontSize: 14, height: 1.5, color: a.muted)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                      minimumSize: const Size(72, 48)),
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(72, 48),
                    backgroundColor: destructive
                        ? a.dangerContainer
                        : null,
                    foregroundColor: destructive ? a.danger : null,
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(confirmText),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return r ?? false;
}
