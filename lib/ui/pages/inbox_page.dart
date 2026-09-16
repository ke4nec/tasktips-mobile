import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_model.dart';
import '../../domain/query.dart';
import '../../domain/todo.dart';
import '../app.dart';
import '../theme.dart';
import '../widgets.dart';

/// Todo 列表页：搜索、视图切换（全部/即将到期/已完成）与底部筛选排序面板。
class InboxPage extends StatefulWidget {
  final AppModel model;
  const InboxPage({super.key, required this.model});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage>
    with AutomaticKeepAliveClientMixin {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final TodoQuery _q = TodoQuery();
  Timer? _searchDebounce;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo 列表'),
        actions: [
          IconButton(
            tooltip: '回收站',
            onPressed: () => openTrashPage(context, widget.model),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(108),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 56,
                  child: SearchBar(
                    hintText: '搜索标题、正文或标签',
                    leading: const Icon(Icons.search),
                    controller: _searchCtrl,
                    elevation: const WidgetStatePropertyAll(0),
                    onChanged: (v) {
                      // 防抖：避免每个字符触发一次全量过滤+排序
                      _searchDebounce?.cancel();
                      _searchDebounce = Timer(
                          const Duration(milliseconds: 200),
                          () => setState(() => _q.search = v));
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _seg(context, '全部', TodoView.all),
                    const SizedBox(width: 8),
                    _seg(context, '未完成', TodoView.inbox),
                    const SizedBox(width: 8),
                    _seg(context, '即将到期', TodoView.upcoming),
                    const SizedBox(width: 8),
                    _seg(context, '已完成', TodoView.completed),
                    const Spacer(),
                    IconButton(
                      tooltip: '筛选与排序',
                      onPressed: _openFilterSheet,
                      icon: Badge(
                        isLabelVisible: _q.hasActiveFilter,
                        child: const Icon(Icons.tune),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: widget.model,
        builder: (context, _) {
          final list = widget.model.query(_q);
          if (list.isEmpty) {
            return _q.hasActiveFilter
                ? const EmptyState(icon: Icons.search_off, title: '没有匹配的结果', subtitle: '调整搜索或清除筛选')
                : const EmptyState(icon: Icons.checklist, title: '暂无任务', subtitle: '点右下角 + 新建一条');
          }
          return ListView.builder(
            controller: _scrollCtrl,
            itemCount: list.length,
            itemBuilder: (context, i) => TodoTile(
              model: widget.model,
              todo: list[i],
              showCategory: true,
              onOpen: () => openDetailPage(context, widget.model, list[i].id),
            ),
          );
        },
      ),
    );
  }

  Widget _seg(BuildContext context, String label, TodoView v) {
    final a = appColors(context, Theme.of(context).brightness);
    final selected = _q.view == v;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _q.view = v),
        child: Container(
          // 设计稿：主操作触控区最小 48dp（.seg 规则）
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? a.brandContainer : a.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? a.brandOutline : Colors.transparent),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: selected ? a.brandInk : a.muted,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
        ),
      ),
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _FilterSheet(
        model: widget.model,
        query: _q,
        onChanged: () => setState(() {}),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final AppModel model;
  final TodoQuery query;
  final VoidCallback onChanged;
  const _FilterSheet({required this.model, required this.query, required this.onChanged});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late TodoQuery q = widget.query;

  @override
  Widget build(BuildContext context) {
    final a = appColors(context, Theme.of(context).brightness);
    final tags = widget.model.visibleTags;
    final cats = widget.model.rootCategories;
    return Padding(
      padding: EdgeInsets.only(
          left: 16, right: 16, top: 8,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('筛选与排序', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              TextButton(
                onPressed: () {
                  q.tagNames = null;
                  q.priorities = {};
                  q.categoryIds = null;
                  q.uncategorized = false;
                  q.dueFrom = null;
                  q.dueTo = null;
                  q.defaultSort = true;
                  setState(() {});
                },
                child: const Text('清除筛选'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('优先级', style: _labelStyle(a)),
          Wrap(
            spacing: 8,
            children: [
              for (final p in kPriorities)
                FilterChip(
                  label: Text(priorityLabel(p)),
                  selected: q.priorities.contains(p),
                  onSelected: (sel) => setState(() => sel
                      ? q.priorities.add(p)
                      : q.priorities.remove(p)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text('目录', style: _labelStyle(a)),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('未分类'),
                selected: q.uncategorized,
                onSelected: (sel) =>
                    setState(() => q.uncategorized = sel),
              ),
              for (final c in cats)
                FilterChip(
                  label: Text(c.name),
                  selected:
                      q.categoryIds != null && q.categoryIds!.contains(c.id),
                  onSelected: (sel) {
                    setState(() {
                      q.categoryIds ??= <String>[];
                      final ids = widget.model.expandCategoryIds(c.id).toList();
                      if (sel) {
                        q.categoryIds = {...q.categoryIds!, ...ids}.toList();
                      } else {
                        q.categoryIds!.removeWhere(ids.contains);
                      }
                    });
                  },
                ),
            ],
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('标签（全部匹配）', style: _labelStyle(a)),
            Wrap(
              spacing: 8,
              children: [
                for (final t in tags)
                  FilterChip(
                    label: Text('#${t.name}'),
                    selected:
                        q.tagNames != null && q.tagNames!.contains(t.name),
                    onSelected: (sel) => setState(() {
                      q.tagNames ??= <String>[];
                      sel
                          ? q.tagNames!.add(t.name)
                          : q.tagNames!.remove(t.name);
                    }),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Text('排序', style: _labelStyle(a)),
          Row(
            children: [
              Expanded(
                child: DropdownButton<SortKey>(
                  isExpanded: true,
                  value: q.sortKey,
                  items: const [
                    DropdownMenuItem(value: SortKey.updatedAt, child: Text('更新时间')),
                    DropdownMenuItem(value: SortKey.createdAt, child: Text('创建时间')),
                    DropdownMenuItem(value: SortKey.dueDate, child: Text('截止日期')),
                    DropdownMenuItem(value: SortKey.priority, child: Text('优先级')),
                    DropdownMenuItem(value: SortKey.title, child: Text('标题')),
                  ],
                  onChanged: (v) => setState(() {
                    q.sortKey = v!;
                    q.defaultSort = false;
                  }),
                ),
              ),
              const SizedBox(width: 12),
              SegmentedButton<SortOrder>(
                segments: const [
                  ButtonSegment(value: SortOrder.asc, label: Text('升序')),
                  ButtonSegment(value: SortOrder.desc, label: Text('降序')),
                ],
                selected: {q.sortOrder},
                onSelectionChanged: (s) => setState(() {
                  q.sortOrder = s.first;
                  q.defaultSort = false;
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                widget.onChanged();
                Navigator.pop(context);
              },
              child: const Text('应用'),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _labelStyle(AppColors a) =>
      TextStyle(fontSize: 13, color: a.muted, fontWeight: FontWeight.w600);
}
