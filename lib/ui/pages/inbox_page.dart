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

  /// 所属 Tab 是否激活：离场时不再随 model 高频通知全量重建。
  final bool active;
  const InboxPage({super.key, required this.model, this.active = true});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage>
    with AutomaticKeepAliveClientMixin, TodoSelectionMixin {
  @override
  AppModel get selectionModel => widget.model;

  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _searchFocus = FocusNode();
  final TodoQuery _q = TodoQuery();
  Timer? _searchDebounce;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // 今日页搜索入口联动：切到本页时聚焦搜索框
    inboxSearchFocusTick.addListener(_onSearchRequested);
  }

  void _onSearchRequested() {
    _searchFocus.requestFocus();
  }

  @override
  void dispose() {
    inboxSearchFocusTick.removeListener(_onSearchRequested);
    _searchDebounce?.cancel();
    _searchFocus.dispose();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ---------- 长按多选（状态与批量删除见 TodoSelectionMixin） ----------

  Widget _tile(Todo t) => selectableTile(
        context,
        // 拖拽排序分支要求条目带 key；普通列表带 key 无影响
        key: ValueKey(t.id),
        todo: t,
        showCategory: true,
        onOpen: () => openDetailPage(context, widget.model, t.id),
      );

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
                    focusNode: _searchFocus,
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
      body: ActiveModelBuilder(
        model: widget.model,
        active: widget.active,
        builder: (context) {
          final list = widget.model.query(_q);
          if (list.isEmpty) {
            return _q.hasActiveFilter
                ? const EmptyState(icon: Icons.search_off, title: '没有匹配的结果', subtitle: '调整搜索或清除筛选')
                : const EmptyState(icon: Icons.checklist, title: '暂无任务', subtitle: '点右下角 + 新建一条');
          }
          // 设计稿 result-summary：结果计数 + 生中的筛选/排序说明
          final sortLabel = _q.defaultSort
              ? ''
              : ' · 按${switch (_q.sortKey) {
                  SortKey.updatedAt => '更新时间',
                  SortKey.createdAt => '创建时间',
                  SortKey.dueDate => '截止日期',
                  SortKey.priority => '优先级',
                  SortKey.title => '标题',
                }}';
          final highPriority =
              list.any((t) => t.priority == 3) ? ' · 高优先级' : '';
          // 自定义顺序拖拽：仅默认排序 + Inbox/All 视图 + 无搜索筛选时启用
          //（桌面设计语义；筛选/显式排序态禁用，避免整组覆盖丢失旧顺序）。
          // 多选模式下禁用拖拽：长按手势归选中，避免与拖拽打架。
          final reorderable = _q.defaultSort &&
              (_q.view == TodoView.inbox || _q.view == TodoView.all) &&
              !_q.hasActiveFilter &&
              !selecting;
          final reorderHint = reorderable ? ' · 长按拖动排序' : '';
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('${list.length} 项$highPriority$sortLabel$reorderHint',
                      style: TextStyle(
                          fontSize: 12, color: appColors(context, Theme.of(context).brightness).muted)),
                ),
              ),
              Expanded(
                child: reorderable
                    ? ReorderableListView.builder(
                        // 与普通列表共用 PageStorageKey：筛选/排序切换分支时
                        // 保持滚动位置（两分支是不同控件树，靠 PageStorage 恢复）
                        key: const PageStorageKey('inbox-list'),
                        padding: const EdgeInsets.only(top: 4),
                        itemCount: list.length,
                        // onReorderItem 已按移除语义调整 newIndex，无需手动 -1
                        onReorderItem: (oldI, newI) =>
                            _onReorder(list, oldI, newI),
                        // 轻量拖拽替身：低阴影 + 卡片同款圆角，替代默认
                        // elevation 6 阴影动画——长列表拖拽时每帧重绘阴影
                        // 是掉帧主因之一
                        proxyDecorator: _dragProxy,
                        itemBuilder: (context, i) => _tile(list[i]),
                      )
                    : ListView.builder(
                        key: const PageStorageKey('inbox-list'),
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.only(top: 4),
                        itemCount: list.length,
                        itemBuilder: (context, i) => _tile(list[i]),
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar:
          selecting ? selectionBar(widget.model.query(_q)) : null,
    );
  }

  /// 拖拽替身：Material elevation 3（默认 6 的阴影每帧重绘明显更贵），
  /// 圆角与 TodoTile 卡片一致，避免拖起时露出直角。
  Widget _dragProxy(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Material(
        elevation: Curves.easeOut.transform(animation.value) * 3,
        color: Colors.transparent,
        shadowColor: Colors.black,
        borderRadius: BorderRadius.circular(16),
        child: child,
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

  /// 拖拽写回：将当前视图完整 ID 顺序存入 customOrder[index/all]，
  /// 由 AppModel 过滤不存在 ID 并保留回收站 ID 后原子落盘。
  Future<void> _onReorder(List<Todo> list, int oldI, int newI) async {
    final ids = list.map((t) => t.id).toList();
    final moved = ids.removeAt(oldI);
    ids.insert(newI, moved);
    final viewKey = _q.view == TodoView.all ? 'all' : 'inbox';
    await widget.model.saveCustomOrder(viewKey, ids);
  }

  void _openFilterSheet() {    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _FilterSheet(
        model: widget.model,
        query: _q,
        onChanged: () => setState(() {}),
        // “清除筛选”同时清搜索词：同步清空搜索框，保证按钮语义完整
        onResetSearch: () {
          _searchDebounce?.cancel();
          _searchCtrl.clear();
          _q.search = null;
          setState(() {});
        },
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final AppModel model;
  final TodoQuery query;
  final VoidCallback onChanged;
  final VoidCallback? onResetSearch;
  const _FilterSheet({required this.model, required this.query, required this.onChanged, this.onResetSearch});

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
                  q.tagMode = TagFilterMode.and;
                  q.priorities = {};
                  q.categoryIds = null;
                  q.uncategorized = false;
                  q.dueFrom = null;
                  q.dueTo = null;
                  q.defaultSort = true;
                  if (q.search != null && q.search!.isNotEmpty) {
                    q.search = null;
                    widget.onResetSearch?.call();
                  }
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
            Text(
                switch (q.tagMode) {
                  TagFilterMode.and => '标签（全部包含）',
                  TagFilterMode.or => '标签（任一包含）',
                  TagFilterMode.exclude => '标签（均不包含）',
                },
                style: _labelStyle(a)),
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
            // 标签筛选模式（桌面 TagFilterMode）：未选标签时禁用
            Wrap(
              spacing: 8,
              children: [
                for (final mode in TagFilterMode.values)
                  ChoiceChip(
                    label: Text(switch (mode) {
                      TagFilterMode.and => '全部包含',
                      TagFilterMode.or => '任一包含',
                      TagFilterMode.exclude => '均不包含',
                    }),
                    selected: q.tagMode == mode,
                    onSelected: (q.tagNames?.isEmpty ?? true)
                        ? null
                        : (sel) => setState(() => q.tagMode = mode),
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
