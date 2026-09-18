import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasktips/app/app_model.dart';
import 'package:tasktips/app/update_service.dart';
import 'package:tasktips/infra/store.dart';

void main() {
  group('版本比较', () {
    test('v 前缀与多余空白被归一', () {
      expect(UpdateService.normalizeVersion(' v0.0.4 '), '0.0.4');
      expect(UpdateService.normalizeVersion('V1.2.3'), '1.2.3');
    });

    test('数值段比较', () {
      expect(UpdateService.compareVersions('0.0.4', '0.0.4'), 0);
      expect(UpdateService.compareVersions('0.0.5', '0.0.4'), greaterThan(0));
      expect(UpdateService.compareVersions('0.0.4', '0.0.10'), lessThan(0));
      expect(UpdateService.compareVersions('0.1.0', '0.0.99'), greaterThan(0));
      expect(UpdateService.compareVersions('1.0', '1.0.0'), 0);
    });

    test('build 元数据被忽略', () {
      expect(UpdateService.compareVersions('0.0.4+1', '0.0.4'), 0);
    });

    test('预发布小于正式版', () {
      expect(UpdateService.compareVersions('1.0.0-beta', '1.0.0'), lessThan(0));
      expect(
        UpdateService.compareVersions('1.0.0-alpha', '1.0.0-beta'),
        lessThan(0),
      );
    });

    test('shouldUpdate 仅新版为真', () {
      const s = UpdateService();
      final r = ReleaseInfo(
        version: '0.0.5',
        tagName: 'v0.0.5',
        name: 'v0.0.5',
        body: '',
        htmlUrl: '',
        apkUrl: 'https://example.com/a.apk',
        apkFileName: UpdateService.apkAssetName,
        publishedAt: '',
      );
      expect(s.shouldUpdate('0.0.4', r), isTrue);
      expect(s.shouldUpdate('0.0.5', r), isFalse);
      expect(s.shouldUpdate('0.0.6', r), isFalse);
    });
  });

  group('Release 解析', () {
    Map<String, dynamic> fixture() => {
      'tag_name': 'v0.0.5',
      'name': 'TaskTips v0.0.5',
      'body': '修复若干问题',
      'html_url':
          'https://github.com/ke4nec/tasktips-mobile/releases/tag/v0.0.5',
      'published_at': '2026-09-18T00:00:00Z',
      'assets': [
        {
          'name': UpdateService.apkAssetName,
          'browser_download_url': 'https://example.com/app.apk',
          'size': 12345,
        },
        {
          'name': UpdateService.shaAssetName,
          'browser_download_url': 'https://example.com/SHA256SUMS.txt',
          'size': 100,
        },
      ],
    };

    test('固定名资产优先', () {
      final r = UpdateService.parseRelease(fixture());
      expect(r.version, '0.0.5');
      expect(r.apkUrl, 'https://example.com/app.apk');
      expect(r.apkSize, 12345);
      expect(r.shaUrl, 'https://example.com/SHA256SUMS.txt');
    });

    test('改名后回退首个 apk', () {
      final j = fixture();
      (j['assets'] as List)[0]['name'] = 'renamed.apk';
      final r = UpdateService.parseRelease(j);
      expect(r.apkUrl, 'https://example.com/app.apk');
      expect(r.apkFileName, 'renamed.apk');
    });

    test('无 apk 抛错', () {
      final j = fixture();
      j['assets'] = [
        {'name': 'notes.txt', 'browser_download_url': 'https://x/y'},
      ];
      expect(() => UpdateService.parseRelease(j), throwsFormatException);
    });
  });

  group('SHA 解析', () {
    test('标准 sha256sum 行', () {
      const text =
          'abc123  notes.txt\n0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef *app-arm64-v8a-release.apk\n';
      expect(
        UpdateService.parseSha256(text, UpdateService.apkAssetName),
        '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
      );
    });

    test('找不到返回 null', () {
      expect(UpdateService.parseSha256('nope\n', 'a.apk'), isNull);
    });

    test('非法 hex 返回 null', () {
      expect(UpdateService.parseSha256('zzz  a.apk\n', 'a.apk'), isNull);
    });
  });

  group('SHA 计算', () {
    test('空流摘要', () async {
      final hex = await UpdateService.sha256Of(const Stream.empty());
      expect(
        hex,
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      );
    });
  });

  group('fetchLatest 分支（mock Dio，零网络）', () {
    Map<String, dynamic> latest({bool withSha = true}) => {
      'tag_name': 'v0.0.5',
      'name': 'TaskTips v0.0.5',
      'body': '修复若干问题',
      'html_url':
          'https://github.com/ke4nec/tasktips-mobile/releases/tag/v0.0.5',
      'published_at': '2026-09-18T00:00:00Z',
      'assets': [
        {
          'name': UpdateService.apkAssetName,
          'browser_download_url': 'https://example.com/app.apk',
          'size': 12345,
        },
        if (withSha)
          {
            'name': UpdateService.shaAssetName,
            'browser_download_url': 'https://example.com/SHA256SUMS.txt',
            'size': 100,
          },
      ],
    };

    /// 按 URL 分发 canned 响应；value 为 DioException 时按失败回放，
    /// 为 Response 时按原状态码/头回放（用于 302 跳转等）。
    Dio stub(Map<String, Object> routes) {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final url = options.uri.toString();
            final v = routes[url];
            if (v == null) {
              handler.reject(
                DioException(requestOptions: options, error: 'unexpected $url'),
              );
              return;
            }
            if (v is DioException) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: v.type,
                  error: v.error,
                  response: v.response,
                ),
              );
              return;
            }
            if (v is Response) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  data: v.data,
                  statusCode: v.statusCode,
                  headers: v.headers,
                ),
              );
              return;
            }
            handler.resolve(
              Response(requestOptions: options, data: v, statusCode: 200),
            );
          },
        ),
      );
      return dio;
    }

    test('正常：解析出 APK 地址与 SHA', () async {
      const sum =
          '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
      final dio = stub({
        UpdateService.apiLatestUrl: latest(),
        'https://example.com/SHA256SUMS.txt':
            '$sum  ${UpdateService.apkAssetName}\n',
      });
      final r = await const UpdateService().fetchLatest(dio: dio);
      expect(r.version, '0.0.5');
      expect(r.apkUrl, 'https://example.com/app.apk');
      expect(r.sha256, sum);
    });

    test('无校验文件：降级为无校验安装', () async {
      final dio = stub({UpdateService.apiLatestUrl: latest(withSha: false)});
      final r = await const UpdateService().fetchLatest(dio: dio);
      expect(r.shaUrl, isNull);
      expect(r.sha256, isNull);
    });

    test('已提供的校验文件拉取失败：拒绝降级为无校验安装', () async {
      final dio = stub({
        UpdateService.apiLatestUrl: latest(),
        'https://example.com/SHA256SUMS.txt': DioException(
          requestOptions: RequestOptions(path: 'x'),
          type: DioExceptionType.connectionTimeout,
        ),
      });
      await expectLater(
        const UpdateService().fetchLatest(dio: dio),
        throwsA(isA<DioException>()),
      );
    });

    test('已提供的校验文件缺少有效 APK 摘要：拒绝更新', () async {
      final dio = stub({
        UpdateService.apiLatestUrl: latest(),
        'https://example.com/SHA256SUMS.txt': 'invalid checksum',
      });
      await expectLater(
        const UpdateService().fetchLatest(dio: dio),
        throwsFormatException,
      );
    });
  });

  group('跳转 Location 解析', () {
    final req = Uri.parse(UpdateService.webLatestUrl);

    test('绝对与相对地址均提取 tag', () {
      expect(
        UpdateService.tagFromLatestLocation(
          req,
          '/ke4nec/tasktips-mobile/releases/tag/v0.0.6',
        ),
        'v0.0.6',
      );
      expect(
        UpdateService.tagFromLatestLocation(
          req,
          'https://github.com/ke4nec/tasktips-mobile/releases/tag/v0.0.6',
        ),
        'v0.0.6',
      );
    });

    test('非 tag 形态与空串返回空', () {
      expect(
        UpdateService.tagFromLatestLocation(
          req,
          'https://github.com/ke4nec/tasktips-mobile',
        ),
        isEmpty,
      );
      expect(UpdateService.tagFromLatestLocation(req, ''), isEmpty);
    });
  });

  group('API 限流页面回退（mock Dio，零网络）', () {
    DioException httpError(
      int code, {
      Map<String, List<String>>? headers,
      Object? data,
    }) {
      final opts = RequestOptions(path: UpdateService.apiLatestUrl);
      return DioException(
        requestOptions: opts,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: opts,
          statusCode: code,
          headers: Headers.fromMap(headers ?? <String, List<String>>{}),
          data: data,
        ),
      );
    }

    Response redirect302(String location) => Response(
      requestOptions: RequestOptions(path: UpdateService.webLatestUrl),
      statusCode: 302,
      headers: Headers.fromMap({
        'location': [location],
      }),
    );

    Dio stub(Map<String, Object> routes) {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final url = options.uri.toString();
            final v = routes[url];
            if (v == null) {
              handler.reject(
                DioException(requestOptions: options, error: 'unexpected $url'),
              );
              return;
            }
            if (v is DioException) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: v.type,
                  error: v.error,
                  response: v.response,
                ),
              );
              return;
            }
            if (v is Response) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  data: v.data,
                  statusCode: v.statusCode,
                  headers: v.headers,
                ),
              );
              return;
            }
            handler.resolve(
              Response(requestOptions: options, data: v, statusCode: 200),
            );
          },
        ),
      );
      return dio;
    }

    test('限流回退：302 取 tag + 固定名拼地址 + 验 SHA', () async {
      const sum =
          '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
      final dio = stub({
        UpdateService.apiLatestUrl: httpError(
          403,
          headers: const {
            'x-ratelimit-remaining': ['0'],
          },
          data: const {'message': 'API rate limit exceeded for 1.2.3.4.'},
        ),
        UpdateService.webLatestUrl: redirect302(
          '/ke4nec/tasktips-mobile/releases/tag/v0.0.6',
        ),
        'https://github.com/ke4nec/tasktips-mobile/releases/download/v0.0.6/${UpdateService.shaAssetName}':
            '$sum  ${UpdateService.apkAssetName}\n',
      });
      final r = await const UpdateService().fetchLatest(dio: dio);
      expect(r.version, '0.0.6');
      expect(r.tagName, 'v0.0.6');
      expect(
        r.apkUrl,
        'https://github.com/ke4nec/tasktips-mobile/releases/download/v0.0.6/${UpdateService.apkAssetName}',
      );
      expect(r.sha256, sum);
      expect(r.apkSize, isNull);
    });

    test('回退页 SHA 404：降级为无校验安装', () async {
      final dio = stub({
        UpdateService.apiLatestUrl: httpError(
          403,
          data: const {'message': 'API rate limit exceeded'},
        ),
        UpdateService.webLatestUrl: redirect302(
          'https://github.com/ke4nec/tasktips-mobile/releases/tag/v0.0.6',
        ),
        'https://github.com/ke4nec/tasktips-mobile/releases/download/v0.0.6/${UpdateService.shaAssetName}':
            httpError(404),
      });
      final r = await const UpdateService().fetchLatest(dio: dio);
      expect(r.version, '0.0.6');
      expect(r.shaUrl, isNull);
      expect(r.sha256, isNull);
    });

    test('回退页 SHA 无效：拒绝更新', () async {
      final dio = stub({
        UpdateService.apiLatestUrl: httpError(
          403,
          data: const {'message': 'API rate limit exceeded'},
        ),
        UpdateService.webLatestUrl: redirect302(
          '/ke4nec/tasktips-mobile/releases/tag/v0.0.6',
        ),
        'https://github.com/ke4nec/tasktips-mobile/releases/download/v0.0.6/${UpdateService.shaAssetName}':
            'invalid checksum',
      });
      await expectLater(
        const UpdateService().fetchLatest(dio: dio),
        throwsFormatException,
      );
    });

    test('回退页无有效跳转：仍抛原始限流错', () async {
      final dio = stub({
        UpdateService.apiLatestUrl: httpError(
          403,
          data: const {'message': 'API rate limit exceeded'},
        ),
        UpdateService.webLatestUrl: redirect302(
          'https://github.com/ke4nec/tasktips-mobile',
        ),
      });
      await expectLater(
        const UpdateService().fetchLatest(dio: dio),
        throwsA(
          predicate(
            (e) => e is DioException && e.response?.statusCode == 403,
          ),
        ),
      );
    });

    test('非限流 403 不走回退，直接抛', () async {
      final dio = stub({
        UpdateService.apiLatestUrl: httpError(
          403,
          data: const {'message': 'Blocked by proxy'},
        ),
      });
      await expectLater(
        const UpdateService().fetchLatest(dio: dio),
        throwsA(
          predicate(
            (e) => e is DioException && e.response?.statusCode == 403,
          ),
        ),
      );
    });
  });

  group('自动检查开关持久化', () {
    test('缺省开启，关闭后重载保持', () async {
      final tmp = await Directory.systemTemp.createTemp('tasktips_update_test');
      try {
        final model = AppModel(TodoStore(tmp));
        await model.load();
        expect(model.autoUpdateCheck, isTrue);
        await model.setAutoUpdateCheck(false);
        final reloaded = AppModel(TodoStore(tmp));
        await reloaded.load();
        expect(reloaded.autoUpdateCheck, isFalse);
      } finally {
        await tmp.delete(recursive: true);
      }
    });

    test('损坏的开关值回退为默认开启', () async {
      final tmp = await Directory.systemTemp.createTemp('tasktips_update_test');
      try {
        final model = AppModel(TodoStore(tmp));
        await model.store.init();
        await model.store.settingsFile.writeAsString(
          '{"theme":"system","onboardingDone":true,"autoUpdateCheck":"yes"}',
        );
        await model.load();
        expect(model.autoUpdateCheck, isTrue);
      } finally {
        await tmp.delete(recursive: true);
      }
    });
  });
}
