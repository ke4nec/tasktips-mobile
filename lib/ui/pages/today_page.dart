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
        final upcomingCount =
            model.query(TodoQuery(view: TodoView.upcoming)).length;
        final a = appColors(context, Theme.of(context).brightness);
        return Scaffold(
          appBar: AppBar(
            title: const Text('今日'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => openSecondaryPage(
                      context,
                      _FilteredListView(model: model, view: TodoView.upcoming),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: a.brandContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('即将到期 $upcomingCount',
                          style: TextStyle(fontSize: 13, color: a.brandInk)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: open.isEmpty
              ? const EmptyState(
                  icon: Icons.check_circle_outline,
                  title: '今天没有到期任务',
                  subtitle: '点右下角 + 新建一条',
                )
              : ListView(
                  children: [
                    if (overdue.isNotEmpty)
                      _section(context, '已过期', overdue,
                          color: a.danger),
                    if (dueToday.isNotEmpty)
                      _section(context, '今天到期', dueToday),
                  ],
                ),
        );
      },
    );
  }

  Widget _section(BuildContext context, String title, List<Todo> items,
      {Color? color}) {
    final a = appColors(context, Theme.of(context).brightness);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(title,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color ?? a.muted)),
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
              : ListView(
                  children: list
                      .map((t) => TodoTile(
                            model: model,
                            todo: t,
                            showCategory: true,
                            onOpen: () => openDetailPage(context, model, t.id),
                          ))
                      .toList(),
                );
        },
      ),
    );
  }
}
