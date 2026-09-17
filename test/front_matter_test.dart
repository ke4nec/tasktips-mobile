import 'package:flutter_test/flutter_test.dart';

import 'package:tasktips/domain/todo.dart';
import 'package:tasktips/infra/markdown_doc.dart';

void main() {
  test('往返保留未知 front matter 字段', () {
    const src = '---\n'
        'schemaVersion: 1\n'
        'id: 01TEST\n'
        'title: 标题\n'
        'status: open\n'
        'priority: 2\n'
        'tags:\n'
        '  - work\n'
        'dueDate: 2026-09-16\n'
        'categoryId: null\n'
        'deletedAt: null\n'
        'createdAt: 2026-08-18T01:00:00Z\n'
        'updatedAt: 2026-08-18T01:10:00Z\n'
        'completedAt: null\n'
        'revision: 3\n'
        'deviceId: dev-1\n'
        'customField: keep-me\n'
        '---\n\n'
        '## 今日任务\n\n- [ ] 完善编辑窗口\n';
    final parsed = parseTodoDoc(src);
    final t = todoFromFields(parsed.fields, parsed.body);
    expect(t.extraFrontMatter['customField'], 'keep-me');
    final out = serializeTodoDoc(t);
    final reparsed = parseTodoDoc(out);
    final t2 = todoFromFields(reparsed.fields, reparsed.body);
    expect(t2.extraFrontMatter['customField'], 'keep-me');
    expect(t2.body, t.body);
    expect(t2.tags, ['work']);
    expect(t2.dueDate, '2026-09-16');
    expect(t2.revision, 3);
  });

  test('兼容 CRLF 读取', () {
    const src = '---\r\n'
        'schemaVersion: 1\r\n'
        'id: 01TEST\r\n'
        'title: t\r\n'
        'status: open\r\n'
        'priority: 0\r\n'
        'createdAt: 2026-08-18T01:00:00Z\r\n'
        'updatedAt: 2026-08-18T01:00:00Z\r\n'
        'revision: 1\r\n'
        'deviceId: dev\r\n'
        '---\r\n\r\n正文\r\n';
    final parsed = parseTodoDoc(src);
    final t = todoFromFields(parsed.fields, parsed.body);
    expect(t.body, '正文\n');
    expect(serializeTodoDoc(t).contains('\r'), isFalse);
  });

  test('孤立 \\r 归一为换行', () {
    const src = '---\nschemaVersion: 1\nid: 01TEST\ntitle: t\nstatus: open\n'
        'priority: 0\ncreatedAt: 2026-08-18T01:00:00Z\n'
        'updatedAt: 2026-08-18T01:00:00Z\nrevision: 1\ndeviceId: dev\n---\n\n第一行\r第二行\n';
    final parsed = parseTodoDoc(src);
    expect(parsed.body, '第一行\n第二行\n');
  });

  test('缺少 front matter 抛异常', () {
    expect(() => parseTodoDoc('只是正文'),
        throwsA(isA<FrontMatterException>()));
  });

  test('不支持的 schemaVersion 抛异常', () {
    const src = '---\nschemaVersion: 2\nid: x\ntitle: t\nstatus: open\n'
        'priority: 0\ncreatedAt: 2026-08-18T01:00:00Z\n'
        'updatedAt: 2026-08-18T01:00:00Z\nrevision: 1\ndeviceId: d\n---\n\nb\n';
    final parsed = parseTodoDoc(src);
    expect(() => todoFromFields(parsed.fields, parsed.body),
        throwsA(isA<FrontMatterException>()));
  });

  test('priority 越界与非 int 类型拒绝为 FrontMatterException', () {
    Map<String, Object?> fields(Object? priority) => {
          'schemaVersion': 1,
          'id': 'x',
          'title': 't',
          'status': 'open',
          'priority': priority,
          'createdAt': '2026-08-18T01:00:00Z',
          'updatedAt': '2026-08-18T01:00:00Z',
          'revision': 1,
          'deviceId': 'd',
        };
    for (final bad in [-1, 4, 9, '2', 2.0, true]) {
      expect(() => todoFromFields(fields(bad), 'b'),
          throwsA(isA<FrontMatterException>()), reason: 'priority=$bad');
    }
    // 缺省与合法值通过
    expect(todoFromFields(fields(null), 'b').priority, 0);
    expect(todoFromFields(fields(3), 'b').priority, 3);
  });

  test('结束标记按行判定：---xyz 不视为结束，行尾空格容忍', () {
    // `---xyz` 行若被误判为结束标记，YAML 切片错位；应整体解析失败
    const bad = '---\nschemaVersion: 1\n---xyz\nid: x\n---\n\nb\n';
    expect(() => parseTodoDoc(bad), throwsA(isA<FrontMatterException>()));
    // 结束标记行尾空格容忍
    const spaced = '---\nschemaVersion: 1\nid: x\ntitle: t\nstatus: open\n'
        'priority: 0\ncreatedAt: 2026-08-18T01:00:00Z\n'
        'updatedAt: 2026-08-18T01:00:00Z\nrevision: 1\ndeviceId: d\n---  \n\nb\n';
    final parsed = parseTodoDoc(spaced);
    expect(todoFromFields(parsed.fields, parsed.body).id, 'x');
  });

  test('deriveTitle 兼容样例', () {
    expect(deriveTitle('#  标题'), '标题');
    expect(deriveTitle('- [ ] 买菜'), '买菜');
    expect(derivePathological(), '🙂🙂🙂 Emoji 标题');
  });
}

String derivePathological() => deriveTitle('🙂🙂🙂 Emoji 标题');
