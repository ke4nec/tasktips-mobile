/// 自更新交互流：启动静默检查 / 手动检查 / 更新确认 / 下载安装。
///
/// 约定：检查走 GitHub 公开 Release（`releases/latest`），失败一律转提示，
/// 永不抛到调用方；下载经用户确认后才开始（提示+手动确认）。
library;

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/app_model.dart';
import '../app/update_installer.dart';
import '../app/update_service.dart';

/// 进程内仅做一次启动检查（避免前台恢复/Tab 切换重复弹）。
bool _startupChecked = false;
bool _checkActive = false;
bool _downloadActive = false;

/// Keep the route identity: shares and other asynchronous flows may push a
/// different route while the request is running.
class _UpdateProgressRoute {
  final DialogRoute<void> route;

  _UpdateProgressRoute(BuildContext context, WidgetBuilder builder)
    : route = DialogRoute<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(canPop: false, child: builder(context)),
      ) {
    unawaited(Navigator.of(context, rootNavigator: true).push(route));
  }

  Future<void> close() async {
    if (route.isActive) route.navigator?.removeRoute(route);
    await route.completed;
  }
}

/// 启动后台检查：开关关闭/非 Android/已是最新/网络失败 → 静默返回；
/// 仅“有新版”时弹确认框。
Future<void> maybePromptUpdateAtStartup(
  BuildContext context,
  AppModel model, {
  UpdateService service = const UpdateService(),
}) async {
  if (_startupChecked) return;
  _startupChecked = true;
  if (!model.autoUpdateCheck) return;
  if (defaultTargetPlatform != TargetPlatform.android) return;
  if (_checkActive || _downloadActive || !context.mounted) return;
  _checkActive = true;
  try {
    final current = await service.currentVersion();
    final release = await service.fetchLatest();
    if (!service.shouldUpdate(current, release)) return;
    if (!context.mounted || !model.autoUpdateCheck) return;
    await showUpdateDialog(
      context,
      current: current,
      release: release,
      service: service,
    );
  } catch (_) {
    // 启动检查失败静默：用户可在设置页手动重试
  } finally {
    _checkActive = false;
  }
}

/// 设置页手动检查：有加载态，无新版/失败给 SnackBar，有新版弹确认框。
Future<void> checkUpdateManually(
  BuildContext context, {
  UpdateService service = const UpdateService(),
}) async {
  if (_checkActive || _downloadActive || !context.mounted) return;
  _checkActive = true;
  try {
    await _checkUpdateManually(context, service);
  } finally {
    _checkActive = false;
  }
}

Future<void> _checkUpdateManually(
  BuildContext context,
  UpdateService service,
) async {
  if (defaultTargetPlatform != TargetPlatform.android) {
    if (context.mounted) {
      _showTip(
        context,
        const SnackBar(content: Text('当前平台暂不支持应用内更新')),
      );
    }
    return;
  }
  final loading = _UpdateProgressRoute(
    context,
    // 检查中：进度圈靠左 + 文本，左对齐（默认 Row 即左起，不居中）。
    (_) => const AlertDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Text('正在检查更新…'),
        ],
      ),
    ),
  );
  ReleaseInfo? release;
  String current = UpdateService.fallbackVersion;
  Object? error;
  try {
    current = await service.currentVersion();
    release = await service.fetchLatest();
  } catch (e) {
    error = e;
  } finally {
    await loading.close();
  }
  if (!context.mounted) return;
  if (error != null || release == null) {
    _showTip(
      context,
      SnackBar(
        content: Text('检查更新失败：${_shortError(error)}，请稍后重试'),
        duration: const Duration(seconds: 6),
        // 新版 Flutter 中带 action 的 SnackBar 默认常驻（persist=true），
        // 必须显式关闭，否则底部黑条不消失。
        persist: false,
        action: SnackBarAction(
          label: '前往下载页',
          onPressed: () => openReleasePage(UpdateService.releasesPageUrl),
        ),
      ),
    );
    return;
  }
  if (!service.shouldUpdate(current, release)) {
    _showTip(
      context,
      SnackBar(content: Text('${UpdateService.appName}已是最新版本（$current）')),
    );
    return;
  }
  await showUpdateDialog(
    context,
    current: current,
    release: release,
    service: service,
  );
}

/// 新版确认框：版本/大小/更新日志 + [稍后再说] [立即更新]。
Future<void> showUpdateDialog(
  BuildContext context, {
  required String current,
  required ReleaseInfo release,
  UpdateService service = const UpdateService(),
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('发现 ${UpdateService.appName} 新版本 ${release.version}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '当前 ${UpdateService.appName} 版本 $current${_sizeSuffix(release.apkSize)}',
              style: const TextStyle(fontSize: 13),
            ),
            if (release.sha256 == null)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  '该版本未提供校验文件，安装前请确认下载来源为本仓库 Release。',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            if (release.body.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('更新内容', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                release.body.trim(),
                style: const TextStyle(fontSize: 13, height: 1.5),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('稍后再说'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('立即更新'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  await startUpdate(context, release, service: service);
}

/// 确认后的下载→校验→安装流程。
Future<void> startUpdate(
  BuildContext context,
  ReleaseInfo release, {
  ApkInstaller installer = const ApkInstaller(),
  UpdateService service = const UpdateService(),
}) async {
  if (_downloadActive || !context.mounted) return;
  _downloadActive = true;
  try {
    await _startUpdate(context, release, installer, service);
  } finally {
    _downloadActive = false;
  }
}

Future<void> _startUpdate(
  BuildContext context,
  ReleaseInfo release,
  ApkInstaller installer,
  UpdateService service,
) async {
  // Android 8+ 未知来源未授权：先引导去设置，不直接下载。
  try {
    if (!await installer.canInstall()) {
      if (!context.mounted) return;
      final go = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('需要安装权限'),
          content: const Text('Android 要求先允许“安装未知应用”，才能安装下载的新版本。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('去设置'),
            ),
          ],
        ),
      );
      if (go == true) {
        try {
          await installer.openInstallSettings();
        } catch (_) {
          if (context.mounted) {
            _showTip(
              context,
              const SnackBar(content: Text('无法打开设置页，请手动开启未知来源安装权限')),
            );
          }
          return;
        }
        if (!context.mounted || !await installer.canInstall()) return;
      } else {
        return;
      }
    }
  } catch (_) {
    // 权限查询失败不阻断：继续下载，安装失败再提示
  }

  if (!context.mounted) return;
  final cancel = CancelToken();
  final progress = ValueNotifier<double>(0);
  late final _UpdateProgressRoute progressRoute;
  progressRoute = _UpdateProgressRoute(
    context,
    (ctx) => AlertDialog(
      title: Text('正在下载 ${UpdateService.appName} ${release.version}'),
      content: ValueListenableBuilder<double>(
        valueListenable: progress,
        builder: (_, v, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(value: v <= 0 ? null : v),
            const SizedBox(height: 8),
            Text(v <= 0 ? '准备中…' : '${(v * 100).toStringAsFixed(0)}%'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            cancel.cancel('用户取消');
            unawaited(progressRoute.close());
          },
          child: const Text('取消'),
        ),
      ],
    ),
  );

  Directory? downloadDir;
  var installerOpened = false;
  try {
    final dir = await getTemporaryDirectory();
    final outDir = Directory(p.join(dir.path, 'update'));
    await outDir.create(recursive: true);
    downloadDir = await outDir.createTemp('download-');
    final savePath = p.join(downloadDir.path, 'update.apk');
    final f = File(savePath);
    if (cancel.isCancelled || !context.mounted) return;
    await service.downloadApk(
      url: release.apkUrl,
      savePath: savePath,
      cancelToken: cancel,
      onProgress: (got, total) {
        if (!cancel.isCancelled && total > 0) {
          progress.value = (got / total).clamp(0.0, 1.0);
        }
      },
    );
    if (cancel.isCancelled || !context.mounted) return;
    if (release.shaUrl != null && release.sha256 == null) {
      throw const FormatException('校验文件缺少有效的 APK SHA-256');
    }
    if (release.sha256 != null) {
      final actual = await UpdateService.sha256Of(f.openRead());
      if (actual.toLowerCase() != release.sha256!.toLowerCase()) {
        throw const FormatException('安装包校验失败（SHA-256 不一致）');
      }
    }
    await progressRoute.close();
    if (cancel.isCancelled || !context.mounted) return;
    try {
      await installer.install(savePath);
      installerOpened = true;
    } catch (e) {
      if (!context.mounted) return;
      _showInstallFailed(context, release, e);
    }
  } catch (e) {
    if (cancel.isCancelled) return; // 用户主动取消不打扰
    await progressRoute.close();
    if (context.mounted) {
      _showDownloadFailed(context, release, e);
    }
  } finally {
    await progressRoute.close();
    progress.dispose();
    if (!installerOpened && downloadDir != null) {
      try {
        await downloadDir.delete(recursive: true);
      } catch (_) {}
    }
  }
}

void _showDownloadFailed(BuildContext context, ReleaseInfo release, Object e) {
  _showTip(
    context,
    SnackBar(
      content: Text('下载失败：${_shortError(e)}'),
      duration: const Duration(seconds: 6),
      // 见上：带 action 默认常驻，必须显式关闭。
      persist: false,
      action: SnackBarAction(
        label: '前往下载页',
        onPressed: () => openReleasePage(release.htmlUrl),
      ),
    ),
  );
}

void _showInstallFailed(BuildContext context, ReleaseInfo release, Object e) {
  _showTip(
    context,
    SnackBar(
      content: Text('调起安装失败：${_shortError(e)}'),
      duration: const Duration(seconds: 6),
      // 见上：带 action 默认常驻，必须显式关闭。
      persist: false,
      action: SnackBarAction(
        label: '前往下载页',
        onPressed: () => openReleasePage(release.htmlUrl),
      ),
    ),
  );
}

/// 更新提示统一入口：先清队列再弹出，避免失败重试时多条排队、
/// 看起来“底部黑条一直不消失”。
void _showTip(BuildContext context, SnackBar bar) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..clearSnackBars()
    ..showSnackBar(bar);
}

/// 兜底：浏览器打开 Release 页手动下载。
Future<void> openReleasePage(String url) async {
  final candidate = Uri.tryParse(url);
  final uri =
      candidate != null &&
          candidate.scheme == 'https' &&
          candidate.host == 'github.com' &&
          candidate.userInfo.isEmpty &&
          candidate.path.startsWith(
            '/${UpdateService.repoOwner}/${UpdateService.repoName}/releases',
          )
      ? candidate
      : Uri.parse(UpdateService.releasesPageUrl);
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
}

String _sizeSuffix(int? bytes) {
  if (bytes == null || bytes <= 0) return '';
  return ' · 约 ${(bytes / 1048576).toStringAsFixed(1)} MB';
}

String _shortError(Object? e) {
  if (e == null) return '未知错误';
  if (e is DioException) {
    final code = e.response?.statusCode;
    if (code == 403) {
      // GitHub 公开 API 未认证限流（每 IP 每小时 60 次，代理共用额度时
      // 更易耗尽）同样返回 403，与代理拦截/仓库不可见同码不同因：
      // 用限流响应头 + 服务端 message 文案区分，不一律归为“网络错误”。
      // 判定口径与 UpdateService.isRateLimited 共用（限流时自动走页面回退，
      // 走到这里说明回退也失败了，仍按限流提示）。
      if (UpdateService.isRateLimited(e)) {
        return 'GitHub 接口限流（未登录每小时 60 次，代理共用更易耗尽）';
      }
      final detail = _responseMessage(e);
      if (detail != null) return '请求被拒绝（HTTP 403）：$detail';
      return '请求被拒绝（HTTP 403），可能是代理拦截或仓库不可见';
    }
    if (code == 429) return '请求过于频繁（HTTP 429），请稍后再试';
    if (code == 404) return '未找到更新信息（HTTP 404），可能暂无可用版本';
    if (code != null) return '网络错误（HTTP $code）';
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return '连接超时，请检查网络或代理后重试';
      case DioExceptionType.connectionError:
        return '无法连接，请检查网络或代理设置后重试';
      case DioExceptionType.cancel:
        return '已取消';
      case DioExceptionType.badCertificate:
        return '证书校验失败，请检查代理或系统时间后重试';
      case DioExceptionType.unknown:
        return '网络错误（unknown），请检查网络或代理后重试';
      case DioExceptionType.badResponse:
        return '网络错误（badResponse）';
    }
  }
  final s = e.toString();
  const prefix = 'FormatException: ';
  final t = s.startsWith(prefix) ? s.substring(prefix.length) : s;
  return t.length > 60 ? '${t.substring(0, 60)}…' : t;
}

/// 提取服务端返回的一行 message（截断防超长），无有效内容返回 null。
String? _responseMessage(DioException e) {
  final data = e.response?.data;
  final raw = data is Map
      ? data['message']
      : data is String
          ? data
          : null;
  if (raw is! String) return null;
  final oneLine = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (oneLine.isEmpty || oneLine == 'null') return null;
  return oneLine.length > 60 ? '${oneLine.substring(0, 60)}…' : oneLine;
}
