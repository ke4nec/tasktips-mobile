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

  /// 兜底下载页（检查失败/安装失败时浏览器打开手动下载）。
  static const releasesPageUrl =
      'https://github.com/$repoOwner/$repoName/releases';

  /// CI 上传的固定资产名（android-build.yml）。
  static const apkAssetName = 'app-arm64-v8a-release.apk';
  static const shaAssetName = 'SHA256SUMS.txt';

  /// PackageInfo 不可用时（单测/异常）的回退版本。
  /// 与 pubspec.yaml versionName 保持一致，改版本时同步改这里。
  static const fallbackVersion = '0.0.5';

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
    } finally {
      if (dio == null) client.close();
    }
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
