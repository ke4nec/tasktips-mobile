/// 列表查询：视图、搜索、筛选与排序，规则见 tasktips-mobile-design.md §3。
library;

import 'todo.dart';

enum TodoView { inbox, today, upcoming, completed, all }

enum SortKey { updatedAt, createdAt, dueDate, priority, title }

enum SortOrder { asc, desc }

class TodoQuery {
  TodoView view;
  String? search; // 标题、正文纯文本、标签，大小写不敏感
  List<String>? tagNames; // 全部匹配（AND）
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

final _codeBlockRe = RegExp(r'```[\s\S]*?```');
final _markerRe = RegExp(r'[#*_`~>\[\]()!|-]');

String _stripToPlainText(String md) =>
    md.replaceAll(_codeBlockRe, ' ').replaceAll(_markerRe, ' ');

/// 过滤 + 排序。today 由调用方传入以便测试跨日场景。
List<Todo> runQuery(
  List<Todo> todos,
  TodoQuery q, {
  required String today,
  Set<String>? includeOnly, // 测试/详情跳转用
}) {
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
    final lower = q.tagNames!.map((e) => e.toLowerCase()).toSet();
    it = it.where((t) {
      final own = t.tags.map((e) => e.toLowerCase()).toSet();
      return lower.every(own.contains);
    });
  }
  if (q.priorities.isNotEmpty) {
    it = it.where((t) => q.priorities.contains(t.priority));
  }
  if (q.categoryIds != null && q.categoryIds!.isNotEmpty) {
    it = it.where((t) => t.categoryId == null
        ? false
        : q.categoryIds!.contains(t.categoryId));
  }
  if (q.uncategorized) {
    it = it.where((t) => t.categoryId == null || t.categoryId!.isEmpty);
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
  return list;
}

extension on Todo {
  bool isOverdueWith(String today) =>
      status == TodoStatus.open && dueDate != null && dueDate!.compareTo(today) < 0;
}
