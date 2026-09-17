import 'package:flutter/material.dart';

import '../../app/app_model.dart';
import '../../domain/query.dart';
import '../../domain/todo.dart';
import '../app.dart';
import '../theme.dart';
import '../widgets.dart';

class TodayPage extends StatelessWidget {
  final AppModel model;
  const TodayPage({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: model,
      builder: (context, _) {
        final open = model.query(TodoQuery(view: TodoView.today));
        final overdue =
            open.where((t) => t.dueDate!.compareTo(model.today) < 0).toList();
        final dueToday = open.where((t) => t.dueDate == model.today).toList();
        // 计数只需一次遍历，无需再跑一遍带排序的全量查询
        final todayStr = model.today;
        final upcomingCount = model.todos
            .where((t) =>
                t.status == TodoStatus.open &&
                !t.isDeleted &&
                t.dueDate != null &&
                t.dueDate!.compareTo(todayStr) > 0)
            .length;
        final a = appColors(context, Theme.of(context).brightness);
        final now = DateTime.now();
        const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
        return Scaffold(
          appBar: AppBar(
            title: const Text('今日'),
            actions: [
              // 设计稿 L1785：今日页搜索入口 → 跳列表页并聚焦搜索框
              IconButton(
                tooltip: '搜索 Todo',
                onPressed: () => openInboxSearch?.call(),
                icon: const Icon(Icons.search),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: open.isEmpty
              ? ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('${now.month} 月 ${now.day} 日，星期${weekdays[now.weekday - 1]}',
                        style: TextStyle(fontSize: 14, color: a.muted)),
                    const SizedBox(height: 14),
                    _focusCard(context, a, 0, 0),
                    const SizedBox(height: 12),
                    const EmptyState(
                      icon: Icons.check_circle_outline,
                      title: '可以轻松一下了',
                      subtitle: '去列表看看接下来要做的事。',
                    ),
                    // 空状态也保留即将到期入口（设计稿 L1697 无条件渲染）
                    if (upcomingCount > 0)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            minimumSize: const Size(48, 48),
                            foregroundColor: a.brandInk,
                          ),
                          onPressed: () => openSecondaryPage(
                            context,
                            _FilteredListView(
                                model: model, view: TodoView.upcoming),
                          ),
                          child: Text('查看即将到期 $upcomingCount'),
                        ),
                      ),
                  ],
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('${now.month} 月 ${now.day} 日，星期${weekdays[now.weekday - 1]}',
                        style: TextStyle(fontSize: 14, color: a.muted)),
                    const SizedBox(height: 14),
                    _focusCard(context, a, open.length, overdue.length),
                    const SizedBox(height: 12),
                    if (overdue.isNotEmpty)
                      _section(context, '已过期', overdue, count: overdue.length,
                          color: a.danger),
                    if (dueToday.isNotEmpty)
                      _section(context, '今天到期', dueToday,
                          count: dueToday.length),
                    const SizedBox(height: 4),
                    // 设计稿：底部 text-button 入口（48dp 触控）
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          foregroundColor: a.brandInk,
                        ),
                        onPressed: () => openSecondaryPage(
                          context,
                          _FilteredListView(model: model, view: TodoView.upcoming),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('查看即将到期 $upcomingCount'),
                            const SizedBox(width: 6),
                            const Icon(Icons.chevron_right, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  /// 设计稿 .focus-card：brand-container 圆角 24 + 52dp 圆角图标 + 专注文案。
  Widget _focusCard(BuildContext context, AppColors a, int dueCount,
      int overdueCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: a.brandContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: a.panel,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.today_outlined, size: 26, color: a.brandInk),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dueCount > 0 ? '今天，专注这 $dueCount 件事' : '今天的任务都完成了',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      color: a.text),
                ),
                const SizedBox(height: 4),
                Text(
                  overdueCount > 0 ? '$overdueCount 项已过期，先处理它们' : '给重要的事留一点时间。',
                  style: TextStyle(fontSize: 14, color: a.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<Todo> items,
      {int? count, Color? color}) {
    final a = appColors(context, Theme.of(context).brightness);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 设计稿 .section-head：48dp 高 + 计数
        Container(
          constraints: const BoxConstraints(minHeight: 48),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: color ?? a.muted)),
              if (count != null) ...[
                const SizedBox(width: 8),
                Text('$count',
                    style: TextStyle(fontSize: 12, color: a.muted)),
              ],
            ],
          ),
        ),
        ...items.map((t) => TodoTile(
              model: model,
              todo: t,
              onOpen: () => openDetailPage(context, model, t.id),
            )),
      ],
    );
  }
}

/// 今日“即将到期”跳转列表（返回时保持今日页状态由 IndexedStack 保证）。
class _FilteredListView extends StatelessWidget {
  final AppModel model;
  final TodoView view;
  const _FilteredListView({required this.model, required this.view});

  @override
  Widget build(BuildContext context) {
    return SecondaryScaffold(
      title: view == TodoView.upcoming ? '即将到期' : '列表',
      body: AnimatedBuilder(
        animation: model,
        builder: (context, _) {
          final list = model.query(TodoQuery(view: view));
          return list.isEmpty
              ? const EmptyState(
                  icon: Icons.event_available, title: '暂无即将到期任务')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final t = list[i];
                    return TodoTile(
                      model: model,
                      todo: t,
                      showCategory: true,
                      onOpen: () => openDetailPage(context, model, t.id),
                    );
                  },
                );
        },
      ),
    );
  }
}
