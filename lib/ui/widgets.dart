/// 共享列表组件：Todo 卡片（复选框、标题、摘要 1 行、标签、优先级、日期、更多操作）。
library;

import 'package:flutter/material.dart';

import '../app/app_model.dart';
import '../domain/todo.dart';
import 'theme.dart';

/// 设计稿 friendlyDate：今天/明天/N 月 N 日/未设置。
/// “明天”按今日串缓存：列表每行取值时避免重复 DateTime 解析与构造。
String _tomorrowOf(String today) {
  if (_fdCacheKey != today) {
    _fdCacheKey = today;
    final t = DateTime.tryParse(today);
    _fdTomorrow = t == null
        ? null
        : DateTime(t.year, t.month, t.day + 1).toIso8601String().substring(0, 10);
  }
  return _fdTomorrow ?? '';
}

String? _fdCacheKey;
String? _fdTomorrow;

String friendlyDate(String today, String? d) {
  if (d == null || d.isEmpty) return '未设置';
  if (d == today) return '今天';
  final tomorrow = _tomorrowOf(today);
  if (tomorrow.isNotEmpty && d == tomorrow) return '明天';
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

  /// 多选模式：点按切换选中（不再打开详情/勾选完成），左滑删除禁用。
  final bool selectionMode;
  final bool selected;
  final VoidCallback? onToggleSelect;

  /// 长按进入多选。拖拽排序列表里长按被拖拽占用，
  /// 那里走“更多操作”菜单的“多选”进入（onEnterSelect 同一回调）。
  final VoidCallback? onEnterSelect;

  const TodoTile({
    super.key,
    required this.model,
    required this.todo,
    required this.onOpen,
    this.showCategory = false,
    this.selectionMode = false,
    this.selected = false,
    this.onToggleSelect,
    this.onEnterSelect,
  });

  @override
  Widget build(BuildContext context) {
    final a = appColors(context, Theme.of(context).brightness);
    final overdue = todo.isOverdue;
    final title = todo.title.isEmpty ? '未命名 Todo' : todo.title;
    final excerpt = _excerpt(todo.body);
    final selecting = selectionMode && selected;
    // 多选模式下勾选框即选中框（选中态与完成态同一样式）
    final checkedBox = selectionMode ? selected : todo.isCompleted;
    // 设计稿 .task：panel 底、line 边框、圆角 16、内边距 4，
    // 三列 48 | 自适应 | 48；左滑删除（移入回收站，二次确认，动画结束再落盘）
    return Dismissible(
      // 与条目 key 区分：拖拽分支外层 TodoTile 另带 ValueKey(id)
      key: ValueKey('dismiss-${todo.id}'),
      direction: DismissDirection.endToStart,
      // 多选模式下左滑弹回：点按切换选中才是唯一手势
      confirmDismiss:
          selectionMode ? (_) async => false : (_) => _confirmTrash(context, title),
      onDismissed: (_) => model.trashTodo(todo.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: a.dangerContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Icon(Icons.delete_outline, color: a.danger),
      ),
      child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: selecting ? a.brandContainer : a.panel,
        border: Border.all(color: selecting ? a.brand : a.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 完成勾选（48×48，圆角 12）；多选模式下变选中框
          Semantics(
            label: selectionMode
                ? (selected ? '取消选中：$title' : '选中：$title')
                : (todo.isCompleted ? '取消完成：$title' : '完成：$title'),
            button: true,
            checked: checkedBox,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: selectionMode
                  ? onToggleSelect
                  : () => model.setCompleted(todo.id, !todo.isCompleted),
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
                        color: checkedBox ? a.brandInk : a.muted,
                        width: 1.5,
                      ),
                      color: checkedBox ? a.brandContainer : null,
                    ),
                    child: checkedBox
                        ? Icon(Icons.check, size: 17, color: a.brandInk)
                        : null,
                  ),
                ),
              ),
            ),
          ),
          // 主体：标题 + 摘要 1 行 + meta；多选模式点按切换选中，长按进入多选
          Expanded(
            child: InkWell(
              onTap: selectionMode ? onToggleSelect : onOpen,
              onLongPress: selectionMode ? null : onEnterSelect,
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
                              label: model.categoryPath(todo.categoryId),
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
      ),
    );
  }

  /// 左滑删除二次确认：与“更多操作”菜单的移入回收站同文案。
  Future<bool> _confirmTrash(BuildContext context, String title) async {
    final ok = await confirmDialog(context,
        title: '移入回收站',
        message: '“$title”将移入回收站，30 天后自动删除。',
        confirmText: '移入回收站');
    return ok;
  }

  /// 单卡“更多操作”底部面板：标记完成 / 多选 / 移入回收站。
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
        const SheetOption('多选', Icons.select_all, 'select'),
        SheetOption('移入回收站', Icons.delete_outline, 'trash'),
      ],
    );
    if (action == null) return;
    switch (action) {
      case 'toggle':
        await model.setCompleted(todo.id, !todo.isCompleted);
      case 'select':
        onEnterSelect?.call();
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

/// 仅在所属 Tab 激活时随 model 变化重建的构建器。
/// IndexedStack 下四个 Tab 常驻：编辑自动保存/同步落盘等高频通知
/// 不再触发离场页面全量查询+重建（4 份→1 份）；重新激活时刷新一帧
/// 取回最新数据，保证切回时视图与 model 一致。
class ActiveModelBuilder extends StatefulWidget {
  final AppModel model;
  final bool active;
  final Widget Function(BuildContext context) builder;
  const ActiveModelBuilder({
    super.key,
    required this.model,
    required this.active,
    required this.builder,
  });

  @override
  State<ActiveModelBuilder> createState() => _ActiveModelBuilderState();
}

class _ActiveModelBuilderState extends State<ActiveModelBuilder> {
  @override
  void initState() {
    super.initState();
    widget.model.addListener(_onModelChanged);
  }

  @override
  void didUpdateWidget(ActiveModelBuilder old) {
    super.didUpdateWidget(old);
    if (old.model != widget.model) {
      old.model.removeListener(_onModelChanged);
      widget.model.addListener(_onModelChanged);
    }
    if (old.active != widget.active && widget.active) setState(() {});
  }

  @override
  void dispose() {
    widget.model.removeListener(_onModelChanged);
    super.dispose();
  }

  void _onModelChanged() {
    if (widget.active && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}

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

/// 列表多选操作条：放列表页底部（bottomNavigationBar/bottomBar 槽），
/// 已选计数 + 全选 + 删除 + 取消。批量删除的二次确认由调用页负责。
class SelectionBar extends StatelessWidget {
  final int count;
  final VoidCallback onSelectAll;
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  const SelectionBar({
    super.key,
    required this.count,
    required this.onSelectAll,
    required this.onDelete,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final a = appColors(context, Theme.of(context).brightness);
    Widget btn(String label, VoidCallback onTap, {Color? color}) => TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(64, 48),
            foregroundColor: color,
          ),
          onPressed: onTap,
          child: Text(label),
        );
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: a.panel,
          border: Border(top: BorderSide(color: a.line)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('已选 $count 项',
                  style: TextStyle(fontSize: 14, color: a.text)),
            ),
            const Spacer(),
            btn('全选', onSelectAll),
            btn('删除', onDelete, color: a.danger),
            btn('取消', onCancel),
          ],
        ),
      ),
    );
  }
}

/// 列表页长按多选通用状态（今日/列表/分类/标签四处列表共用）：
/// 长按条目或“更多操作”菜单进入多选，点按切换，全选/删除/取消走底部
/// [SelectionBar]。批量删除二次确认后逐条 trashTodo，完事清选择。
mixin TodoSelectionMixin<T extends StatefulWidget> on State<T> {
  /// 所在页的 model（经 widget 持有）。
  AppModel get selectionModel;

  final Set<String> selectedIds = {};
  bool get selecting => selectedIds.isNotEmpty;

  void enterSelect(String id) {
    if (mounted) setState(() => selectedIds.add(id));
  }

  void toggleSelect(String id) {
    if (!mounted) return;
    setState(() {
      if (!selectedIds.remove(id)) selectedIds.add(id);
    });
  }

  void selectAllVisible(List<Todo> items) {
    if (mounted) setState(() => selectedIds.addAll(items.map((t) => t.id)));
  }

  void cancelSelect() {
    if (mounted) setState(selectedIds.clear);
  }

  Future<void> deleteSelected() async {
    final n = selectedIds.length;
    if (n == 0) return;
    final ok = await confirmDialog(context,
        title: '移入回收站',
        message: '将 $n 项移入回收站，30 天后自动删除。',
        confirmText: '移入回收站');
    if (!ok || !mounted) return;
    final ids = selectedIds.toList();
    setState(selectedIds.clear);
    for (final id in ids) {
      await selectionModel.trashTodo(id);
    }
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('已将 $n 项移入回收站')));
    }
  }

  /// 当前可见列表的多选操作条；非多选时返回 null，直接喂 bottomBar 槽。
  SelectionBar? selectionBar(List<Todo> visible) => selecting
      ? SelectionBar(
          count: selectedIds.length,
          onSelectAll: () => selectAllVisible(visible),
          onDelete: deleteSelected,
          onCancel: cancelSelect,
        )
      : null;

  /// 按本页多选态装配 TodoTile（调用页只传各自的展示参数与打开回调）。
  /// [key] 供拖拽排序分支（要求条目带 key），普通列表可不传。
  Widget selectableTile(
    BuildContext context, {
    Key? key,
    required Todo todo,
    bool showCategory = false,
    required VoidCallback onOpen,
  }) =>
      TodoTile(
        key: key,
        model: selectionModel,
        todo: todo,
        showCategory: showCategory,
        selectionMode: selecting,
        selected: selectedIds.contains(todo.id),
        onToggleSelect: () => toggleSelect(todo.id),
        onEnterSelect: () => enterSelect(todo.id),
        onOpen: onOpen,
      );
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
