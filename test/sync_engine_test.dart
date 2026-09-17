/// 同步引擎 mock 回归网：Dio stub + codegen 配套序列化器构造 canned 响应，
/// 不发起真实网络。覆盖 bootstrap/pull/push/epoch/generation/冲突/
/// rejected/lock/退避/认证分流/待同步口径。
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_of/one_of.dart';
import 'package:tasktips_api/tasktips_api.dart' as api;

import 'package:tasktips/app/app_model.dart';
import 'package:tasktips/infra/store.dart';
import 'package:tasktips/sync/session.dart';
import 'package:tasktips/sync/sync_engine.dart';
import 'package:tasktips/sync/sync_state.dart';

/// 内存安全存储替身：避免单测触碰平台通道。
class FakeSecureStorage extends FlutterSecureStorage {
  FakeSecureStorage() : super();
  final map = <String, String>{};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      map[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      map.remove(key);
    } else {
      map[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    map.remove(key);
  }
}

Object? _std(Object obj, Type t) =>
    api.standardSerializers.serialize(obj, specifiedType: FullType(t));

api.SyncChange _objectChange({
  required String kind,
  required String id,
  required int revision,
  required String contentHash,
}) {
  final inner = api.SyncObjectChange((b) => b
    // 注意：此处用服务端真实线值 'object'（契约 const），而非 codegen 类型名；
    // 配套补丁见 packages/tasktips_api/.../sync_change.dart MANUAL PATCH
    ..type = JsonObject('object')
    ..kind = api.ObjectKind.valueOf(kind)
    ..id = id
    ..schemaVersion = 1
    ..revision = revision
    ..contentHash = contentHash
    ..updatedAt = DateTime.utc(2026, 1, 1)
    ..deviceId = 'dev-1'
    ..changeSequence = 7);
  return api.SyncChange((b) => b.oneOf = OneOfDynamic(
        typeIndex: 0,
        types: [api.SyncObjectChange, api.SyncTombstoneChange],
        value: inner,
      ));
}

api.PushAppliedResult _applied(String kind, String id, int revision) =>
    api.PushAppliedResult((b) => b
      ..status = JsonObject('applied') // 服务端辨别器（openapi const: applied）
      ..kind = api.ObjectKind.valueOf(kind)
      ..id = id
      ..revision = revision
      ..changeSequence = 7
      ..changedAt = DateTime.utc(2026, 1, 1));

/// 可编程 stub：按路径分发 canned 响应并计数。
class StubServer {
  int bootstraps = 0;
  int pulls = 0;
  int pushes = 0;
  int heads = 0;
  int puts = 0;
  int gets = 0;
  final List<String?> pushRequestIds = [];
  Map<String, Object?>? lastPushBody;

  api.BootstrapResponse Function()? onBootstrap;
  api.PullResponse Function()? onPull;
  api.PushResponse Function()? onPush;
  bool failNextPushOnce = false;
  Uint8List Function(String hash)? onGetPayload;

  Dio build() {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
      final p = o.path;
      if (p.endsWith('/sync/bootstrap')) {
        bootstraps++;
        h.resolve(Response(
            requestOptions: o,
            statusCode: 200,
            data: _std(onBootstrap!(), api.BootstrapResponse)));
      } else if (p.endsWith('/sync/pull')) {
        pulls++;
        h.resolve(Response(
            requestOptions: o,
            statusCode: 200,
            data: _std(onPull!(), api.PullResponse)));
      } else if (p.endsWith('/sync/push')) {
        pushes++;
        if (o.data is Map) {
          pushRequestIds.add((o.data as Map)['requestId']?.toString());
          lastPushBody = (o.data as Map).cast<String, Object?>();
        } else {
          pushRequestIds.add(null);
        }
        if (failNextPushOnce) {
          failNextPushOnce = false;
          h.reject(DioException(
              requestOptions: o,
              response:
                  Response(requestOptions: o, statusCode: 500, data: const {}),
              type: DioExceptionType.badResponse));
        } else {
          h.resolve(Response(
              requestOptions: o,
              statusCode: 200,
              data: _std(onPush!(), api.PushResponse)));
        }
      } else if (p.contains('/payloads/')) {
        if (o.method == 'HEAD') {
          heads++;
          h.resolve(Response(requestOptions: o, statusCode: 200));
        } else if (o.method == 'GET') {
          gets++;
          final hash = p.split('/').last;
          h.resolve(Response(
              requestOptions: o,
              statusCode: 200,
              data: onGetPayload?.call(hash) ?? Uint8List(0)));
        } else {
          puts++;
          h.resolve(Response(requestOptions: o, statusCode: 200));
        }
      } else {
        h.reject(DioException(
            requestOptions: o,
            error: 'stub 未覆盖路径 $p',
            type: DioExceptionType.unknown));
      }
    }));
    return dio;
  }
}

Dio _noNetwork() {
  final dio = Dio();
  dio.interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
    h.reject(DioException(
        requestOptions: o,
        error: '单测不应发起网络请求: ${o.path}',
        type: DioExceptionType.unknown));
  }));
  return dio;
}

Future<(AppModel, SyncEngine, StubServer)> _setup() async {
  final dir = await Directory.systemTemp.createTemp('tt_synceng');
  final model = AppModel(TodoStore(dir));
  await model.load();
  final stub = StubServer();
  final engine = SyncEngine(
      model, SyncSession(FakeSecureStorage()),
      httpClient: stub.build());
  engine.state.serverUrl = 'https://sync.test';
  engine.state.projectId = 'p1';
  return (model, engine, stub);
}

DioException _dioError(int status, [Object? code]) => DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: status,
          data: code == null ? null : {'code': code}),
      type: DioExceptionType.badResponse,
    );

api.SyncChange _tombstoneChange(
    {required String kind, required String id, required int revision}) {
  final inner = api.SyncTombstoneChange((b) => b
    ..type = JsonObject('tombstone')
    ..kind = api.ObjectKind.valueOf(kind)
    ..id = id
    ..revision = revision
    ..deletedAt = DateTime.utc(2026, 9, 1, 8)
    ..deviceId = 'desktop-dev'
    ..changeSequence = 9);
  return api.SyncChange((b) => b.oneOf = OneOfDynamic(
        typeIndex: 1,
        types: [api.SyncObjectChange, api.SyncTombstoneChange],
        value: inner,
      ));
}

void main() {
  group('线格式回归（服务端契约 const 辨别器）', () {
    // 锁定 codegen 手工补丁：codegen 按类型名生成辨别器，服务端实际发送
    // type: object/tombstone 与 status: applied/conflict/rejected。
    // 若重新 codegen 覆盖补丁，本组用例会失败。
    test('BootstrapResponse wire：type=object 可解析', () {
      const wire = {
        'generation': 1,
        'items': [
          {
            'type': 'object',
            'kind': 'todo',
            'id': 'x',
            'schemaVersion': 1,
            'revision': 2,
            'contentHash': 'h',
            'updatedAt': '2026-01-01T00:00:00Z',
            'deviceId': 'd',
            'changeSequence': 7,
          }
        ],
        'hasMore': false,
        'cursor': 'c0',
      };
      final back = api.standardSerializers.deserialize(wire,
          specifiedType: const FullType(api.BootstrapResponse));
      expect(back, isA<api.BootstrapResponse>());
    });

    test('PushResponse wire：status=applied 可解析', () {
      const wire = {
        'generation': 1,
        'results': [
          {
            'status': 'applied',
            'kind': 'todo',
            'id': 'x',
            'revision': 2,
            'changeSequence': 7,
            'changedAt': '2026-01-01T00:00:00Z',
          }
        ],
      };
      final back = api.standardSerializers.deserialize(wire,
          specifiedType: const FullType(api.PushResponse));
      expect(back, isA<api.PushResponse>());
    });
  });

  group('SyncLock 跨进程互斥', () {
    test('持有期间他人获取失败，释放后可获取，陈旧锁可抢占', () async {
      final dir = await Directory.systemTemp.createTemp('tt_lock');
      final stateDir = Directory('${dir.path}/state')..createSync();
      final a = await SyncLock.acquire(stateDir.path);
      expect(a, isNotNull);
      expect(await SyncLock.acquire(stateDir.path), isNull);
      await a!.release();
      final b = await SyncLock.acquire(stateDir.path);
      expect(b, isNotNull);
      await b!.release();
      // 陈旧锁（20 分钟前）视为崩溃残留，可抢占
      final f = File('${stateDir.path}/sync.lock');
      await f.writeAsString(
          '${DateTime.now().millisecondsSinceEpoch - 20 * 60 * 1000}\n');
      expect(await SyncLock.acquire(stateDir.path), isNotNull);
      await dir.delete(recursive: true);
    });
  });

  group('退避：自动受限、手动不受限', () {
    test('无失败时不退避；失败后窗口内退避，过期后恢复', () async {
      final (_, engine, _) = await _setup();
      expect(engine.debugBackoffActive, isFalse);
      engine.debugSetBackoff(failures: 1, at: DateTime.now());
      expect(engine.debugBackoffActive, isTrue);
      engine.debugSetBackoff(
          failures: 1,
          at: DateTime.now().subtract(const Duration(minutes: 10)));
      expect(engine.debugBackoffActive, isFalse);
    });

    test('退避中自动同步直接返回，不触碰网络', () async {
      final dir = await Directory.systemTemp.createTemp('tt_bo');
      final model = AppModel(TodoStore(dir));
      await model.load();
      final engine = SyncEngine(
          model, SyncSession(FakeSecureStorage()),
          httpClient: _noNetwork());
      engine.state.serverUrl = 'https://sync.test';
      engine.state.projectId = 'p1';
      engine.debugSetBackoff(failures: 2, at: DateTime.now());
      await engine.syncNow(); // 自动触发：应直接返回
      expect(engine.status, SyncStatus.disconnected);
      expect(engine.state.bootstrapped, isFalse);
      await dir.delete(recursive: true);
    });
  });

  group('错误码解析与认证分流', () {
    test('errorCodeOf 解析 Map 与 JSON 字符串响应体', () async {
      final (_, engine, _) = await _setup();
      expect(engine.errorCodeOf(_dioError(401, 'DEVICE_REVOKED')),
          'DEVICE_REVOKED');
      final strBody = DioException(
        requestOptions: RequestOptions(path: '/x'),
        response: Response(
            requestOptions: RequestOptions(path: '/x'),
            statusCode: 401,
            data: '{"code":"ACCOUNT_DISABLED"}'),
        type: DioExceptionType.badResponse,
      );
      expect(engine.errorCodeOf(strBody), 'ACCOUNT_DISABLED');
      expect(engine.errorCodeOf(_dioError(403)), isNull);
    });

    test('终局失效判定：撤销/禁用/凭据无效为 true，其余为 false', () async {
      final (_, engine, _) = await _setup();
      expect(engine.isTerminalAuthFailure(_dioError(401, 'DEVICE_REVOKED')),
          isTrue);
      expect(engine.isTerminalAuthFailure(_dioError(403, 'ACCOUNT_DISABLED')),
          isTrue);
      expect(
          engine.isTerminalAuthFailure(
              _dioError(401, 'AUTHENTICATION_REQUIRED')),
          isTrue);
      expect(engine.isTerminalAuthFailure(_dioError(403)), isFalse);
      expect(engine.isTerminalAuthFailure(_dioError(429, 'RATE_LIMITED')),
          isFalse);
    });

    test('文案映射：撤销/禁用/维护/限流/断网', () async {
      final (_, engine, _) = await _setup();
      expect(engine.dioMessage(_dioError(401, 'DEVICE_REVOKED'), 'x'),
          '设备已被撤销，请重新登录');
      expect(engine.dioMessage(_dioError(403, 'ACCOUNT_DISABLED'), 'x'),
          '账号已被禁用');
      expect(engine.dioMessage(_dioError(423, 'PROJECT_MAINTENANCE'), 'x'),
          '项目维护中，稍后再试');
      expect(engine.dioMessage(_dioError(429, 'RATE_LIMITED'), 'x'),
          '请求过于频繁，稍后再试');
      expect(engine.dioMessage(_dioError(403), 'x'), '没有权限，设备可能已被撤销');
    });

    test('handleTerminalAuthFailure：清凭据+断开+暂停标记', () async {
      final (_, engine, _) = await _setup();
      final storage = engine.session;
      await storage.updateTokens('access-1', 'refresh-1', 3600);
      engine.status = SyncStatus.connected;
      await engine.handleTerminalAuthFailure(
          _dioError(401, 'DEVICE_REVOKED'));
      expect(storage.refreshToken, isNull);
      expect(storage.accessToken, isNull);
      expect(engine.status, SyncStatus.disconnected);
      expect(engine.state.submitPaused, 'DEVICE_REVOKED');
      expect(engine.lastError, '设备已被撤销，请重新登录');
    });
  });

  group('hasUnsyncedChanges 口径', () {
    test('从未确认基线 → 待同步；基线确认后 → 已同步', () async {
      final (model, engine, _) = await _setup();
      expect(engine.hasUnsyncedChanges, isTrue); // 分类/索引未确认
      engine.state.baselines[engine.state.baselineKey('classification', 'classification')] =
          ObjectBaseline('classification', 'classification', 1,
              engine.classificationHash());
      engine.state.baselines[engine.state.baselineKey('index', 'index')] =
          ObjectBaseline('index', 'index', 1, engine.indexHash());
      expect(engine.hasUnsyncedChanges, isFalse);
      await model.createTodo(); // 新增未确认 Todo
      expect(engine.hasUnsyncedChanges, isTrue);
    });

    test('未确认图片与墓碑点亮待同步', () async {
      final (model, engine, _) = await _setup();
      engine.state.baselines[engine.state.baselineKey('classification', 'classification')] =
          ObjectBaseline('classification', 'classification', 1,
              engine.classificationHash());
      engine.state.baselines[engine.state.baselineKey('index', 'index')] =
          ObjectBaseline('index', 'index', 1, engine.indexHash());
      expect(engine.hasUnsyncedChanges, isFalse);
      final png = Uint8List.fromList(
          [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
      final rel = await model.store.saveImage(png);
      expect(engine.hasUnsyncedChanges, isTrue);
      final name = rel.split('/').last;
      engine.state.baselines[engine.state.baselineKey('image', name)] =
          ObjectBaseline('image', name, 1, engine.sha256Of(png));
      expect(engine.hasUnsyncedChanges, isFalse);
    });
  });

  group('syncNow 全链路（bootstrap→pull→push）', () {
    test('空项目首次同步：cursor 推进、基线确认、状态已同步', () async {
      final (_, engine, stub) = await _setup();
      stub.onBootstrap = () => api.BootstrapResponse((b) => b
        ..generation = 1
        ..items = ListBuilder<api.SyncChange>()
        ..hasMore = false
        ..cursor = 'c0');
      stub.onPull = () => api.PullResponse((b) => b
        ..generation = 1
        ..changes = ListBuilder<api.SyncChange>()
        ..nextCursor = 'c1'
        ..hasMore = false);
      stub.onPush = () => api.PushResponse((b) => b
        ..generation = 1
        ..results = ListBuilder<api.PushItemResult>([
          api.PushItemResult((c) => c.oneOf = OneOfDynamic(
              typeIndex: 0,
              types: const [
                api.PushAppliedResult,
                api.PushConflictResult,
                api.PushRejectedResult,
              ],
              value: _applied('classification', 'classification', 1))),
          api.PushItemResult((c) => c.oneOf = OneOfDynamic(
              typeIndex: 0,
              types: const [
                api.PushAppliedResult,
                api.PushConflictResult,
                api.PushRejectedResult,
              ],
              value: _applied('index', 'index', 1))),
        ]));
      await engine.syncNow(manual: true);
      expect(engine.state.bootstrapped, isTrue);
      expect(engine.state.pullCursor, 'c1');
      expect(engine.state.generation, 1);
      expect(
          engine.state.baselines[
                  engine.state.baselineKey('classification', 'classification')]!
              .revision,
          1);
      expect(
          engine.state.baselines[engine.state.baselineKey('index', 'index')]!
              .revision,
          1);
      expect(engine.state.pendingPush, isNull);
      expect(engine.status, SyncStatus.synced);
      expect(engine.hasUnsyncedChanges, isFalse);
      expect(engine.state.autoSync, isTrue); // 首次接入默认开启
      expect(stub.bootstraps, 1);
      expect(stub.pushes, 1);
    });

    test('push 响应丢失后原 requestId 幂等重试', () async {
      final (model, engine, stub) = await _setup();
      await model.createTodo();
      // 基线确认分类/索引，使本轮仅推送 Todo
      engine.state.baselines[engine.state.baselineKey('classification', 'classification')] =
          ObjectBaseline('classification', 'classification', 1,
              engine.classificationHash());
      engine.state.baselines[engine.state.baselineKey('index', 'index')] =
          ObjectBaseline('index', 'index', 1, engine.indexHash());
      stub.onPush = () => api.PushResponse((b) => b
        ..generation = 1
        ..results = ListBuilder<api.PushItemResult>([
          api.PushItemResult((c) => c.oneOf = OneOfDynamic(
              typeIndex: 0,
              types: const [
                api.PushAppliedResult,
                api.PushConflictResult,
                api.PushRejectedResult,
              ],
              value: _applied(
                  'todo', model.todos.single.id, model.todos.single.revision))),
        ]));
      stub.failNextPushOnce = true; // 首轮 500：pendingPush 保留
      await expectLater(engine.pushDirty(), throwsA(isA<DioException>()));
      expect(engine.state.pendingPush, isNotNull);
      await engine.pushDirty(); // 原样重试
      expect(engine.state.pendingPush, isNull);
      expect(stub.pushes, 2);
      expect(stub.pushRequestIds[0], isNotNull);
      expect(stub.pushRequestIds[0], stub.pushRequestIds[1]); // 同一 requestId
    });
  });

  group('bootstrap 冲突与 pull generation', () {
    test('本机编辑 vs 远端更新 → 整对象冲突，本机不动', () async {
      final (model, engine, stub) = await _setup();
      final t = await model.createTodo();
      await model.writeTodo(t.copyWith(body: '本机正文'));
      engine.state.baselines[engine.state.baselineKey('todo', t.id)] =
          ObjectBaseline('todo', t.id, 1, 'old-hash');
      stub.onBootstrap = () => api.BootstrapResponse((b) => b
        ..generation = 1
        ..items = ListBuilder<api.SyncChange>(
            [_objectChange(kind: 'todo', id: t.id, revision: 2, contentHash: 'remote-hash')])
        ..hasMore = false
        ..cursor = 'c0');
      await engine.bootstrapAndApply();
      expect(engine.state.conflicts, hasLength(1));
      final c = engine.state.conflicts.single;
      expect(c.localRevision, 1);
      expect(c.remoteRevision, 2);
      expect(c.remoteContentHash, 'remote-hash');
      expect(model.byId(t.id)!.body, '本机正文'); // 未被覆盖
      expect(engine.state.baselines[engine.state.baselineKey('todo', t.id)]!.revision,
          1); // 基线未动
    });

    test('pull generation 变化 → 丢弃旧上下文并抛 GENERATION_MISMATCH', () async {
      final (_, engine, stub) = await _setup();
      engine.state.bootstrapped = true;
      engine.state.pullCursor = 'c0';
      engine.state.generation = 1;
      stub.onPull = () => api.PullResponse((b) => b
        ..generation = 2
        ..changes = ListBuilder<api.SyncChange>()
        ..nextCursor = 'c9'
        ..hasMore = false);
      await expectLater(engine.pull(),
          throwsA(predicate((e) => e is SyncException && e.code == 'GENERATION_MISMATCH')));
      expect(engine.state.bootstrapped, isFalse);
      expect(engine.state.pullCursor, isNull);
    });
  });

  group('图片 rejected 按内容哈希', () {
    test('同内容不再上传；内容变化后重试并确认基线', () async {
      final (model, engine, stub) = await _setup();
      engine.state.baselines[engine.state.baselineKey('classification', 'classification')] =
          ObjectBaseline('classification', 'classification', 1,
              engine.classificationHash());
      engine.state.baselines[engine.state.baselineKey('index', 'index')] =
          ObjectBaseline('index', 'index', 1, engine.indexHash());
      final png = Uint8List.fromList(
          [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
      final rel = await model.store.saveImage(png);
      final name = rel.split('/').last;
      final key = engine.state.baselineKey('image', name);
      final hash = engine.sha256Of(png);
      engine.state.rejected[key] = RejectedRecord('PAYLOAD_TOO_LARGE', 1, hash);
      stub.onPush = () => api.PushResponse((b) => b
        ..generation = 1
        ..results = ListBuilder<api.PushItemResult>([
          api.PushItemResult((c) => c.oneOf = OneOfDynamic(
              typeIndex: 0,
              types: const [
                api.PushAppliedResult,
                api.PushConflictResult,
                api.PushRejectedResult,
              ],
              value: _applied('image', name, 1))),
        ]));
      await engine.pushDirty();
      expect(stub.heads, 0); // 同内容：连 HEAD 都不发
      expect(stub.pushes, 0);
      // 文件内容变化 → 重试上传
      engine.state.rejected[key] = RejectedRecord('PAYLOAD_TOO_LARGE', 1, 'other-hash');
      await engine.pushDirty();
      expect(stub.heads, 1);
      expect(stub.pushes, 1);
      expect(engine.state.baselines[key]!.revision, 1);
      expect(engine.state.rejected.containsKey(key), isFalse); // 成功清除
    });
  });

  group('切换项目：放弃本地采用远端', () {
    test('快照本机→清空→隔离同步上下文但保留连接', () async {
      final (model, engine, _) = await _setup();
      await model.createCategory('工作');
      await model.createTodo();
      engine.state.autoSync = true;
      final (stash, err) = await engine.resetLocalAdoptRemote();
      expect(err, isNull);
      expect(stash, isNotNull);
      expect(Directory(stash!).existsSync(), isTrue); // 快照可反悔
      expect(model.todos, isEmpty);
      expect(model.classification.categories, isEmpty);
      expect(model.index.customOrder, isEmpty);
      expect(engine.state.serverUrl, 'https://sync.test'); // 连接保留
      expect(engine.state.accountId, isNull);
      expect(engine.state.projectId, isNull); // 回到项目选择
      expect(engine.state.baselines, isEmpty);
      expect(engine.state.bootstrapped, isFalse);
      expect(engine.state.autoSync, isTrue);
      expect(engine.status, SyncStatus.connected);
    });
  });

  group('批次E/F 校验逻辑（免网络）', () {
    test('renameDevice 名称长度校验', () async {
      final (_, engine, _) = await _setup();
      expect(await engine.renameDevice('d1', ''), isNotNull);
      expect(await engine.renameDevice('d1', 'x' * 129), isNotNull);
    });

    test('changePassword 新密码长度校验', () async {
      final (_, engine, _) = await _setup();
      expect(await engine.changePassword('old', 'short'), isNotNull);
    });

    test('validateRestoreReason 长度校验', () {
      expect(SyncEngine.validateRestoreReason(''), isNotNull);
      expect(SyncEngine.validateRestoreReason('x' * 513), isNotNull);
      expect(SyncEngine.validateRestoreReason('例行恢复'), isNull);
    });

    test('createRestore 模式二选一与原因校验（网络前拦截）', () async {
      final (_, engine, _) = await _setup();
      final (job1, err1) = await engine.createRestore(reason: '');
      expect(job1, isNull);
      expect(err1, isNotNull);
      final (job2, err2) = await engine.createRestore(
          snapshotId: 's1', targetChangeSequence: 5, reason: '测试');
      expect(job2, isNull);
      expect(err2, '按快照与按时间点两种模式二选一');
    });
  });

  group('index 墓碑合并与收敛（对齐桌面协议）', () {
    test('pull 远端 index：未确认本机墓碑保留，已确认被远端列表取代', () async {
      final (model, engine, _) = await _setup();
      // 本机两枚墓碑：一枚已确认（基线 ≥ revision），一枚未确认
      model.index.tombstones.addAll([
        Tombstone('01CONF', 'todo', '2026-08-01T00:00:00Z', 2, 'dev-m'),
        Tombstone('01PEND', 'todo', '2026-08-02T00:00:00Z', 1, 'dev-m'),
      ]);
      engine.state.baselines[engine.state.baselineKey('todo', '01CONF')] =
          ObjectBaseline('todo', '01CONF', 2, null);
      // 远端规范形态 index：墓碑列表为桌面的 01REMOTE
      const remoteCanonical =
          '{"schemaVersion":1,"tombstones":[{"deletedAt":"2026-09-01T08:00:00.123456789Z","deviceId":"desktop-dev","id":"01REMOTE","kind":"todo","projectId":"local","revision":5}]}';
      final hash = engine.sha256Of(utf8.encode(remoteCanonical));
      await engine.debugApplyChange(
          _objectChange(kind: 'index', id: 'index', revision: 5, contentHash: hash),
          prefetched: {hash: Uint8List.fromList(utf8.encode(remoteCanonical))},
          notify: false);
      final ids = model.index.tombstones.map((t) => t.id).toSet();
      expect(ids, containsAll(['01REMOTE', '01PEND'])); // 远端落地 + 未确认保留
      expect(ids, isNot(contains('01CONF'))); // 已确认以远端并集为准
      expect(
          model.index.tombstones
              .firstWhere((t) => t.id == '01REMOTE')
              .deletedAt,
          '2026-09-01T08:00:00.123456789Z'); // 原文时间戳保留
      expect(
          model.index.tombstones
              .firstWhere((t) => t.id == '01PEND')
              .deviceId,
          'dev-m'); // 未确认条目本机优先（同键覆盖远端）
    });

    test('墓碑变更经通道记入 index 缓存（含 image）；同 revision 不降精度', () async {
      final (model, engine, _) = await _setup();
      // 预置同 revision 的原文条目（模拟先经 index 落地的纳秒形态）
      model.index.tombstones.add(Tombstone(
          '01NANO', 'todo', '2026-09-01T08:00:00.123456789Z', 3, 'desktop-dev'));
      await engine.debugApplyChange(
          _tombstoneChange(kind: 'todo', id: '01NANO', revision: 3),
          notify: false);
      expect(
          model.index.tombstones
              .firstWhere((t) => t.id == '01NANO')
              .deletedAt,
          '2026-09-01T08:00:00.123456789Z'); // 等 revision 保留原文

      await engine.debugApplyChange(
          _tombstoneChange(kind: 'image', id: '01IMG.png', revision: 2),
          notify: false);
      expect(
          model.index.tombstones
              .any((t) => t.id == '01IMG.png' && t.kind == 'image'),
          isTrue);
    });

    test('复活守卫：本机墓碑不早于远端对象版本时不落地', () async {
      final (model, engine, _) = await _setup();
      model.index.tombstones
          .add(Tombstone('01DEAD', 'todo', '2026-09-01T00:00:00Z', 4, 'dev-m'));
      await engine.debugApplyChange(
          _objectChange(kind: 'todo', id: '01DEAD', revision: 3, contentHash: 'h3'),
          notify: false);
      expect(model.todos.any((t) => t.id == '01DEAD'), isFalse);
      expect(
          engine.state.baselines[engine.state.baselineKey('todo', '01DEAD')]!
              .revision,
          3); // 基线已确认但不应用
    });

    test('push 仅推送 todo 墓碑；image 墓碑只留本机缓存', () async {
      final (model, engine, stub) = await _setup();
      // 分类/索引基线对齐避免无关推送噪音（index 无基线会随墓碑一并推送，属预期）
      engine.state.baselines[engine.state.baselineKey('classification', 'classification')] =
          ObjectBaseline('classification', 'classification', 1,
              engine.classificationHash());
      model.index.tombstones.addAll([
        Tombstone('01T', 'todo', '2026-09-01T00:00:00.123456Z', 1, 'dev-m'),
        Tombstone('01I.png', 'image', '2026-09-01T00:00:00.123456Z', 1, 'dev-m'),
      ]);
      stub.onPush = () => api.PushResponse((b) => b
        ..generation = 1
        ..results = ListBuilder<api.PushItemResult>([
          for (final r in [
            _applied('todo', '01T', 1),
            _applied('index', 'index', 1),
          ])
            api.PushItemResult((c) => c.oneOf = OneOfDynamic(
                typeIndex: 0,
                types: const [
                  api.PushAppliedResult,
                  api.PushConflictResult,
                  api.PushRejectedResult,
                ],
                value: r)),
        ]));
      await engine.pushDirty();
      expect(stub.pushes, 1);
      final wire = stub.lastPushBody!;
      final tombstones = (wire['tombstones'] as List).cast<Map<String, Object?>>();
      expect(tombstones, hasLength(1));
      expect(tombstones.single['id'], '01T');
      expect(tombstones.single['deletedAt'], '2026-09-01T00:00:00.123456Z');
      expect(tombstones.single.containsKey('projectId'), isFalse); // 推送契约无 projectId
    });
  });
}
