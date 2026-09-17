/// index.json 跨端序列化兼容（对齐桌面 normalize_json_payload 协议）：
/// - 规范形态 = 递归字典序 + 2 空格缩进（serde_json Value/BTreeMap 同构）；
/// - lastScanAt 仅本机扫描时间，不进入哈希/推送形态；
/// - customOrder 为空时整个键省略（桌面 TipIndex Option 语义）；
/// - 墓碑时间戳保留 RFC3339 原文（纳秒精度不截断），projectId 恒写。
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:tasktips/infra/store.dart';

/// 桌面端推送的 index 规范形态样例（键已按字典序排列）。
const _desktopCanonical = '''
{
  "customOrder": {
    "inbox": [
      "01J5MZ6K6AC2F4Y17D8Q1T8PX0",
      "01J5MZ6K6AC2F4Y17D8Q1T8PX1"
    ]
  },
  "schemaVersion": 1,
  "tombstones": [
    {
      "deletedAt": "2026-09-01T08:00:00.123456789Z",
      "deviceId": "desktop-dev",
      "id": "01AAAAAAAAAAAAAAAAAAAAAAAA",
      "kind": "todo",
      "projectId": "local",
      "revision": 3
    },
    {
      "baseRevision": 2,
      "deletedAt": "2026-09-02T09:30:00Z",
      "deviceId": "desktop-dev",
      "id": "01BBBBBBBBBBBBBBBBBBBBBBBB",
      "kind": "image",
      "projectId": "local",
      "revision": 4
    }
  ]
}''';

Future<(Directory, TodoStore)> _store() async {
  final dir = await Directory.systemTemp.createTemp('tt_idxcompat');
  final store = TodoStore(dir);
  await store.init();
  return (dir, store);
}

void main() {
  test('canonicalJson：递归按 key 字典序排列', () {
    final out = canonicalJson({
      'tombstones': [
        {'id': 'b', 'kind': 'todo', 'revision': 1}
      ],
      'schemaVersion': 1,
      'customOrder': {'inbox': ['x']},
    });
    expect(out, startsWith('{\n  "customOrder":'));
    expect(out, contains('\n  "schemaVersion": 1,\n  "tombstones": ['));
    // 墓碑对象内同样字典序：id < kind < revision
    expect(out, contains('"id": "b",\n      "kind": "todo",\n      "revision": 1'));
  });

  test('桌面规范形态：读入后未修改再保存逐字节等价', () async {
    final (_, store) = await _store();
    final idx = store.indexFromRawJson(_desktopCanonical);
    await store.saveIndex(idx);
    expect(await store.indexFile.readAsString(), _desktopCanonical);
  });

  test('推送形态不含 lastScanAt（桌面 normalize 同规则）', () async {
    final (_, store) = await _store();
    // 带本机扫描时间的文件（桌面 typed save 会写 null/时间）
    final withScan = '{"lastScanAt":"2026-09-16T01:02:03Z","schemaVersion":1,"tombstones":[]}';
    final idx = store.indexFromRawJson(withScan);
    final pushed = store.indexJson(idx);
    expect(pushed.contains('lastScanAt'), isFalse);
    // 空墓碑列表仍写出（桌面 Vec 无 skip）
    expect(pushed, contains('"tombstones": []'));
  });

  test('空 customOrder 整键省略；非空保留 inbox/all', () async {
    final (_, store) = await _store();
    final empty = store.indexJson(IndexData.empty());
    expect(empty.contains('customOrder'), isFalse);

    final idx = IndexData(1, {
      'inbox': ['01A'],
    }, []);
    expect(store.indexJson(idx),
        '{\n  "customOrder": {\n    "inbox": [\n      "01A"\n    ]\n  },\n  "schemaVersion": 1,\n  "tombstones": []\n}');
  });

  test('墓碑时间戳原文保留：纳秒精度不截断', () async {
    final (_, store) = await _store();
    final idx = store.indexFromRawJson(_desktopCanonical);
    expect(idx.tombstones.first.deletedAt, '2026-09-01T08:00:00.123456789Z');
    expect(idx.tombstones.first.projectId, 'local');
    expect(idx.tombstones[1].baseRevision, 2);
    final roundTrip = store.indexJson(idx);
    expect(roundTrip.contains('2026-09-01T08:00:00.123456789Z'), isTrue);
    expect(roundTrip.contains('"baseRevision": 2'), isTrue);
  });

  test('旧移动端格式读入：缺 projectId 补默认、空 customOrder 归一省略', () async {
    final (_, store) = await _store();
    const legacy =
        '{"schemaVersion":1,"customOrder":{},"tombstones":[{"id":"01C","kind":"todo","deletedAt":"2026-08-01T00:00:00.000Z","revision":2,"deviceId":"m"}],"lastScanAt":null}';
    final idx = store.indexFromRawJson(legacy);
    expect(idx.tombstones.single.projectId, 'local');
    expect(idx.tombstones.single.deletedAt, '2026-08-01T00:00:00.000Z');
    final out = store.indexJson(idx);
    expect(out.contains('customOrder'), isFalse);
    expect(out.contains('lastScanAt'), isFalse);
    expect(out.contains('"projectId": "local"'), isTrue);
  });

  test('customOrder 未知视图键丢弃（桌面 typed 解析同语义）', () {
    final idx = IndexData.fromJson({
      'schemaVersion': 1,
      'customOrder': {
        'inbox': ['01A'],
        'someday': ['01B'],
      },
      'tombstones': [],
    });
    expect(idx.customOrder.keys, ['inbox']);
  });

  test('损坏墓碑（缺 deletedAt）按解析失败处理', () {
    expect(() {
      IndexData.fromJson({
        'schemaVersion': 1,
        'tombstones': [
          {'id': '01D', 'kind': 'todo', 'revision': 1, 'deviceId': 'x'}
        ],
      });
    }, throwsFormatException);
  });

  test('本机新建墓碑形态与桌面一致（含 projectId，无 baseRevision）', () async {
    final ts = Tombstone('01E', 'todo', '2026-09-17T00:00:00Z', 2, 'dev-m');
    final encoded = canonicalJson({
      'schemaVersion': 1,
      'tombstones': [ts.toJson()],
    });
    final decoded = jsonDecode(encoded) as Map<String, Object?>;
    final tsJson = (decoded['tombstones'] as List).single as Map<String, Object?>;
    expect(tsJson['projectId'], 'local');
    expect(tsJson.containsKey('baseRevision'), isFalse);
    expect(tsJson['deletedAt'], '2026-09-17T00:00:00Z');
  });
}
