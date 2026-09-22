import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_of/one_of.dart';
import 'package:tasktips_api/tasktips_api.dart' as api;
import 'package:tasktips/app/app_model.dart';
import 'package:tasktips/infra/store.dart';
import 'package:tasktips/infra/backup.dart';
import 'package:tasktips/infra/markdown_doc.dart';
import 'package:tasktips/sync/session.dart';
import 'package:tasktips/sync/sync_engine.dart';
import 'package:tasktips/sync/sync_state.dart';

import 'sync_engine_test.dart' show FakeSecureStorage, StubServer;

Future<(AppModel, SyncEngine, StubServer)> setup() async {
  final dir = await Directory.systemTemp.createTemp('tt_review_');
  addTearDown(() => dir.delete(recursive: true));
  final model = AppModel(TodoStore(dir));
  await model.load();
  final stub = StubServer();
  final engine = SyncEngine(
    model,
    SyncSession(FakeSecureStorage()),
    httpClient: stub.build(),
  );
  engine.state.serverUrl = 'https://sync.test';
  engine.state.projectId = 'p1';
  stub.onPush = () => accepted(stub.lastPushBody!);
  return (model, engine, stub);
}

void cleanMeta(SyncEngine e) {
  for (final kind in ['classification', 'index']) {
    e.state.baselines[e.state.baselineKey(kind, kind)] = ObjectBaseline(
      kind,
      kind,
      1,
      kind == 'classification' ? e.classificationHash() : e.indexHash(),
    );
  }
}

api.SyncChange change(String kind, String id, int revision, String hash) =>
    api.SyncChange(
      (b) => b.oneOf = OneOfDynamic(
        typeIndex: 0,
        types: [api.SyncObjectChange, api.SyncTombstoneChange],
        value: api.SyncObjectChange(
          (c) => c
            ..type = JsonObject('object')
            ..kind = api.ObjectKind.valueOf(kind)
            ..id = id
            ..schemaVersion = 1
            ..revision = revision
            ..contentHash = hash
            ..updatedAt = DateTime.utc(2026)
            ..deviceId = 'remote'
            ..changeSequence = 1,
        ),
      ),
    );

api.PushResponse accepted(Map<String, Object?> body) => api.PushResponse(
  (b) => b
    ..generation = 1
    ..results = ListBuilder([
      for (final item in [
        ...body['objects'] as List,
        ...body['tombstones'] as List,
      ])
        api.PushItemResult(
          (r) => r.oneOf = OneOfDynamic(
            typeIndex: 0,
            types: [
              api.PushAppliedResult,
              api.PushConflictResult,
              api.PushRejectedResult,
            ],
            value: api.PushAppliedResult(
              (a) => a
                ..status = JsonObject('applied')
                ..kind = api.ObjectKind.valueOf(item['kind'])
                ..id = item['id']
                ..revision = item['revision']
                ..changeSequence = 1
                ..changedAt = DateTime.utc(2026),
            ),
          ),
        ),
    ]),
);

void main() {
  test('首次上传的信封版本遵守服务端 CAS 契约', () async {
    final (m, e, s) = await setup();
    final t = await m.createTodo();
    await m.writeTodo(t.copyWith(body: 'new todo with content'));
    cleanMeta(e);
    await e.pushDirty();
    final objects = s.lastPushBody!['objects'] as List;
    final sent = objects.single as Map;
    expect(
      sent['revision'],
      (sent['baseRevision'] as int? ?? 0) + 1,
      reason: '服务端要求 revision 等于 baseRevision + 1',
    );
  });

  test('分类和索引上传使用 JSON 媒体类型', () async {
    final dir = await Directory.systemTemp.createTemp('tt_review_mime_');
    addTearDown(() => dir.delete(recursive: true));
    final m = AppModel(TodoStore(dir));
    await m.load();
    final dio = Dio();
    final uploadedTypes = <String?>[];
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) {
          if (o.method == 'HEAD') {
            h.reject(
              DioException(
                requestOptions: o,
                type: DioExceptionType.badResponse,
                response: Response(requestOptions: o, statusCode: 404),
              ),
            );
          } else if (o.method == 'PUT') {
            uploadedTypes.add(o.contentType);
            h.resolve(Response(requestOptions: o, statusCode: 200));
          } else {
            h.resolve(
              Response(
                requestOptions: o,
                statusCode: 200,
                data: {'generation': 1, 'results': []},
              ),
            );
          }
        },
      ),
    );
    final e = SyncEngine(m, SyncSession(FakeSecureStorage()), httpClient: dio);
    e.state.serverUrl = 'https://sync.test';
    e.state.projectId = 'p1';
    await e.pushDirty();
    expect(uploadedTypes, [
      'application/json',
      'application/json',
    ], reason: '分类和索引必须使用 JSON 媒体类型');
  });

  test('并入项目时清除旧基线与游标', () async {
    final (_, e, _) = await setup();
    e.state.bootstrapped = true;
    e.state.pullCursor = 'p1-cursor';
    e.state.generation = 8;
    e.state.baselines[e.state.baselineKey('todo', 'a')] = ObjectBaseline(
      'todo',
      'a',
      5,
      'hash',
    );
    await e.beginProjectSwitch();
    await e.selectProject('p2');
    expect(
      e.state.bootstrapped,
      isFalse,
      reason: 'new project requires bootstrap',
    );
    expect(e.state.pullCursor, isNull);
    expect(e.state.baselines, isEmpty);
  });

  test('彻底删除已同步 Todo 必须上传墓碑', () async {
    final (m, e, s) = await setup();
    final t = await m.createTodo();
    await m.trashTodo(t.id);
    final deleted = m.byId(t.id)!;
    e.state.baselines[e.state.baselineKey('todo', t.id)] = ObjectBaseline(
      'todo',
      t.id,
      deleted.revision,
      e.sha256Of(e.todoBytes(deleted)),
    );
    cleanMeta(e);
    await m.purgeTodo(t.id);
    await e.pushDirty();
    expect(s.lastPushBody?['tombstones'], isNotEmpty);
    final sent = (s.lastPushBody!['tombstones'] as List).single;
    expect(sent['revision'], deleted.revision + 1);
    await e.pushDirty();
    expect(s.pushes, 1, reason: '已确认删除不应反复提交');
  });

  test('远端图片保持原始文件名', () async {
    final (m, e, _) = await setup();
    final bytes = Uint8List.fromList([0x89, 0x50, 0x4e, 0x47]);
    final hash = e.sha256Of(bytes);
    await e.debugApplyChange(
      change('image', '01IMAGE.png', 1, hash),
      prefetched: {hash: bytes},
    );
    expect(
      File('${m.store.imagesDir.path}/01IMAGE.png').existsSync(),
      isTrue,
      reason:
          'actual files: ${m.store.imagesDir.listSync().map((f) => f.path).toList()}',
    );
  });

  test('首次接入的同 ID 正文差异保留为冲突', () async {
    final (m, e, s) = await setup();
    final t = await m.createTodo();
    await m.writeTodo(t.copyWith(body: 'local edits'));
    final remote = t.copyWith(body: 'remote edits', revision: 3);
    final bytes = e.todoBytes(remote);
    final hash = e.sha256Of(bytes);
    s.onGetPayload = (_) => bytes;
    s.onBootstrap = () => api.BootstrapResponse(
      (b) => b
        ..generation = 1
        ..items = ListBuilder([change('todo', t.id, 3, hash)])
        ..hasMore = false
        ..cursor = 'c1',
    );
    await e.bootstrapAndApply();
    expect(m.byId(t.id)!.body, 'local edits');
    expect(e.state.conflicts, isNotEmpty);
  });

  test('保留本机后继续编辑仍可同步', () async {
    final (m, e, s) = await setup();
    final t = await m.createTodo();
    await m.writeTodo(t.copyWith(body: 'local'));
    cleanMeta(e);
    e.state.conflicts.add(ConflictRecord('todo', t.id, 2, 10, 'remote'));
    s.onPush = () => api.PushResponse(
      (b) => b
        ..generation = 1
        ..results = ListBuilder([
          api.PushItemResult(
            (r) => r.oneOf = OneOfDynamic(
              typeIndex: 0,
              types: [
                api.PushAppliedResult,
                api.PushConflictResult,
                api.PushRejectedResult,
              ],
              value: api.PushAppliedResult(
                (a) => a
                  ..status = JsonObject('applied')
                  ..kind = api.ObjectKind.todo
                  ..id = t.id
                  ..revision = 11
                  ..changeSequence = 1
                  ..changedAt = DateTime.utc(2026),
              ),
            ),
          ),
        ]),
    );
    await e.resolveKeepLocal('todo', t.id);
    await m.writeTodo(m.byId(t.id)!.copyWith(body: 'next edit'));
    expect(e.hasUnsyncedChanges, isTrue);
    s.onPush = () => accepted(s.lastPushBody!);
    await e.pushDirty();
    expect((s.lastPushBody!['objects'] as List).single['revision'], 12);
    expect(e.hasUnsyncedChanges, isFalse);
  });

  test('恢复旧备份将正文标为待同步', () async {
    final (m, e, _) = await setup();
    final t = await m.createTodo();
    await m.writeTodo(t.copyWith(body: 'backup contents'));
    final zip = '${m.store.root.path}/backup.zip';
    await exportBackup(m.store, zip, appVersion: '0.1.1');
    await m.writeTodo(m.byId(t.id)!.copyWith(body: 'newer synced contents'));
    final current = m.byId(t.id)!;
    e.state.baselines[e.state.baselineKey('todo', t.id)] = ObjectBaseline(
      'todo',
      t.id,
      current.revision,
      e.sha256Of(e.todoBytes(current)),
    );
    cleanMeta(e);
    await e.restoreBackup(zip);
    expect(m.byId(t.id)!.body, 'backup contents');
    expect(e.hasUnsyncedChanges, isTrue);
  });

  test('退出后丢弃迟到的 bootstrap 成功响应', () async {
    final dir = await Directory.systemTemp.createTemp('tt_review_epoch_');
    addTearDown(() => dir.delete(recursive: true));
    final m = AppModel(TodoStore(dir));
    await m.load();
    final started = Completer<void>();
    final gate = Completer<void>();
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) async {
          if (o.path.endsWith('/sync/bootstrap')) {
            started.complete();
            await gate.future;
            h.resolve(
              Response(
                requestOptions: o,
                statusCode: 200,
                data: {
                  'generation': 1,
                  'items': [],
                  'hasMore': false,
                  'cursor': 'old-project-cursor',
                },
              ),
            );
          } else {
            h.reject(DioException(requestOptions: o));
          }
        },
      ),
    );
    final e = SyncEngine(m, SyncSession(FakeSecureStorage()), httpClient: dio);
    e.state.serverUrl = 'https://sync.test';
    e.state.projectId = 'p1';
    final running = e.syncNow(manual: true);
    await started.future;
    await e.logout();
    gate.complete();
    await running;
    expect(e.state.bootstrapped, isFalse);
    expect(e.state.autoSync, isFalse);
    expect(e.state.pullCursor, isNull);
    final disk = SyncStateStore.load(
      await File('${m.store.stateDir.path}/sync-state.json').readAsString(),
    );
    expect(disk.bootstrapped, isFalse);
    expect(disk.pullCursor, isNull);
  });

  test('离线多次编辑按远端下一版本提交，确认后不重复上传', () async {
    final (m, e, s) = await setup();
    final t = await m.createTodo();
    cleanMeta(e);
    for (var i = 0; i < 5; i++) {
      await m.writeTodo(m.byId(t.id)!.copyWith(body: '编辑 $i'));
    }
    await e.pushDirty();
    expect((s.lastPushBody!['objects'] as List).single['revision'], 1);
    expect(e.hasUnsyncedChanges, isFalse);
    await e.pushDirty();
    expect(s.pushes, 1);
    await m.writeTodo(m.byId(t.id)!.copyWith(body: '再次编辑'));
    await e.pushDirty();
    expect((s.lastPushBody!['objects'] as List).single['revision'], 2);
    expect(e.hasUnsyncedChanges, isFalse);
  });

  test('上传 Markdown 的版本与信封一致，桌面读到的正文仍是最新快照', () async {
    final (m, e, s) = await setup();
    final t = await m.createTodo();
    cleanMeta(e);
    final payloads = <String, Uint8List>{};
    e.dio.interceptors.insert(
      0,
      InterceptorsWrapper(
        onRequest: (o, h) async {
          if (o.method == 'HEAD') {
            h.reject(
              DioException(
                requestOptions: o,
                type: DioExceptionType.badResponse,
                response: Response(requestOptions: o, statusCode: 404),
              ),
            );
          } else if (o.method == 'PUT') {
            expect(o.contentType, 'text/markdown');
            payloads[o.path.split('/').last] = Uint8List.fromList(
              await (o.data as Stream<List<int>>).fold<List<int>>(
                [],
                (a, b) => a..addAll(b),
              ),
            );
            h.resolve(Response(requestOptions: o, statusCode: 200));
          } else {
            h.next(o);
          }
        },
      ),
    );
    for (var i = 0; i < 5; i++) {
      await m.writeTodo(m.byId(t.id)!.copyWith(body: '最新正文 $i'));
    }
    Future<void> verifyPayload(int revision) async {
      final sent = (s.lastPushBody!['objects'] as List).single as Map;
      final bytes = payloads[sent['contentHash']]!;
      final parsed = parseTodoDoc(utf8.decode(bytes));
      expect(e.sha256Of(bytes), sent['contentHash']);
      expect(sent['revision'], revision);
      expect(parsed.fields['revision'], revision);
      expect(parsed.body, m.byId(t.id)!.body);
      expect(e.hasUnsyncedChanges, isFalse);
    }

    await e.pushDirty();
    await verifyPayload(1);
    final localRevision = m.byId(t.id)!.revision;
    expect(localRevision, greaterThan(1));
    e.state.conflicts.add(ConflictRecord('todo', t.id, 1, 10, 'remote'));
    await e.resolveKeepLocal('todo', t.id);
    await verifyPayload(11);
    expect(m.byId(t.id)!.revision, localRevision);
    await m.writeTodo(m.byId(t.id)!.copyWith(body: '解决冲突后再编辑'));
    await e.pushDirty();
    await verifyPayload(12);
    await e.pushDirty();
    expect(s.pushes, 3);
  });

  test('首次接入预览分类和排序冲突，确认前不覆盖或上传', () async {
    final (m, e, s) = await setup();
    await m.createCategory('本机目录');
    m.index.customOrder['inbox'] = ['local-id'];
    await m.store.saveIndex(m.index);
    m.indexVersion++;
    final cls = utf8.encode('{"schemaVersion":3,"categories":[],"tags":[]}');
    final idx = utf8.encode(m.store.indexJson(IndexData.empty()));
    final payloads = {e.sha256Of(cls): cls, e.sha256Of(idx): idx};
    s.onGetPayload = (h) => payloads[h]!;
    s.onBootstrap = () => api.BootstrapResponse(
      (b) => b
        ..generation = 1
        ..items = ListBuilder([
          change('classification', 'classification', 4, e.sha256Of(cls)),
          change('index', 'index', 3, e.sha256Of(idx)),
        ])
        ..hasMore = false
        ..cursor = 'c',
    );
    expect((await e.preview()).conflicts, 2);
    await e.bootstrapAndApply();
    expect(e.state.conflicts, hasLength(2));
    expect(m.rootCategories.single.name, '本机目录');
    expect(m.index.customOrder['inbox'], ['local-id']);
    await e.pushDirty();
    expect(s.pushes, 0);
    await e.resolveUseRemote('classification', 'classification');
    await e.resolveUseRemote('index', 'index');
    expect(m.rootCategories, isEmpty);
    expect(m.index.customOrder, isEmpty);
    expect(e.state.conflicts, isEmpty);
    expect(e.hasUnsyncedChanges, isFalse);
  });

  test('接收不同排版的远端正文后，重启不产生虚假本机修改', () async {
    final (m, e, s) = await setup();
    final t = await m.createTodo();
    final bytes = utf8.encode(
      utf8.decode(e.todoBytes(t)).replaceAll('\n', '\r\n'),
    );
    await m.store.deleteTodoFile(t.id);
    m.todos.clear();
    m.notifyListeners();
    cleanMeta(e);
    final hash = e.sha256Of(bytes);
    await e.debugApplyChange(
      change('todo', t.id, 8, hash),
      prefetched: {hash: bytes},
      notify: false,
    );
    await e.setAutoSync(false); // 持久化确认后的本机哈希
    await e.loadState();
    expect(e.hasUnsyncedChanges, isFalse);
    await e.pushDirty();
    expect(s.pushes, 0);
    await m.writeTodo(m.byId(t.id)!.copyWith(body: '恢复后编辑'));
    expect(e.hasUnsyncedChanges, isTrue);
  });

  test('恢复备份同时上传恢复正文和备份中缺失 Todo 的墓碑', () async {
    final (m, e, s) = await setup();
    final keep = await m.createTodo();
    await m.writeTodo(keep.copyWith(body: '备份正文'));
    final zip = '${m.store.root.path}/restore.zip';
    await exportBackup(m.store, zip, appVersion: '0.1.1');
    await m.writeTodo(m.byId(keep.id)!.copyWith(body: '最新正文'));
    final absent = await m.createTodo();
    await e.pushDirty();
    await e.restoreBackup(zip);
    expect(m.byId(absent.id), isNull);
    await e.pushDirty();
    final objects = s.lastPushBody!['objects'] as List;
    expect(
      objects.any((o) => o['id'] == keep.id && o['revision'] == 2),
      isTrue,
    );
    expect((s.lastPushBody!['tombstones'] as List).single['id'], absent.id);
    expect(e.hasUnsyncedChanges, isFalse);
    await e.pushDirty();
    expect(s.pushes, 2);
  });

  test('到期清理生成比已同步版本更高的本机墓碑', () async {
    final (m, e, s) = await setup();
    final t = await m.createTodo();
    await m.writeTodo(
      t.copyWith(deletedAt: DateTime.now().subtract(const Duration(days: 31))),
    );
    await e.pushDirty();
    final localRevision = m.byId(t.id)!.revision;
    await m.purgeExpiredTrash();
    expect(m.index.tombstones.single.revision, localRevision + 1);
    await e.pushDirty();
    expect((s.lastPushBody!['tombstones'] as List).single['revision'], 2);
    expect(m.byId(t.id), isNull);
  });

  test('冲突保留本机被拒时仍保留冲突入口', () async {
    final (m, e, s) = await setup();
    final t = await m.createTodo();
    e.state.conflicts.add(ConflictRecord('todo', t.id, 1, 10, 'remote'));
    s.onPush = () => api.PushResponse(
      (b) => b
        ..generation = 1
        ..results = ListBuilder([
          api.PushItemResult(
            (r) => r.oneOf = OneOfDynamic(
              typeIndex: 2,
              types: [
                api.PushAppliedResult,
                api.PushConflictResult,
                api.PushRejectedResult,
              ],
              value: api.PushRejectedResult(
                (v) => v
                  ..status = JsonObject('rejected')
                  ..kind = api.ObjectKind.todo
                  ..id = t.id
                  ..code = api.ErrorCode.INVALID_REQUEST
                  ..message = '校验失败',
              ),
            ),
          ),
        ]),
    );
    await e.resolveKeepLocal('todo', t.id);
    expect(e.state.conflicts, hasLength(1));
    expect(e.state.rejected, isNotEmpty);
  });

  for (final bootstrap in [true, false]) {
    test('${bootstrap ? 'bootstrap' : 'pull'} 下载期间切项目，旧正文不落盘', () async {
      final dir = await Directory.systemTemp.createTemp('tt_epoch_payload');
      addTearDown(() => dir.delete(recursive: true));
      final m = AppModel(TodoStore(dir));
      await m.load();
      final todo = await m.createTodo();
      m.todos.clear();
      m.notifyListeners();
      await m.store.deleteTodoFile(todo.id);
      final started = Completer<void>();
      final gate = Completer<void>();
      final dio = Dio();
      final e = SyncEngine(
        m,
        SyncSession(FakeSecureStorage()),
        httpClient: dio,
      );
      final bytes = e.todoBytes(todo.copyWith(body: '旧项目正文'));
      final hash = e.sha256Of(bytes);
      final item = api.standardSerializers.serialize(
        change('todo', todo.id, 1, hash),
        specifiedType: const FullType(api.SyncChange),
      );
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) async {
            if (o.path.endsWith('/sync/bootstrap') ||
                o.path.endsWith('/sync/pull')) {
              h.resolve(
                Response(
                  requestOptions: o,
                  statusCode: 200,
                  data: {
                    'generation': 1,
                    bootstrap ? 'items' : 'changes': [item],
                    'hasMore': false,
                    bootstrap ? 'cursor' : 'nextCursor': 'old-cursor',
                  },
                ),
              );
            } else if (o.method == 'GET') {
              started.complete();
              await gate.future;
              h.resolve(
                Response(requestOptions: o, statusCode: 200, data: bytes),
              );
            } else {
              h.reject(DioException(requestOptions: o, error: '意外请求'));
            }
          },
        ),
      );
      e.state.serverUrl = 'https://sync.test';
      e.state.projectId = 'p1';
      e.state.bootstrapped = !bootstrap;
      e.state.pullCursor = bootstrap ? null : 'old-cursor';
      e.state.generation = 1;
      final running = e.syncNow(manual: true);
      await started.future;
      await e.beginProjectSwitch();
      await e.selectProject('p2');
      gate.complete();
      await running;
      expect(m.todos, isEmpty);
      expect(await m.store.readTodo(todo.id), isNull);
      expect(e.state.projectId, 'p2');
      expect(e.state.bootstrapped, isFalse);
      expect(e.state.baselines, isEmpty);
    });
  }

  test('旧版错误媒体类型通过等价传输副本恢复，成功后不重复推送', () async {
    final dir = await Directory.systemTemp.createTemp('tt_media_repair');
    addTearDown(() => dir.delete(recursive: true));
    final m = AppModel(TodoStore(dir));
    await m.load();
    final dio = Dio();
    final e = SyncEngine(m, SyncSession(FakeSecureStorage()), httpClient: dio);
    e.state.serverUrl = 'https://sync.test';
    e.state.projectId = 'p1';
    final original = e.classificationBytes();
    final oldHash = e.sha256Of(original);
    cleanMeta(e);
    e.state.baselines.remove('classification/classification');
    Uint8List? uploaded;
    String? uploadedType;
    var pushes = 0;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) async {
          if (o.method == 'HEAD') {
            if (o.path.endsWith(oldHash)) {
              h.resolve(
                Response(
                  requestOptions: o,
                  statusCode: 200,
                  headers: Headers.fromMap({
                    'content-type': ['application/octet-stream'],
                  }),
                ),
              );
            } else {
              h.reject(
                DioException(
                  requestOptions: o,
                  type: DioExceptionType.badResponse,
                  response: Response(requestOptions: o, statusCode: 404),
                ),
              );
            }
          } else if (o.method == 'PUT') {
            uploadedType = o.contentType;
            uploaded = Uint8List.fromList(
              await (o.data as Stream<List<int>>).fold<List<int>>(
                [],
                (a, b) => a..addAll(b),
              ),
            );
            h.resolve(Response(requestOptions: o, statusCode: 200));
          } else {
            pushes++;
            h.resolve(
              Response(
                requestOptions: o,
                statusCode: 200,
                data: api.standardSerializers.serialize(
                  accepted((o.data as Map).cast<String, Object?>()),
                  specifiedType: const FullType(api.PushResponse),
                ),
              ),
            );
          }
        },
      ),
    );
    await e.pushDirty();
    expect(uploadedType, 'application/json');
    expect(
      jsonDecode(utf8.decode(uploaded!)),
      jsonDecode(utf8.decode(original)),
    );
    expect(
      e.state.baselines['classification/classification']!.contentHash,
      isNot(oldHash),
    );
    expect(e.hasUnsyncedChanges, isFalse);
    await e.pushDirty();
    expect(pushes, 1);
  });
  test('升级后重建不合法旧请求，保留合法请求的幂等 ID', () async {
    final (m, e, s) = await setup();
    final t = await m.createTodo();
    await m.writeTodo(t.copyWith(body: '旧版离线编辑'));
    cleanMeta(e);
    e.state.pendingPush = PendingPush('invalid-old', 1, [
      {'kind': 'todo', 'id': t.id, 'revision': 5, 'baseRevision': null},
    ], []);
    await e.pushDirty();
    expect(s.pushRequestIds, isNot(contains('invalid-old')));
    expect((s.lastPushBody!['objects'] as List).single['revision'], 1);
    await m.writeTodo(m.byId(t.id)!.copyWith(body: '新修改'));
    s.failNextPushOnce = true;
    await expectLater(e.pushDirty(), throwsA(isA<DioException>()));
    final retryId = e.state.pendingPush!.requestId;
    await e.pushDirty();
    expect(s.pushRequestIds.last, retryId);
    expect(e.hasUnsyncedChanges, isFalse);
  });

  test('旧版媒体类型拒绝在升级时允许重新提交一次', () async {
    final (m, e, _) = await setup();
    e.state.payloadMediaVersion = 1;
    e.state.rejected['classification/classification'] = RejectedRecord(
      'INVALID_REQUEST',
      1,
      'old',
    );
    e.state.rejected['todo/too-big'] = RejectedRecord(
      'PAYLOAD_TOO_LARGE',
      1,
      'large',
    );
    await File('${m.store.stateDir.path}/sync-state.json')
        .writeAsString(SyncStateStore.save(e.state));
    await e.loadState();
    expect(
      e.state.rejected.containsKey('classification/classification'),
      isFalse,
    );
    expect(e.state.rejected.containsKey('todo/too-big'), isTrue);
    expect(e.state.payloadMediaVersion, 2);
  });

  test('无远端哈希的冲突采用远端后不重新生成首次接入冲突', () async {
    final (m, e, s) = await setup();
    final t = await m.createTodo();
    final bytes = e.todoBytes(t.copyWith(body: '采用远端', revision: 8));
    final hash = e.sha256Of(bytes);
    e.state.conflicts.add(ConflictRecord('todo', t.id, 1, 8, null));
    s.onGetPayload = (_) => bytes;
    s.onBootstrap = () => api.BootstrapResponse(
      (b) => b
        ..generation = 1
        ..items = ListBuilder([change('todo', t.id, 8, hash)])
        ..hasMore = false
        ..cursor = 'c',
    );
    cleanMeta(e);
    await e.resolveUseRemote('todo', t.id);
    expect(m.byId(t.id)!.body, '采用远端');
    expect(e.state.conflicts, isEmpty);
    expect(e.hasUnsyncedChanges, isFalse);
  });

  test('恢复备份与后台同步互斥，锁持有时不改本机文件', () async {
    final (m, e, _) = await setup();
    final t = await m.createTodo();
    final lock = await SyncLock.acquire(m.store.stateDir.path);
    try {
      await expectLater(
        e.restoreBackup('/missing.zip'),
        throwsA(isA<BackupException>()),
      );
      expect(await m.store.readTodo(t.id), isNotNull);
    } finally {
      await lock!.release();
    }
  });
}
