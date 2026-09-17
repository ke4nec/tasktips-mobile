/// 列表查询：视图、搜索、筛选与排序，规则见 tasktips-mobile-design.md §3。
library;

import 'todo.dart';

enum TodoView { inbox, today, upcoming, completed, all }

enum SortKey { updatedAt, createdAt, dueDate, priority, title }

enum SortOrder { asc, desc }

/// 标签筛选模式（桌面 domain/query.rs TagFilterMode）：
/// and=全部命中、or=任一命中、exclude=均不包含；标签为空时恒命中。
enum TagFilterMode { and, or, exclude }

class TodoQuery {
  TodoView view;
  String? search; // 标题、正文纯文本、标签，大小写不敏感
  List<String>? tagNames;
  TagFilterMode tagMode; // 仅内存查询态，不落盘、不进同步对象
  Set<int> priorities; // 多选取并集；空集不限
  List<String>? categoryIds; // 命中任一，含子目录（调用方展开）
  bool uncategorized;
  LocalDate? dueFrom;
  LocalDate? dueTo;
  SortKey sortKey;
  SortOrder sortOrder;
  bool defaultSort; // true 时忽略 sortKey/sortOrder 使用默认排序

  TodoQuery({
    this.view = TodoView.inbox,
    this.search,
    this.tagNames,
    this.tagMode = TagFilterMode.and,
    this.priorities = const {},
    this.categoryIds,
    this.uncategorized = false,
    this.dueFrom,
    this.dueTo,
    this.sortKey = SortKey.updatedAt,
    this.sortOrder = SortOrder.desc,
    this.defaultSort = true,
  });

  bool get hasActiveFilter =>
      (search != null && search!.isNotEmpty) ||
      (tagNames != null && tagNames!.isNotEmpty) ||
      priorities.isNotEmpty ||
      (categoryIds != null && categoryIds!.isNotEmpty) ||
      uncategorized ||
      dueFrom != null ||
      dueTo != null ||
      !defaultSort;
}

bool _matchesView(Todo t, TodoView view, String today) {
  switch (view) {
    case TodoView.inbox:
      return t.status == TodoStatus.open && !t.isDeleted;
    case TodoView.today:
      return t.status == TodoStatus.open &&
          !t.isDeleted &&
          t.dueDate != null &&
          t.dueDate!.compareTo(today) <= 0;
    case TodoView.upcoming:
      return t.status == TodoStatus.open &&
          !t.isDeleted &&
          t.dueDate != null &&
          t.dueDate!.compareTo(today) > 0;
    case TodoView.completed:
      return t.status == TodoStatus.completed && !t.isDeleted;
    case TodoView.all:
      return !t.isDeleted;
  }
}

final _markerRe = RegExp(r'[#*_`~>\[\]()!|-]');

/// Markdown 纯文本化（供搜索匹配）：与桌面端 `plain_text` 语义一致——
/// 围栏标记行丢弃，围栏内代码内容保留可搜；围栏外剥离行内标记。
String _stripToPlainText(String md) {
  final buf = <String>[];
  var inFence = false;
  for (final rawLine in md.split('\n')) {
    final trimmed = rawLine.trim();
    if (trimmed.startsWith('```') || trimmed.startsWith('~~~')) {
      inFence = !inFence;
      continue;
    }
    buf.add(inFence ? rawLine : rawLine.replaceAll(_markerRe, ' '));
  }
  return buf.join(' ');
}

/// 过滤 + 排序。today 由调用方传入以便测试跨日场景。
/// [activeCategoryIds] 为当前未删除目录 ID 集：categoryId 指向不存在或
/// 已删除目录的 Todo 按"未分类"口径参与筛选与计数。
List<Todo> runQuery(
  List<Todo> todos,
  TodoQuery q, {
  required String today,
  Set<String>? includeOnly, // 测试/详情跳转用
  Set<String>? activeCategoryIds,
  Map<String, List<String>>? customOrder, // 桌面端同步来的 Inbox/All 自定义顺序
}) {
  bool uncategorized(Todo t) =>
      t.categoryId == null ||
      t.categoryId!.isEmpty ||
      (activeCategoryIds != null && !activeCategoryIds.contains(t.categoryId));
  final search = q.search?.trim().toLowerCase();
  Iterable<Todo> it = todos.where((t) => _matchesView(t, q.view, today));
  if (includeOnly != null) it = it.where((t) => includeOnly.contains(t.id));
  if (search != null && search.isNotEmpty) {
    it = it.where((t) =>
        t.title.toLowerCase().contains(search) ||
        _stripToPlainText(t.body).toLowerCase().contains(search) ||
        t.tags.any((tag) => tag.toLowerCase().contains(search)));
  }
  if (q.tagNames != null && q.tagNames!.isNotEmpty) {
    // Unicode 小写折叠（与桌面 name_key 语义一致）
    final lower = q.tagNames!.map((e) => e.toLowerCase()).toSet();
    bool match(Todo t) {
      final own = t.tags.map((e) => e.toLowerCase()).toSet();
      return switch (q.tagMode) {
        TagFilterMode.and => lower.every(own.contains),
        TagFilterMode.or => lower.any(own.contains),
        TagFilterMode.exclude => !lower.any(own.contains),
      };
    }

    it = it.where(match);
  }
  if (q.priorities.isNotEmpty) {
    it = it.where((t) => q.priorities.contains(t.priority));
  }
  // 目录筛选（桌面 matches_categories 语义）：命中 ID 任一，或（勾选未分类时）
  // 无目录（categoryId 为空/指向已删或不存在目录）——两者取并集，单谓词一次判定。
  if ((q.categoryIds != null && q.categoryIds!.isNotEmpty) ||
      q.uncategorized) {
    it = it.where((t) {
      final cat = uncategorized(t) ? null : t.categoryId;
      final inIds = cat != null &&
          q.categoryIds != null &&
          q.categoryIds!.contains(cat);
      if (q.uncategorized) return inIds || cat == null;
      return inIds;
    });
  }
  if (q.dueFrom != null) {
    it = it.where((t) => t.dueDate != null && t.dueDate!.compareTo(q.dueFrom!) >= 0);
  }
  if (q.dueTo != null) {
    it = it.where((t) => t.dueDate != null && t.dueDate!.compareTo(q.dueTo!) <= 0);
  }
  final list = it.toList();

  int cmpDateAsc(String? a, String? b) {
    // 截止日期升序时无日期排最后
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return a.compareTo(b);
  }

  if (q.defaultSort) {
    const p = TodoStatus.open;
    list.sort((a, b) {
      final aOpen = a.status == p, bOpen = b.status == p;
      if (aOpen != bOpen) return aOpen ? -1 : 1;
      if (aOpen) {
        final aOver = a.isOverdueWith(today), bOver = b.isOverdueWith(today);
        if (aOver != bOver) return aOver ? -1 : 1;
      }
      if (a.priority != b.priority) return b.priority - a.priority;
      final d = cmpDateAsc(a.dueDate, b.dueDate);
      if (d != 0) return d;
      return b.updatedAt.compareTo(a.updatedAt);
    });
  } else {
    int mul = q.sortOrder == SortOrder.asc ? 1 : -1;
    list.sort((a, b) {
      late int d;
      switch (q.sortKey) {
        case SortKey.updatedAt:
          d = a.updatedAt.compareTo(b.updatedAt);
        case SortKey.createdAt:
          d = a.createdAt.compareTo(b.createdAt);
        case SortKey.dueDate:
          d = cmpDateAsc(a.dueDate, b.dueDate) * (q.sortOrder == SortOrder.asc ? 1 : -1);
          if (d != 0) return d;
          return 0;
        case SortKey.priority:
          d = a.priority - b.priority;
        case SortKey.title:
          d = a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
      return d * mul;
    });
  }
  // 已同步的 Inbox/All 自定义顺序：默认排序且无筛选/搜索时生效，
  // 数组内 ID 按数组相对顺序排前（优先于过期/优先级等默认键），其余按默认规则追加
  if (q.defaultSort && !q.hasActiveFilter) {
    final key = switch (q.view) {
      TodoView.inbox => 'inbox',
      TodoView.all => 'all',
      _ => null,
    };
    final order = key == null ? null : customOrder?[key];
    if (order != null && order.isNotEmpty) {
      final rank = <String, int>{
        for (var i = 0; i < order.length; i++) order[i]: i
      };
      final pinned = <Todo>[];
      final rest = <Todo>[];
      for (final t in list) {
        (rank.containsKey(t.id) ? pinned : rest).add(t);
      }
      pinned.sort((a, b) => rank[a.id]!.compareTo(rank[b.id]!));
      return [...pinned, ...rest];
    }
  }
  return list;
}

extension on Todo {
  bool isOverdueWith(String today) =>
      status == TodoStatus.open && dueDate != null && dueDate!.compareTo(today) < 0;
}
