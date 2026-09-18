/// 应用自更新：GitHub Release 检查 / APK 下载 / SHA-256 校验。
///
/// 更新源为公开仓库的 `releases/latest`（CI 仅 `v*` 标签发布，
/// 资产名固定 `app-arm64-v8a-release.apk`，另附 `SHA256SUMS.txt`）。
/// 检查失败一律抛错，由调用方静默吞掉或转提示——永不阻塞启动首帧。
library;

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  static const repoOwner = 'ke4nec';
  static const repoName = 'tasktips-mobile';
  static const apiLatestUrl =
      'https://api.github.com/repos/$repoOwner/$repoName/releases/latest';

  /// API 限流时的回退入口：`releases/latest` 页面会 302 跳到
  /// `releases/tag/<tag>`，tag 即版本号；不走 api.github.com，不消耗
  /// API 配额（未认证每小时 60 次，代理共用时极易耗尽）。
  static const webLatestUrl =
      'https://github.com/$repoOwner/$repoName/releases/latest';

  /// 兜底下载页（检查失败/安装失败时浏览器打开手动下载）。
  static const releasesPageUrl =
      'https://github.com/$repoOwner/$repoName/releases';

  /// CI 上传的固定资产名（android-build.yml）。
  static const apkAssetName = 'app-arm64-v8a-release.apk';
  static const shaAssetName = 'SHA256SUMS.txt';

  /// PackageInfo 不可用时（单测/异常）的回退版本。
  /// 与 pubspec.yaml versionName 保持一致，改版本时同步改这里。
  static const fallbackVersion = '0.0.8';

  const UpdateService();

  /// 本机已装版本（versionName，不含 build-number）。
  Future<String> currentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final v = info.version.trim();
      return v.isEmpty ? fallbackVersion : v;
    } catch (_) {
      return fallbackVersion;
    }
  }

  /// 拉取最新 Release 并（若存在校验文件）解析出 APK 的 SHA-256。
  ///
  /// 主路径走 GitHub API；仅当 API 明确限流（403 + 限流特征）时回退到
  /// Release 页面（302 跳转取 tag + 固定名拼下载地址 + 同样验 SHA）。
  /// 回退页本身不可用时抛原始限流错（提示口径不变）；SHA 校验类失败
  /// 原样抛出（疑似篡改/损坏，必须明示并拒绝更新）。
  Future<ReleaseInfo> fetchLatest({Dio? dio}) async {
    final client =
        dio ??
        Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 10),
            headers: {
              'Accept': 'application/vnd.github+json',
              'User-Agent': 'TaskTips-Mobile',
            },
          ),
        );
    try {
      try {
        return await _fetchViaApi(client);
      } on DioException catch (e) {
        if (e.response?.statusCode != 403 || !isRateLimited(e)) rethrow;
        try {
          return await _fetchViaWeb(client);
        } on _WebFallbackUnavailable {
          throw e;
        }
      }
    } finally {
      if (dio == null) client.close();
    }
  }

  Future<ReleaseInfo> _fetchViaApi(Dio client) async {
    final resp = await client.get<Map<String, dynamic>>(apiLatestUrl);
    final data = resp.data;
    if (data == null) throw const FormatException('更新响应为空');
    final release = parseRelease(data);
    if (release.shaUrl != null) {
      final shaResp = await client.get<String>(
        release.shaUrl!,
        options: Options(responseType: ResponseType.plain),
      );
      final text = shaResp.data ?? '';
      final sum = parseSha256(text, release.apkFileName);
      if (sum == null) throw const FormatException('校验文件缺少有效的 APK SHA-256');
      return release.copyWith(sha256: sum);
    }
    return release;
  }

  /// 页面回退：禁用自动跳转，从 302 Location 提取 tag；APK/SHA 地址按
  /// CI 固定名构造（`releases/download/<tag>/…` 为稳定链接，无需解析 HTML）。
  /// SHA 拉取成功必须含有效摘要；404 视为历史无校验版本降级（调用方提示
  /// 确认来源）；其他失败拒绝本次更新。
  Future<ReleaseInfo> _fetchViaWeb(Dio client) async {
    late final Response<String> resp;
    try {
      resp = await client.get<String>(
        webLatestUrl,
        options: Options(
          responseType: ResponseType.plain,
          followRedirects: false,
          validateStatus: (s) => s != null && s >= 200 && s < 400,
        ),
      );
    } on DioException {
      throw const _WebFallbackUnavailable();
    }
    final tag = tagFromLatestLocation(
      resp.requestOptions.uri,
      resp.headers.value('location') ?? '',
    );
    if (tag.isEmpty) throw const _WebFallbackUnavailable();
    final base =
        'https://github.com/$repoOwner/$repoName/releases/download/$tag';
    String? sha256;
    String? shaUrl;
    try {
      final shaResp = await client.get<String>(
        '$base/$shaAssetName',
        options: Options(responseType: ResponseType.plain),
      );
      final sum = parseSha256(shaResp.data ?? '', apkAssetName);
      if (sum == null) throw const FormatException('校验文件缺少有效的 APK SHA-256');
      sha256 = sum;
      shaUrl = '$base/$shaAssetName';
    } on DioException catch (e) {
      // 404 = 该版本未附校验文件：按历史兼容降级，安装前提示确认来源。
      if (e.response?.statusCode != 404) rethrow;
    }
    return ReleaseInfo(
      version: normalizeVersion(tag),
      tagName: tag,
      name: tag,
      body: '',
      htmlUrl: 'https://github.com/$repoOwner/$repoName/releases/tag/$tag',
      apkUrl: '$base/$apkAssetName',
      apkFileName: apkAssetName,
      apkSize: null,
      shaUrl: shaUrl,
      sha256: sha256,
      publishedAt: '',
    );
  }

  /// GitHub 限流启发式：`x-ratelimit-remaining: 0` 或服务端 message 含
  /// rate limit 字样即判定为限流（未认证 403 常用此形态）。
  /// UI 层限流文案与此处共用判定，口径保持一致。
  static bool isRateLimited(DioException e) {
    final remaining = e.response?.headers.value('x-ratelimit-remaining');
    if (remaining == '0') return true;
    final data = e.response?.data;
    final text = data is Map
        ? '${data['message']}'
        : data is String
            ? data
            : '';
    return RegExp(r'rate.?limit', caseSensitive: false).hasMatch(text);
  }

  /// 从 `/releases/latest` 跳转 Location 提取 tag（兼容绝对/相对地址）。
  /// 非 `…/releases/tag/<tag>` 形态返回空串（调用方拒绝本次更新）。
  static String tagFromLatestLocation(Uri requestUri, String location) {
    if (location.isEmpty) return '';
    final uri = Uri.tryParse(location);
    if (uri == null) return '';
    final resolved = uri.hasScheme ? uri : requestUri.resolveUri(uri);
    final seg = resolved.pathSegments;
    for (var i = 0; i + 2 < seg.length; i++) {
      if (seg[i] == 'releases' && seg[i + 1] == 'tag') return seg[i + 2];
    }
    return '';
  }

  /// 是否有新版可升（latest > current）。
  bool shouldUpdate(String current, ReleaseInfo latest) =>
      compareVersions(
        normalizeVersion(latest.version),
        normalizeVersion(current),
      ) >
      0;

  /// 下载 APK 到 [savePath]（调用方传入 cache 目录文件路径）。
  Future<void> downloadApk({
    required String url,
    required String savePath,
    required ProgressCallback onProgress,
    Dio? dio,
    CancelToken? cancelToken,
  }) async {
    final client =
        dio ??
        Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 120),
            headers: const {'User-Agent': 'TaskTips-Mobile'},
          ),
        );
    try {
      await client.download(
        url,
        savePath,
        onReceiveProgress: onProgress,
        cancelToken: cancelToken,
      );
    } finally {
      if (dio == null) client.close();
    }
  }

  // ---------- 纯函数（可单测） ----------

  /// 去掉首尾空白与 `v` 前缀；`V1.2` → `1.2`。
  static String normalizeVersion(String v) {
    var s = v.trim();
    if (s.startsWith('v') || s.startsWith('V')) s = s.substring(1);
    return s.trim();
  }

  /// SemVer 数值比较（忽略 `+build`；`-pre` < 正式版）。
  /// 返回负/零/正表示 a < b / == / >。
  static int compareVersions(String a, String b) {
    final pa = _splitVersion(a);
    final pb = _splitVersion(b);
    final coreLen = pa.core.length > pb.core.length
        ? pa.core.length
        : pb.core.length;
    for (var i = 0; i < coreLen; i++) {
      final x = i < pa.core.length ? pa.core[i] : 0;
      final y = i < pb.core.length ? pb.core[i] : 0;
      if (x != y) return x.compareTo(y);
    }
    // 核心段相等：无 pre > 有 pre；双 pre 按标识逐段比。
    if (pa.pre == null && pb.pre == null) return 0;
    if (pa.pre == null) return 1;
    if (pb.pre == null) return -1;
    final la = pa.pre!.split('.');
    final lb = pb.pre!.split('.');
    final n = la.length > lb.length ? la.length : lb.length;
    for (var i = 0; i < n; i++) {
      if (i >= la.length) return -1;
      if (i >= lb.length) return 1;
      final c = _comparePreId(la[i], lb[i]);
      if (c != 0) return c;
    }
    return 0;
  }

  static int _comparePreId(String a, String b) {
    final na = int.tryParse(a);
    final nb = int.tryParse(b);
    if (na != null && nb != null) return na.compareTo(nb);
    // 数字标识 < 非数字标识（semver §11）
    if (na != null) return -1;
    if (nb != null) return 1;
    return a.compareTo(b);
  }

  static ({List<int> core, String? pre}) _splitVersion(String v) {
    var s = normalizeVersion(v);
    final plus = s.indexOf('+');
    if (plus >= 0) s = s.substring(0, plus);
    String? pre;
    final dash = s.indexOf('-');
    if (dash >= 0) {
      pre = s.substring(dash + 1);
      s = s.substring(0, dash);
    }
    final core = <int>[];
    for (final part in s.split('.')) {
      // 非数字段按 0 处理（如空串），避免 FormatException 阻断比较
      core.add(int.tryParse(part.trim()) ?? 0);
    }
    return (core: core, pre: (pre == null || pre.isEmpty) ? null : pre);
  }

  /// 解析 `releases/latest` JSON。apk 资产缺失时抛错（资产改名属 CI 违约）。
  static ReleaseInfo parseRelease(Map<String, dynamic> json) {
    final tag = (json['tag_name'] as String?)?.trim() ?? '';
    if (tag.isEmpty) throw const FormatException('Release 缺少 tag_name');
    final assets = (json['assets'] as List?) ?? const [];
    String? apkUrl;
    int? apkSize;
    String? apkName;
    String? shaUrl;
    String? firstApkUrl;
    int? firstApkSize;
    String? firstApkName;
    for (final e in assets) {
      if (e is! Map) continue;
      final name = (e['name'] as String?) ?? '';
      final url = (e['browser_download_url'] as String?) ?? '';
      if (url.isEmpty) continue;
      if (name == shaAssetName) {
        shaUrl ??= url;
        continue;
      }
      if (name.endsWith('.apk')) {
        firstApkUrl ??= url;
        firstApkSize ??= (e['size'] as num?)?.toInt();
        firstApkName ??= name;
        if (name == apkAssetName) {
          apkUrl = url;
          apkSize = (e['size'] as num?)?.toInt();
          apkName = name;
        }
      }
    }
    // 固定名优先，改名后回退到首个 apk（兼容 CI 资产改名窗口）。
    apkUrl ??= firstApkUrl;
    apkSize ??= firstApkSize;
    apkName ??= firstApkName;
    if (apkUrl == null || apkUrl.isEmpty) {
      throw const FormatException('Release 中没有 APK 资产');
    }
    return ReleaseInfo(
      version: normalizeVersion(tag),
      tagName: tag,
      name: (json['name'] as String?) ?? tag,
      body: (json['body'] as String?) ?? '',
      htmlUrl: (json['html_url'] as String?) ?? '',
      apkUrl: apkUrl,
      apkFileName: (apkName == null || apkName.isEmpty)
          ? apkAssetName
          : apkName,
      apkSize: apkSize,
      shaUrl: shaUrl,
      publishedAt: (json['published_at'] as String?) ?? '',
    );
  }

  /// 解析 `sha256sum` 文本，找出 [apkFileName] 对应行的 64 位 hex。
  /// 找不到/非法返回 null（调用方必须拒绝本次更新）。
  static String? parseSha256(String text, String apkFileName) {
    final want = apkFileName.trim().toLowerCase();
    for (final raw in text.split('\n')) {
      final line = raw.trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      final parts = line.split(RegExp(r'\s+'));
      if (parts.length < 2) continue;
      final hash = parts[0].toLowerCase();
      var file = parts.last.trim().toLowerCase();
      if (file.startsWith('*')) file = file.substring(1);
      if (file.contains('/')) file = file.split('/').last;
      if (file != want) continue;
      if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(hash)) return null;
      return hash;
    }
    return null;
  }

  /// 计算字节流的 SHA-256 hex（APK 体积大，按块累加不一次读入内存两份）。
  static Future<String> sha256Of(Stream<List<int>> stream) async {
    final digest = await sha256.bind(stream).first;
    return digest.toString();
  }
}

/// 页面回退不可用（跳转页拉取失败/无有效 tag 跳转）：调用方据此抛原始
/// API 限流错。SHA 校验类失败不用它（须原样暴露并拒绝更新）。
class _WebFallbackUnavailable implements Exception {
  const _WebFallbackUnavailable();
}

/// GitHub 最新 Release（`releases/latest` + 可选校验文件解析结果）。
class ReleaseInfo {
  final String version;
  final String tagName;
  final String name;
  final String body;
  final String htmlUrl;
  final String apkUrl;
  final String apkFileName;
  final int? apkSize;
  final String? shaUrl;
  final String? sha256;
  final String publishedAt;

  const ReleaseInfo({
    required this.version,
    required this.tagName,
    required this.name,
    required this.body,
    required this.htmlUrl,
    required this.apkUrl,
    required this.apkFileName,
    this.apkSize,
    this.shaUrl,
    this.sha256,
    required this.publishedAt,
  });

  ReleaseInfo copyWith({String? sha256}) => ReleaseInfo(
    version: version,
    tagName: tagName,
    name: name,
    body: body,
    htmlUrl: htmlUrl,
    apkUrl: apkUrl,
    apkFileName: apkFileName,
    apkSize: apkSize,
    shaUrl: shaUrl,
    sha256: sha256 ?? this.sha256,
    publishedAt: publishedAt,
  );
}
