/// connect 链路回归：登录成功写入 last* 并记住登录（安全存储）；
/// 记住登录写失败只降级不阻断登录。
/// 登录请求走引擎自建的 plain Dio，注入 httpClient 的拦截器拦不到，
/// 故起真实本地端口；本文件不得含 testWidgets（binding 会劫持
/// HttpClient 令所有请求返回 400）。
library;

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tasktips/app/app_model.dart';
import 'package:tasktips/infra/store.dart';
import 'package:tasktips/sync/session.dart';
import 'package:tasktips/sync/sync_engine.dart';
import 'package:tasktips/sync/sync_state.dart';

import 'sync_engine_test.dart' show FakeSecureStorage;

/// 本地 stub 服务器：/auth/login、/me、/devices/register、/devices；
/// /auth/logout、/me/password 返回 204。
Future<HttpServer> _startStubServer() async {
  final device = jsonEncode({
    'id': 'd1',
    'ownerUserId': 'acc-1',
    'displayName': 'dev-d1',
    'platform': 'android',
    'appVersion': '0.1.2',
    'createdAt': '2026-01-01T00:00:00.000Z',
  });
  final server = await HttpServer.bind('127.0.0.1', 0);
  server.listen((req) async {
    await req.drain<void>();
    final p = req.uri.path;
    String? body;
    var status = 200;
    if (p.endsWith('/auth/login')) {
      body = jsonEncode({
        'accessToken': 'acc-1',
        'refreshToken': 'ref-1',
        'expiresIn': 3600,
      });
    } else if (p.endsWith('/me')) {
      body = jsonEncode({
        'id': 'acc-1',
        'email': 'u@example.com',
        'role': 'user',
        'status': 'active',
      });
    } else if (p.endsWith('/devices/register')) {
      body = device;
    } else if (p.endsWith('/devices')) {
      body = jsonEncode({'items': [jsonDecode(device)]});
    } else if (p.endsWith('/auth/logout') || p.endsWith('/me/password')) {
      status = 204;
    } else {
      status = 404;
      body = jsonEncode({'code': 'NOT_FOUND'});
    }
    req.response.statusCode = status;
    if (body != null) {
      req.response.headers.contentType = ContentType.json;
      req.response.write(body);
    }
    await req.response.close();
  });
  return server;
}

/// 记住的登录键写入失败（模拟安全存储异常），其余键（refresh token）正常。
class _FlakySecureStorage extends FakeSecureStorage {
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
    if (key == 'tasktips.remembered_logins') {
      throw Exception('安全存储写入失败');
    }
    await super.write(key: key, value: value);
  }
}

Future<(Directory, AppModel, SyncSession, SyncEngine)> _engine(
    {FlutterSecureStorage? storage}) async {
  final dir = await Directory.systemTemp.createTemp('tt_connect_');
  final model = AppModel(TodoStore(dir));
  await model.load();
  final session = SyncSession(storage ?? FakeSecureStorage());
  final engine = SyncEngine(model, session, httpClient: Dio());
  return (dir, model, session, engine);
}

void main() {
  group('引擎：connect 与记住的登录', () {
    test('connect 成功：last* 落盘并记住登录', () async {
      final server = await _startStubServer();
      addTearDown(server.close);
      final (dir, model, session, engine) = await _engine();
      addTearDown(() => dir.delete(recursive: true));
      final url = 'http://127.0.0.1:${server.port}';

      final err = await engine.connect(
        serverUrl: url,
        email: 'u@example.com',
        password: 'pw-123456',
      );

      expect(err, isNull);
      expect(engine.state.serverUrl, url);
      expect(engine.state.lastServerUrl, url);
      expect(engine.state.lastEmail, 'u@example.com');
      expect(session.rememberedPassword(url, 'u@example.com'), 'pw-123456');
      final disk = SyncStateStore.load(
        await File('${model.store.stateDir.path}/sync-state.json')
            .readAsString(),
      );
      expect(disk.lastServerUrl, url);
      expect(disk.lastEmail, 'u@example.com');
    });

    test('记住登录存储失败不阻断登录', () async {
      final server = await _startStubServer();
      addTearDown(server.close);
      final (dir, _, session, engine) =
          await _engine(storage: _FlakySecureStorage());
      addTearDown(() => dir.delete(recursive: true));

      final err = await engine.connect(
        serverUrl: 'http://127.0.0.1:${server.port}',
        email: 'u@example.com',
        password: 'pw-123456',
      );

      // 登录本身已成功，记住登录写失败只降级不失败
      expect(err, isNull);
      expect(engine.status, SyncStatus.connected);
      expect(session.refreshToken, 'ref-1');
    });
  });
}
