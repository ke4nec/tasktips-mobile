import 'package:flutter_test/flutter_test.dart';

import 'package:tasktips/domain/query.dart';
import 'package:tasktips/domain/todo.dart';

Todo _t(
  String id, {
  String title = '',
  String body = '',
  TodoStatus status = TodoStatus.open,
  int priority = 0,
  List<String> tags = const [],
  String? due,
  DateTime? updated,
}) =>
    Todo(
      id: id,
      title: title,
      body: body,
      status: status,
      priority: priority,
      tags: tags,
      dueDate: due,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: updated ?? DateTime(2026, 1, 1),
      deviceId: 'dev',
    );

void main() {
  const today = '2026-09-16';
  final todos = [
    _t('a', title: '过期高优', due: '2026-09-15', priority: 3),
    _t('b', title: '今天中优', due: today, priority: 2),
    _t('c', title: '未来低优', due: '2026-09-20', priority: 1),
    _t('d', title: '无日期', priority: 0),
    _t('e', title: '已完成', due: today, status: TodoStatus.completed),
  ];

  test('今日视图 = 未完成且 dueDate <= today', () {
    final r = runQuery(todos, TodoQuery(view: TodoView.today), today: today);
    expect(r.map((t) => t.id).toList(), ['a', 'b']);
  });

  test('即将到期 = 未完成且日期在今天之后', () {
    final r = runQuery(todos, TodoQuery(view: TodoView.upcoming), today: today);
    expect(r.map((t) => t.id).toList(), ['c']);
  });

  test('默认排序：未完成在前、过期在前、优先级降序、日期升序', () {
    final r = runQuery(todos, TodoQuery(view: TodoView.all), today: today);
    expect(r.first.id, 'a');
    expect(r.last.id, 'e');
  });

  test('截止日期升序时无日期排最后', () {
    final r = runQuery(
        todos,
        TodoQuery(
            view: TodoView.all,
            sortKey: SortKey.dueDate,
            sortOrder: SortOrder.asc,
            defaultSort: false),
        today: today);
    expect(r.last.id, 'd');
  });

  test('搜索大小写不敏感覆盖标题/正文/标签', () {
    final list = [
      _t('x', title: 'Buy Coffee', body: 'notes'),
      _t('y', title: 'other', body: 'buy later'),
      _t('z', title: 'zz', tags: ['BUY-LIST']),
    ];
    final r = runQuery(
        list, TodoQuery(view: TodoView.inbox, search: 'buy'),
        today: today);
    expect(r.map((t) => t.id).toSet(), {'x', 'y', 'z'});
  });

  test('多标签全部匹配（AND）', () {
    final list = [
      _t('a1', tags: ['work', 'urgent']),
      _t('a2', tags: ['work']),
    ];
    final r = runQuery(
        list, TodoQuery(view: TodoView.inbox, tagNames: ['work', 'urgent']),
        today: today);
    expect(r.map((t) => t.id).toList(), ['a1']);
  });

  test('优先级筛选取并集', () {
    final r = runQuery(todos,
        TodoQuery(view: TodoView.inbox, priorities: {1, 2}),
        today: today);
    expect(r.map((t) => t.id).toSet(), {'b', 'c'});
  });
}
