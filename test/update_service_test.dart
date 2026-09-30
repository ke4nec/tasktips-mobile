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

  group('检查重试（弱网抖动）', () {
    Map<String, dynamic> latestNoSha() => {
      'tag_name': 'v0.0.5',
      'name': 'TaskTips v0.0.5',
      'body': '',
      'html_url':
          'https://github.com/ke4nec/tasktips-mobile/releases/tag/v0.0.5',
      'published_at': '2026-09-18T00:00:00Z',
      'assets': [
        {
          'name': UpdateService.apkAssetName,
          'browser_download_url': 'https://example.com/app.apk',
          'size': 12345,
        },
      ],
    };

    DioException transient() => DioException(
      requestOptions: RequestOptions(path: UpdateService.apiLatestUrl),
      type: DioExceptionType.connectionTimeout,
    );

    DioException httpError(int code) {
      final opts = RequestOptions(path: UpdateService.apiLatestUrl);
      return DioException(
        requestOptions: opts,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: opts, statusCode: code),
      );
    }

    test('瞬时超时自动重试后成功', () async {
      var calls = 0;
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            calls++;
            if (calls == 1) {
              handler.reject(transient());
              return;
            }
            handler.resolve(
              Response(
                requestOptions: options,
                data: latestNoSha(),
                statusCode: 200,
              ),
            );
          },
        ),
      );
      final r = await const UpdateService().fetchLatest(dio: dio);
      expect(r.version, '0.0.5');
      expect(calls, 2);
    });

    test('500 重试后成功', () async {
      var calls = 0;
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            calls++;
            if (calls == 1) {
              handler.reject(httpError(500));
              return;
            }
            handler.resolve(
              Response(
                requestOptions: options,
                data: latestNoSha(),
                statusCode: 200,
              ),
            );
          },
        ),
      );
      final r = await const UpdateService().fetchLatest(dio: dio);
      expect(r.version, '0.0.5');
      expect(calls, 2);
    });

    test('内容错误不重试', () async {
      var calls = 0;
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            calls++;
            handler.resolve(
              Response(
                requestOptions: options,
                data: {'no_tag': true},
                statusCode: 200,
              ),
            );
          },
        ),
      );
      await expectLater(
        const UpdateService().fetchLatest(dio: dio),
        throwsFormatException,
      );
      expect(calls, 1);
    });

    test('404 不重试直接抛', () async {
      var calls = 0;
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            calls++;
            handler.reject(httpError(404));
          },
        ),
      );
      await expectLater(
        const UpdateService().fetchLatest(dio: dio),
        throwsA(isA<DioException>()),
      );
      expect(calls, 1);
    });
  });

  group('检查总时限（弱网不无限等待）', () {
    /// 无响应挂起：拦截器永不回包，模拟请求发出后一直无响应。
    test('无响应请求到点按连接超时收口', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.uri.toString() != UpdateService.apiLatestUrl) {
              handler.resolve(
                Response(requestOptions: options, statusCode: 200),
              );
            }
            // api.github.com 分支：永不回调 handler，请求挂起。
          },
        ),
      );
      await expectLater(
        const UpdateService().fetchLatest(
          dio: dio,
          timeout: const Duration(milliseconds: 120),
        ),
        throwsA(
          predicate(
            (e) =>
                e is DioException &&
                e.type == DioExceptionType.connectionTimeout,
          ),
        ),
      );
    });

    /// 退避等待中到点：总时限打断 Future.delayed，同样按超时收口，
    /// 不再开始下一次重试。
    test('退避期间到点不再补发重试', () async {
      var calls = 0;
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            calls++;
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionTimeout,
              ),
            );
          },
        ),
      );
      await expectLater(
        const UpdateService().fetchLatest(
          dio: dio,
          timeout: const Duration(milliseconds: 120),
        ),
        throwsA(
          predicate(
            (e) =>
                e is DioException &&
                e.type == DioExceptionType.connectionTimeout,
          ),
        ),
      );
      expect(calls, 1);
    });
  });

  group('下载断点续传（HttpServer 本地）', () {
    late HttpServer server;
    late List<int> content;
    var failFirst = 0;
    var requests = 0;
    var sawRange = false;
    var ignoreRange = false;
    var destroyAtBytes = 0;

    setUp(() async {
      content = List<int>.generate(262144, (i) => i % 256);
      failFirst = 0;
      requests = 0;
      sawRange = false;
      ignoreRange = false;
      destroyAtBytes = 0;
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((req) async {
        requests++;
        if (req.uri.path == '/missing') {
          req.response.statusCode = 404;
          await req.response.close();
          return;
        }
        if (failFirst > 0 && requests <= failFirst) {
          req.response.statusCode = 500;
          await req.response.close();
          return;
        }
        // 首个请求发到指定字节后硬断连接（模拟弱网中途断连，不走正常
        // close），后续请求走下方正常分支。
        // 首个请求发到指定字节后以短于 Content-Length 的 body 提前关连接
        // （模拟弱网中途断连；客户端侧表现为早退 EOF 的裸 HttpException，
        // 与连接被重置同类），后续请求走下方正常分支。
        if (destroyAtBytes > 0 && requests == 1) {
          req.response.bufferOutput = false;
          req.response.headers.contentLength = content.length;
          req.response.add(content.sublist(0, destroyAtBytes));
          try {
            await req.response.close();
          } catch (_) {
            // 短写 close 在服务端抛“Content size below specified
            // contentLength”，正是制造早退 EOF 的手段，吞掉即可。
          }
          return;
        }
        final range = req.headers.value('range');
        if (range != null && !ignoreRange) {
          sawRange = true;
          final m = RegExp(r'bytes=(\d+)-').firstMatch(range);
          final start = m == null ? 0 : int.parse(m.group(1)!);
          if (start >= content.length) {
            req.response.statusCode = 416;
            await req.response.close();
            return;
          }
          final rest = content.sublist(start);
          req.response.statusCode = 206;
          req.response.headers.set(
            'content-range',
            'bytes $start-${content.length - 1}/${content.length}',
          );
          req.response.headers.set('content-length', '${rest.length}');
          req.response.add(rest);
          await req.response.close();
          return;
        }
        req.response.statusCode = 200;
        req.response.headers.set('content-length', '${content.length}');
        req.response.add(content);
        await req.response.close();
      });
    });

    tearDown(() async {
      await server.close(force: true);
    });

    test('预置分片续传补齐且总量正确', () async {
      final tmp = await Directory.systemTemp.createTemp('tt_dl_resume');
      try {
        final url = 'http://127.0.0.1:${server.port}/app.apk';
        final savePath = '${tmp.path}/update.apk';
        await File(savePath).writeAsBytes(content.sublist(0, 100000));
        var lastTotal = -1;
        await const UpdateService().downloadApk(
          url: url,
          savePath: savePath,
          onProgress: (got, total) => lastTotal = total,
        );
        expect(await File(savePath).length(), content.length);
        expect(await File(savePath).readAsBytes(), content);
        expect(sawRange, isTrue);
        expect(lastTotal, content.length);
      } finally {
        await tmp.delete(recursive: true);
      }
    });

    test('服务端忽略 Range 时截断重写不拼接损坏', () async {
      ignoreRange = true;
      final tmp = await Directory.systemTemp.createTemp('tt_dl_full');
      try {
        final url = 'http://127.0.0.1:${server.port}/app.apk';
        final savePath = '${tmp.path}/update.apk';
        await File(savePath).writeAsBytes(List<int>.filled(100, 0));
        await const UpdateService().downloadApk(
          url: url,
          savePath: savePath,
          onProgress: (_, _) {},
        );
        expect(await File(savePath).readAsBytes(), content);
      } finally {
        await tmp.delete(recursive: true);
      }
    });

    test('500 后自动重试成功', () async {
      failFirst = 1;
      final tmp = await Directory.systemTemp.createTemp('tt_dl_retry');
      try {
        final url = 'http://127.0.0.1:${server.port}/app.apk';
        final savePath = '${tmp.path}/update.apk';
        await const UpdateService().downloadApk(
          url: url,
          savePath: savePath,
          onProgress: (_, _) {},
        );
        expect(await File(savePath).readAsBytes(), content);
        expect(requests, 2);
      } finally {
        await tmp.delete(recursive: true);
      }
    });

    test('body 中途断连自动重试且续传补齐', () async {
      destroyAtBytes = 100000;
      final tmp = await Directory.systemTemp.createTemp('tt_dl_reset');
      try {
        final url = 'http://127.0.0.1:${server.port}/app.apk';
        final savePath = '${tmp.path}/update.apk';
        await const UpdateService().downloadApk(
          url: url,
          savePath: savePath,
          onProgress: (_, _) {},
        );
        // 断连在 stream 消费期抛裸 HttpException，必须被归一为
        // DioException 才能进重试循环（首请求分片保留，第二次带 Range 补齐）。
        expect(await File(savePath).readAsBytes(), content);
        expect(requests, 2);
        expect(sawRange, isTrue);
      } finally {
        await tmp.delete(recursive: true);
      }
    });

    test('404 不重试直接抛', () async {
      final tmp = await Directory.systemTemp.createTemp('tt_dl_404');
      try {
        final url = 'http://127.0.0.1:${server.port}/missing';
        await expectLater(
          const UpdateService().downloadApk(
            url: url,
            savePath: '${tmp.path}/update.apk',
            onProgress: (_, _) {},
          ),
          throwsA(isA<DioException>()),
        );
        expect(requests, 1);
      } finally {
        await tmp.delete(recursive: true);
      }
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
