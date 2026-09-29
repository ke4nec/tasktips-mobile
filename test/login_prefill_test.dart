/// 登录回填回归：浏览器式“记住的登录”——按服务端地址+邮箱分账号
/// 记住密码；登录表单切换邮箱自动带出对应密码；session 过期/退出
/// 登录后地址/邮箱/密码回填（last* 字段 + 安全存储密码库）。
library;

import 'dart:io';

import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasktips_api/tasktips_api.dart' as api;

import 'package:tasktips/app/app_model.dart';
import 'package:tasktips/infra/store.dart';
import 'package:tasktips/sync/session.dart';
import 'package:tasktips/sync/sync_engine.dart';
import 'package:tasktips/sync/sync_state.dart';
import 'package:tasktips/ui/pages/sync_page.dart';

import 'sync_engine_test.dart' show FakeSecureStorage;

Object? _std(Object obj, Type t) =>
    api.standardSerializers.serialize(obj, specifiedType: FullType(t));

/// stub 账号路由：/auth/logout、/me/password、/me。
Dio authStubDio() {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (o, h) {
        final p = o.path;
        if (p.endsWith('/auth/logout') || p.endsWith('/me/password')) {
          h.resolve(Response(requestOptions: o, statusCode: 204));
        } else if (p.endsWith('/me')) {
          h.resolve(
            Response(
              requestOptions: o,
              statusCode: 200,
              data: _std(
                api.CurrentUser(
                  (b) => b
                    ..id = 'acc-1'
                    ..email = 'u@example.com'
                    ..role = api.CurrentUserRoleEnum.user
                    ..status = api.CurrentUserStatusEnum.active,
                ),
                api.CurrentUser,
              ),
            ),
          );
        } else {
          h.reject(
            DioException(
              requestOptions: o,
              error: 'stub 未覆盖路径 $p',
              type: DioExceptionType.unknown,
            ),
          );
        }
      },
    ),
  );
  return dio;
}

Dio _noNetwork() {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (o, h) {
        h.reject(
          DioException(
            requestOptions: o,
            error: '单测不应发起网络请求: ${o.path}',
            type: DioExceptionType.unknown,
          ),
        );
      },
    ),
  );
  return dio;
}

DioException _auth401() => DioException(
  requestOptions: RequestOptions(path: '/api/v1/sync/pull'),
  response: Response(
    requestOptions: RequestOptions(path: '/api/v1/sync/pull'),
    statusCode: 401,
    data: {'code': 'AUTH_INVALID'},
  ),
  type: DioExceptionType.badResponse,
);

Future<(Directory, AppModel, FakeSecureStorage, SyncSession, SyncEngine)>
_engine({required Dio dio}) async {
  final dir = await Directory.systemTemp.createTemp('tt_prefill_');
  final model = AppModel(TodoStore(dir));
  await model.load();
  final storage = FakeSecureStorage();
  final session = SyncSession(storage);
  final engine = SyncEngine(model, session, httpClient: dio);
  return (dir, model, storage, session, engine);
}

List<String> _fieldTexts(WidgetTester tester) => tester
    .widgetList<TextField>(find.byType(TextField))
    .map((f) => f.controller!.text)
    .toList();

void main() {
  group('记住的登录：按地址+邮箱分账号', () {
    test('不同邮箱各自记住密码，重启后仍可取', () async {
      final storage = FakeSecureStorage();
      final session = SyncSession(storage);
      await session.loadRememberedLogins();
      await session.rememberLogin('https://sync.test', 'a@example.com', 'pw-a');
      await session.rememberLogin('https://sync.test', 'b@example.com', 'pw-b');
      expect(
        session.rememberedPassword('https://sync.test', 'a@example.com'),
        'pw-a',
      );
      expect(
        session.rememberedPassword('https://sync.test', 'b@example.com'),
        'pw-b',
      );
      // 新会话从安全存储重读（模拟重启）
      final s2 = SyncSession(storage);
      await s2.loadRememberedLogins();
      expect(
        s2.rememberedPassword('https://sync.test', 'a@example.com'),
        'pw-a',
      );
      expect(
        s2.rememberedPassword('https://sync.test', 'b@example.com'),
        'pw-b',
      );
    });

    test('同邮箱不同地址互不串密码', () async {
      final session = SyncSession(FakeSecureStorage());
      await session.loadRememberedLogins();
      await session.rememberLogin(
        'https://one.test',
        'u@example.com',
        'pw-one',
      );
      await session.rememberLogin(
        'https://two.test',
        'u@example.com',
        'pw-two',
      );
      expect(
        session.rememberedPassword('https://one.test', 'u@example.com'),
        'pw-one',
      );
      expect(
        session.rememberedPassword('https://two.test', 'u@example.com'),
        'pw-two',
      );
    });

    test('同邮箱重复登录覆盖旧密码；超上限淘汰最久未登录', () async {
      final session = SyncSession(FakeSecureStorage());
      await session.loadRememberedLogins();
      await session.rememberLogin('https://s', 'a@x.com', '1');
      await session.rememberLogin('https://s', 'a@x.com', '2');
      expect(session.rememberedPassword('https://s', 'a@x.com'), '2');
      for (var i = 0; i < 5; i++) {
        await session.rememberLogin('https://s', 'u$i@x.com', 'p$i');
      }
      // a@x.com 最久未登录，被淘汰；最近 5 个保留
      expect(session.rememberedPassword('https://s', 'a@x.com'), isNull);
      expect(session.rememberedPassword('https://s', 'u0@x.com'), 'p0');
      expect(session.rememberedPassword('https://s', 'u4@x.com'), 'p4');
    });

    test('存储损坏时按无记住登录处理，新登录可覆盖写入', () async {
      final storage = FakeSecureStorage();
      await storage.write(key: 'tasktips.remembered_logins', value: '{oops');
      final session = SyncSession(storage);
      await session.loadRememberedLogins();
      expect(session.hasRememberedLogins, isFalse);
      await session.rememberLogin('https://s', 'a@x.com', 'p');
      expect(session.rememberedPassword('https://s', 'a@x.com'), 'p');
    });
  });

  group('引擎：上次登录信息的写入与保留', () {
    test('logout 保留上次地址/邮箱与记住的登录（浏览器语义）', () async {
      final (dir, model, storage, session, engine) = await _engine(
        dio: authStubDio(),
      );
      addTearDown(() => dir.delete(recursive: true));
      engine.state
        ..serverUrl = 'https://sync.test'
        ..email = 'u@example.com'
        ..lastServerUrl = 'https://sync.test'
        ..lastEmail = 'u@example.com';
      await session.updateTokens('access', 'refresh', 3600);
      await session.rememberLogin(
        'https://sync.test',
        'u@example.com',
        'secret-pass',
      );

      await engine.logout();

      expect(engine.state.serverUrl, isNull);
      expect(engine.state.lastServerUrl, 'https://sync.test');
      expect(engine.state.lastEmail, 'u@example.com');
      // 密码仍在（模拟重启后重读）
      final s2 = SyncSession(storage);
      await s2.loadRememberedLogins();
      expect(
        s2.rememberedPassword('https://sync.test', 'u@example.com'),
        'secret-pass',
      );
      // 落盘副本同样保留：重启后仍可回填
      final disk = SyncStateStore.load(
        await File('${model.store.stateDir.path}/sync-state.json')
            .readAsString(),
      );
      expect(disk.lastServerUrl, 'https://sync.test');
      expect(disk.lastEmail, 'u@example.com');
    });

    test('session 过期（终局认证失败）不清除记住的登录', () async {
      final (dir, _, _, session, engine) = await _engine(dio: _noNetwork());
      addTearDown(() => dir.delete(recursive: true));
      engine.state
        ..serverUrl = 'https://sync.test'
        ..email = 'u@example.com'
        ..lastServerUrl = 'https://sync.test'
        ..lastEmail = 'u@example.com';
      await session.updateTokens('access', 'refresh', 3600);
      await session.rememberLogin(
        'https://sync.test',
        'u@example.com',
        'secret-pass',
      );

      await engine.handleTerminalAuthFailure(_auth401());

      expect(engine.status, SyncStatus.disconnected);
      expect(engine.state.lastServerUrl, 'https://sync.test');
      expect(
        session.rememberedPassword('https://sync.test', 'u@example.com'),
        'secret-pass',
      );
    });

    test('修改密码成功后更新记住的登录', () async {
      final (dir, _, _, session, engine) = await _engine(dio: authStubDio());
      addTearDown(() => dir.delete(recursive: true));
      engine.state
        ..serverUrl = 'https://sync.test'
        ..email = 'u@example.com';
      await session.updateTokens('access', 'refresh', 3600);
      await session.rememberLogin(
        'https://sync.test',
        'u@example.com',
        'old-pass-123',
      );

      final err = await engine.changePassword(
        'old-pass-123',
        'new-pass-456789',
      );

      expect(err, isNull);
      expect(
        session.rememberedPassword('https://sync.test', 'u@example.com'),
        'new-pass-456789',
      );
    });

    test('项目切换保留上次登录地址/邮箱', () async {
      final (dir, _, _, _, engine) = await _engine(dio: _noNetwork());
      addTearDown(() => dir.delete(recursive: true));
      engine.state
        ..serverUrl = 'https://sync.test'
        ..lastServerUrl = 'https://sync.test'
        ..lastEmail = 'u@example.com'
        ..projectId = 'p1';

      await engine.beginProjectSwitch();

      expect(engine.state.projectId, isNull);
      expect(engine.state.lastServerUrl, 'https://sync.test');
      expect(engine.state.lastEmail, 'u@example.com');
    });
  });

  group('登录表单回填', () {
    testWidgets('回填上次输入的地址/邮箱/密码', (tester) async {
      late Directory dir;
      late AppModel model;
      await tester.runAsync(() async {
        final r = await _engine(dio: _noNetwork());
        dir = r.$1;
        model = r.$2;
        r.$5.state
          ..lastServerUrl = 'https://sync.test'
          ..lastEmail = 'u@example.com';
        await r.$4.rememberLogin(
          'https://sync.test',
          'u@example.com',
          'secret-pass',
        );
        model.sync = r.$5;
      });
      addTearDown(() => dir.delete(recursive: true));

      await tester.pumpWidget(MaterialApp(home: SyncPage(model: model)));
      await tester.pumpAndSettle();

      final texts = _fieldTexts(tester);
      expect(texts, hasLength(3));
      expect(texts[0], 'https://sync.test');
      expect(texts[1], 'u@example.com');
      expect(texts[2], 'secret-pass');
    });

    testWidgets('切换邮箱自动带出对应密码，未记住的邮箱清空自动填充', (tester) async {
      late Directory dir;
      late AppModel model;
      await tester.runAsync(() async {
        final r = await _engine(dio: _noNetwork());
        dir = r.$1;
        model = r.$2;
        r.$5.state
          ..lastServerUrl = 'https://sync.test'
          ..lastEmail = 'a@example.com';
        await r.$4.rememberLogin('https://sync.test', 'a@example.com', 'pw-a');
        await r.$4.rememberLogin('https://sync.test', 'b@example.com', 'pw-b');
        model.sync = r.$5;
      });
      addTearDown(() => dir.delete(recursive: true));

      await tester.pumpWidget(MaterialApp(home: SyncPage(model: model)));
      await tester.pumpAndSettle();
      final emailField = find.byType(TextField).at(1);
      final pwField = find.byType(TextField).at(2);

      expect(_fieldTexts(tester)[2], 'pw-a');

      // 切到另一个记住的邮箱 → 带出对应密码
      await tester.enterText(emailField, 'b@example.com');
      await tester.pump();
      expect(_fieldTexts(tester)[2], 'pw-b');

      // 切回第一个 → 再次带出
      await tester.enterText(emailField, 'a@example.com');
      await tester.pump();
      expect(_fieldTexts(tester)[2], 'pw-a');

      // 切到未记住的邮箱 → 自动填充的密码被清空
      await tester.enterText(emailField, 'c@example.com');
      await tester.pump();
      expect(_fieldTexts(tester)[2], '');

      // 手动输入的密码不因切换邮箱被清空
      await tester.enterText(pwField, 'manual-pw');
      await tester.enterText(emailField, 'd@example.com');
      await tester.pump();
      expect(_fieldTexts(tester)[2], 'manual-pw');
    });

    testWidgets('清除记住的登录密码入口', (tester) async {
      late Directory dir;
      late AppModel model;
      await tester.runAsync(() async {
        final r = await _engine(dio: _noNetwork());
        dir = r.$1;
        model = r.$2;
        r.$5.state
          ..lastServerUrl = 'https://sync.test'
          ..lastEmail = 'a@example.com';
        await r.$4.rememberLogin('https://sync.test', 'a@example.com', 'pw-a');
        model.sync = r.$5;
      });
      addTearDown(() => dir.delete(recursive: true));

      await tester.pumpWidget(MaterialApp(home: SyncPage(model: model)));
      await tester.pumpAndSettle();

      expect(_fieldTexts(tester)[2], 'pw-a');
      expect(find.text('清除记住的登录密码'), findsOneWidget);

      await tester.tap(find.text('清除记住的登录密码'));
      await tester.pumpAndSettle();

      expect(_fieldTexts(tester)[2], '');
      expect(find.text('清除记住的登录密码'), findsNothing);
      // 清除后切换邮箱不再带出密码
      await tester.enterText(find.byType(TextField).at(1), 'a@example.com');
      await tester.pump();
      expect(_fieldTexts(tester)[2], '');
    });

    testWidgets('退出登录后回填地址/邮箱/密码', (tester) async {
      late Directory dir;
      late AppModel model;
      late SyncEngine engine;
      await tester.runAsync(() async {
        final r = await _engine(dio: authStubDio());
        dir = r.$1;
        model = r.$2;
        engine = r.$5;
        engine.state
          ..serverUrl = 'https://sync.test'
          ..email = 'u@example.com'
          ..lastServerUrl = 'https://sync.test'
          ..lastEmail = 'u@example.com'
          ..projectId = 'p1'
          ..bootstrapped = true;
        await r.$4.updateTokens('access', 'refresh', 3600);
        await r.$4.rememberLogin(
          'https://sync.test',
          'u@example.com',
          'secret-pass',
        );
        model.sync = engine;
      });
      addTearDown(() => dir.delete(recursive: true));

      // 加高视口令 ListView 惰性子项全部构建，退出按钮无需滚动即可命中
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(MaterialApp(home: SyncPage(model: model)));
      await tester.pumpAndSettle();

      // 退出登录含真实落盘，进 runAsync 轮询等完成
      await tester.runAsync(() async {
        await tester.tap(find.text('退出登录（保留本地内容）'));
        for (var i = 0; i < 50 && engine.state.serverUrl != null; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));
        }
        await tester.pumpAndSettle();
      });
      await tester.pumpAndSettle();

      expect(engine.state.serverUrl, isNull);
      final texts = _fieldTexts(tester);
      expect(texts, hasLength(3));
      expect(texts[0], 'https://sync.test');
      expect(texts[1], 'u@example.com');
      expect(texts[2], 'secret-pass');
    });
  });
}
