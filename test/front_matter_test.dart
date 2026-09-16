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

  test('deriveTitle 兼容样例', () {
    expect(deriveTitle('#  标题'), '标题');
    expect(deriveTitle('- [ ] 买菜'), '买菜');
    expect(derivePathological(), '🙂🙂🙂 Emoji 标题');
  });
}

String derivePathological() => deriveTitle('🙂🙂🙂 Emoji 标题');
