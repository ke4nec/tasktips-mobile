import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasktips/app/app_model.dart';
import 'package:tasktips/app/update_installer.dart';
import 'package:tasktips/app/update_service.dart';
import 'package:tasktips/infra/store.dart';
import 'package:tasktips/ui/update_flow.dart';

const release = ReleaseInfo(
  version: '0.0.5',
  tagName: 'v0.0.5',
  name: 'TaskTips',
  body: '',
  htmlUrl: UpdateService.releasesPageUrl,
  apkUrl: 'https://example.com/update.apk',
  apkFileName: UpdateService.apkAssetName,
  publishedAt: '',
);

class FakeUpdateService extends UpdateService {
  Future<ReleaseInfo> Function()? fetch;
  Future<void> Function(String, ProgressCallback, CancelToken?)? download;
  int checks = 0;

  @override
  Future<String> currentVersion() async => '0.0.5';

  @override
  Future<ReleaseInfo> fetchLatest({Dio? dio}) async {
    checks++;
    return fetch == null ? release : await fetch!();
  }

  @override
  Future<void> downloadApk({
    required String url,
    required String savePath,
    required ProgressCallback onProgress,
    Dio? dio,
    CancelToken? cancelToken,
  }) async {
    await File(savePath).writeAsBytes([1, 2, 3]);
    await download?.call(savePath, onProgress, cancelToken);
  }
}

class FakeInstaller extends ApkInstaller {
  bool allowed = true;
  final settings = Completer<void>();
  bool settingsOpened = false;
  String? installed;

  @override
  Future<bool> canInstall() async => allowed;

  @override
  Future<void> openInstallSettings() {
    settingsOpened = true;
    return settings.future;
  }

  @override
  Future<void> install(String apkPath) async => installed = apkPath;
}

Future<BuildContext> host(WidgetTester tester) async {
  late BuildContext context;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (ctx) {
          context = ctx;
          return const Scaffold(body: Text('Settings'));
        },
      ),
    ),
  );
  return context;
}

Future<void> pumpUntil(WidgetTester tester, bool Function() done) async {
  for (var i = 0; i < 100 && !done(); i++) {
    await tester.pump(const Duration(milliseconds: 20));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 5)),
    );
  }
  expect(done(), isTrue, reason: 'Update flow did not finish');
}

void main() {
  late Directory cache;
  setUp(() async {
    cache = await Directory.systemTemp.createTemp('tt_update_flow');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => cache.path,
        );
  });
  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
    await cache.delete(recursive: true);
  });

  testWidgets('Check completion preserves a route pushed by another flow', (
    tester,
  ) async {
    final context = await host(tester);
    final response = Completer<ReleaseInfo>();
    final service = FakeUpdateService()..fetch = () => response.future;
    var finished = false;
    final checking = checkUpdateManually(
      context,
      service: service,
    ).whenComplete(() => finished = true);
    await tester.pump();
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('Shared note')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    response.complete(release);
    await pumpUntil(tester, () => finished);
    await checking;
    expect(find.text('Shared note'), findsOneWidget);
    Navigator.of(context).pop();
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Immediate check result closes its own loading dialog', (
    tester,
  ) async {
    final context = await host(tester);
    var finished = false;
    final checking = checkUpdateManually(
      context,
      service: FakeUpdateService(),
    ).whenComplete(() => finished = true);
    await pumpUntil(tester, () => finished);
    await checking;
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Settings'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Startup and manual checks share a lock and honor a disabled setting',
    (tester) async {
      final context = await host(tester);
      final model = AppModel(TodoStore(cache));
      final response = Completer<ReleaseInfo>();
      final service = FakeUpdateService()..fetch = () => response.future;
      final checking = maybePromptUpdateAtStartup(
        context,
        model,
        service: service,
      );
      await tester.pump();
      await checkUpdateManually(context, service: service);
      expect(service.checks, 1);
      model.autoUpdateCheck = false;
      response.complete(
        const ReleaseInfo(
          version: '0.0.6',
          tagName: 'v0.0.6',
          name: '',
          body: '',
          htmlUrl: '',
          apkUrl: '',
          apkFileName: '',
          publishedAt: '',
        ),
      );
      await checking;
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      model.dispose();
    },
  );

  testWidgets('Late download completion after cancellation cannot install', (
    tester,
  ) async {
    final context = await host(tester);
    final installer = FakeInstaller();
    final completeDownload = Completer<void>();
    String? downloaded;
    final service = FakeUpdateService()
      ..download = (path, progress, cancel) async {
        downloaded = path;
        progress(3, 3);
        await completeDownload.future;
      };
    var finished = false;
    final updating = startUpdate(
      context,
      release,
      service: service,
      installer: installer,
    ).whenComplete(() => finished = true);
    await pumpUntil(tester, () => downloaded != null);
    await tester.pump();
    await tester.tap(find.text('取消'));
    completeDownload.complete();
    await pumpUntil(tester, () => finished);
    await updating;
    expect(installer.installed, isNull);
    expect(File(downloaded!).existsSync(), isFalse);
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Disposing the calling page closes progress and prevents installation',
    (tester) async {
      final context = await host(tester);
      final navigator = Navigator.of(context);
      late BuildContext pageContext;
      final page = MaterialPageRoute<void>(
        builder: (ctx) {
          pageContext = ctx;
          return const Scaffold(body: Text('Update page'));
        },
      );
      unawaited(navigator.push(page));
      await tester.pumpAndSettle();
      final installer = FakeInstaller();
      final completeDownload = Completer<void>();
      String? downloaded;
      final service = FakeUpdateService()
        ..download = (path, progress, cancel) async {
          downloaded = path;
          await completeDownload.future;
        };
      var finished = false;
      final updating = startUpdate(
        pageContext,
        release,
        service: service,
        installer: installer,
      ).whenComplete(() => finished = true);
      await pumpUntil(tester, () => downloaded != null);
      navigator.removeRoute(page);
      await pumpUntil(tester, () => !pageContext.mounted);
      completeDownload.complete();
      await pumpUntil(tester, () => finished);
      await updating;
      expect(installer.installed, isNull);
      expect(File(downloaded!).existsSync(), isFalse);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Settings'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Checksum mismatch cleans up and never opens the installer', (
    tester,
  ) async {
    final context = await host(tester);
    final installer = FakeInstaller();
    var finished = false;
    final updating = startUpdate(
      context,
      release.copyWith(sha256: '0' * 64),
      service: FakeUpdateService(),
      installer: installer,
    ).whenComplete(() => finished = true);
    await pumpUntil(tester, () => finished);
    await updating;
    expect(installer.installed, isNull);
    expect(find.textContaining('SHA-256 不一致'), findsOneWidget);
    expect(Directory('${cache.path}/update').listSync(), isEmpty);
  });

  for (final allow in [true, false]) {
    testWidgets('Returning from install settings with permission=$allow', (
      tester,
    ) async {
      final context = await host(tester);
      final installer = FakeInstaller()..allowed = false;
      var finished = false;
      final updating = startUpdate(
        context,
        release,
        service: FakeUpdateService(),
        installer: installer,
      ).whenComplete(() => finished = true);
      await tester.pumpAndSettle();
      await tester.tap(find.text('去设置'));
      await tester.pumpAndSettle();
      expect(installer.settingsOpened, isTrue);
      expect(finished, isFalse);
      installer.allowed = allow;
      installer.settings.complete();
      await pumpUntil(tester, () => finished);
      await updating;
      expect(installer.installed, allow ? isNotNull : isNull);
      if (allow) expect(File(installer.installed!).existsSync(), isTrue);
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('检查中提示圈与文本居中对齐', (tester) async {
    final context = await host(tester);
    final response = Completer<ReleaseInfo>();
    final service = FakeUpdateService()..fetch = () => response.future;
    var finished = false;
    final checking = checkUpdateManually(
      context,
      service: service,
    ).whenComplete(() => finished = true);
    await tester.pump(const Duration(milliseconds: 100));
    final dialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
    final padding = dialog.contentPadding as EdgeInsets;
    expect(padding.top, padding.bottom);
    final row = tester.widget<Row>(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(Row),
      ),
    );
    expect(row.mainAxisAlignment, MainAxisAlignment.center);
    expect(row.crossAxisAlignment, CrossAxisAlignment.center);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(Expanded),
      ),
      findsNothing,
    );
    response.complete(release);
    await pumpUntil(tester, () => finished);
    await checking;
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  group('检查失败提示', () {
    DioException httpError(
      int code, {
      Map<String, List<String>>? headers,
      Object? data,
      DioExceptionType type = DioExceptionType.badResponse,
    }) {
      final opts = RequestOptions(path: UpdateService.apiLatestUrl);
      return DioException(
        requestOptions: opts,
        type: type,
        response: Response(
          requestOptions: opts,
          statusCode: code,
          headers: Headers.fromMap(headers ?? <String, List<String>>{}),
          data: data,
        ),
      );
    }

    Future<void> runFailingCheck(
      WidgetTester tester,
      Object error,
    ) async {
      final context = await host(tester);
      final service = FakeUpdateService()
        ..fetch = () => Future<ReleaseInfo>.error(error);
      var finished = false;
      final checking = checkUpdateManually(
        context,
        service: service,
      ).whenComplete(() => finished = true);
      await pumpUntil(tester, () => finished);
      await checking;
      await tester.pumpAndSettle();
    }

    testWidgets('403 限流单独提示且黑条自动消失', (tester) async {
      await runFailingCheck(
        tester,
        httpError(
          403,
          headers: const {
            'x-ratelimit-remaining': ['0'],
          },
          data: const {'message': 'API rate limit exceeded for 1.2.3.4.'},
        ),
      );
      expect(find.textContaining('限流'), findsOneWidget);
      expect(find.textContaining('每小时 60 次'), findsOneWidget);
      // 带“前往下载页”按钮的 SnackBar 必须自动消失（persist:false 回归）。
      await tester.pump(const Duration(seconds: 7));
      await tester.pumpAndSettle();
      expect(find.textContaining('限流'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('403 非限流提示拒绝原因而非网络错误', (tester) async {
      await runFailingCheck(
        tester,
        httpError(403, data: const {'message': 'Blocked by proxy'}),
      );
      expect(find.textContaining('请求被拒绝'), findsOneWidget);
      expect(find.textContaining('Blocked by proxy'), findsOneWidget);
      expect(find.textContaining('网络错误'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('404 与超时文案区分', (tester) async {
      await runFailingCheck(tester, httpError(404));
      expect(find.textContaining('未找到更新信息'), findsOneWidget);

      await runFailingCheck(
        tester,
        DioException(
          requestOptions: RequestOptions(path: UpdateService.apiLatestUrl),
          type: DioExceptionType.connectionTimeout,
        ),
      );
      expect(find.textContaining('超时'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
