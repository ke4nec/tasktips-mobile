import 'package:flutter_test/flutter_test.dart';

import 'package:tasktips/sync/session.dart';
import 'package:tasktips/sync/sync_state.dart';

void main() {
  group('服务端地址校验', () {
    test('HTTPS 合法', () {
      expect(validateServerUrl('https://sync.example.com'), isNull);
      expect(validateServerUrl('https://sync.example.com:8443'), isNull);
    });
    test('拒绝 HTTP、凭据、查询与片段', () {
      expect(validateServerUrl('http://sync.example.com'), isNotNull);
      expect(validateServerUrl('https://u:p@sync.example.com'), isNotNull);
      expect(validateServerUrl('https://sync.example.com?x=1'), isNotNull);
      expect(validateServerUrl('https://sync.example.com#f'), isNotNull);
      expect(validateServerUrl(''), isNotNull);
    });
    test('规范化保留端口去路径', () {
      expect(normalizeServerUrl('https://a.b.com:8443'), 'https://a.b.com:8443');
      expect(normalizeServerUrl('https://a.b.com'), 'https://a.b.com');
    });
  });

  group('同步状态持久化往返', () {
    test('基线/待提交请求/冲突/日志往返', () {
      final d = SyncStateData()
        ..serverUrl = 'https://s.example.com'
        ..accountId = 'acc-1'
        ..projectId = 'p-1'
        ..generation = 3
        ..pullCursor = 'cursor-abc'
        ..autoSync = true
        ..bootstrapped = true;
      d.baselines[d.baselineKey('todo', '01A')] =
          ObjectBaseline('todo', '01A', 5, 'h1');
      d.pendingPush = PendingPush('req-1', 3, [
        {'kind': 'todo', 'id': '01A', 'revision': 6}
      ], []);
      d.conflicts
          .add(ConflictRecord('todo', '01B', 2, 3, 'hash2'));
      d.addLog(SyncLogEntry(DateTime.utc(2026, 9, 16), 'upload', 2, 'ok'));
      d.addLog(
          SyncLogEntry(DateTime.utc(2026, 9, 16), 'download', 1, 'error', 'HTTP_500'));

      final raw = SyncStateStore('').save(d);
      final back = SyncStateStore('').load(raw);

      expect(back.serverUrl, d.serverUrl);
      expect(back.projectId, 'p-1');
      expect(back.pullCursor, 'cursor-abc');
      expect(back.baselines['todo/01A']!.revision, 5);
      expect(back.pendingPush!.requestId, 'req-1');
      expect(back.pendingPush!.objects.single['revision'], 6);
      expect(back.conflicts.single.remoteRevision, 3);
      expect(back.logs.length, 2);
      expect(back.logs.first.result, 'error');
      expect(back.logs.first.errorCode, 'HTTP_500');
      expect(back.autoSync, isTrue);
    });

    test('日志上限 200 条', () {
      final d = SyncStateData();
      for (var i = 0; i < 250; i++) {
        d.addLog(SyncLogEntry(DateTime.utc(2026), 'upload', 1, 'ok'));
      }
      expect(d.logs.length, 200);
    });
  });
}
