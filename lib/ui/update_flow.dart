/// 自更新交互流：启动静默检查 / 手动检查 / 更新确认 / 下载安装。
///
/// 约定：检查走 GitHub 公开 Release（`releases/latest`），失败一律转提示，
/// 永不抛到调用方；下载经用户确认后才开始（提示+手动确认）。检查中弹层
/// 可随时关闭，检查转后台、结果到达再提示；检查时限与重试次数受
/// [UpdateService.fetchTimeout] 总时限约束。
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
import 'theme.dart';

/// 进程内仅做一次启动检查（避免前台恢复/Tab 切换重复弹）。
bool _startupChecked = false;
bool _downloadActive = false;

/// 手动/启动检查共享的产出：release 与 error 二选一（error 非空即失败）。
typedef _CheckOutcome = ({String current, ReleaseInfo? release, Object? error});

/// 正在进行的检查任务。重复触发（用户关掉进度弹层后再点“检查更新”、
/// 启动检查与手动检查重叠）复用同一次网络请求。[presented] 在结果
/// 到达后认领（check-then-set 同步原子），保证结果只提示一次；启动
/// 检查对无新版/失败不认领，同期手动检查仍会给出自己的提示。
/// [done] 使迟到挂接者不再闪现进度弹层，直接接手或跳过提示。
class _CheckTask {
  final Future<_CheckOutcome> result;
  bool done = false;
  bool presented = false;

  _CheckTask(this.result) {
    result.whenComplete(() => done = true);
  }
}

_CheckTask? _checkTask;

_CheckTask _startCheckTask(UpdateService service) {
  final task = _CheckTask(() async {
    String current = UpdateService.fallbackVersion;
    ReleaseInfo? release;
    Object? error;
    try {
      current = await service.currentVersion();
      release = await service.fetchLatest();
    } catch (e) {
      error = e;
    }
    return (current: current, release: release, error: error);
  }());
  return _checkTask = task;
}

const _checkingRow = Row(
  mainAxisAlignment: MainAxisAlignment.start,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    CircularProgressIndicator(),
    SizedBox(width: 16),
    Text('正在检查更新…'),
  ],
);

/// Keep the route identity: shares and other asynchronous flows may push a
/// different route while the request is running.
class _UpdateProgressRoute {
  final ModalBottomSheetRoute<void> route;

  /// [dismissible] 为 false（下载进度）：只拦系统返回，关闭一律走
  /// [close]，防止误触中断下载；为 true（检查中）：返回手势、点弹层
  /// 外、下拉均可关闭，任务本身转后台继续。
  _UpdateProgressRoute(
    BuildContext context,
    Widget content, {
    bool dismissible = false,
  }) : route = ModalBottomSheetRoute<void>(
        builder: (_) => PopScope(
          canPop: dismissible,
          // 与“关于”弹层同一样式：panel 底、顶部圆角 28、安全区内边距
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              child: content,
            ),
          ),
        ),
        backgroundColor:
            appColors(context, Theme.of(context).brightness).panel,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        isScrollControlled: false,
        isDismissible: dismissible,
        enableDrag: dismissible,
      ) {
    unawaited(Navigator.of(context, rootNavigator: true).push(route));
  }

  bool _closed = false;

  /// 栈顶时走 pop() 带动画滑出（与其余底部弹层动效一致；PopScope(canPop:false)
  /// 只拦系统返回，不拦 Navigator.pop）；被其他路由盖住时保底
  /// removeRoute 立即移除。_closed 保证关闭动作只触发一次；重复调用仍等
  /// completed（退出动画结束、路由释放后才完成），调用方据此安全释放进度流。
  /// 用户手势关闭（dismissible 弹层）时路由状态已同步越过 popping，
  /// isActive 为 false，不会重复 pop 底下页面。
  Future<void> close() async {
    if (!_closed) {
      _closed = true;
      final nav = route.navigator;
      if (route.isActive && nav != null) {
        if (route.isCurrent) {
          nav.pop();
        } else {
          nav.removeRoute(route);
        }
      }
    }
    await route.completed;
  }
}

/// 更新流程确认类弹层：底部 sheet（与“关于”弹层同一样式），
/// 不再用居中 AlertDialog。按钮按确认弹层规范 48dp 高。
Future<T?> _showUpdateSheet<T>(
  BuildContext context, {
  required String title,
  required Widget content,
  required List<Widget> Function(BuildContext ctx) actions,
}) {
  final a = appColors(context, Theme.of(context).brightness);
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: a.panel,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) {
      final btns = actions(ctx);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              content,
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (var i = 0; i < btns.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    btns[i],
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _sheetTextBtn(String label, VoidCallback onTap) => TextButton(
      style: TextButton.styleFrom(minimumSize: const Size(72, 48)),
      onPressed: onTap,
      child: Text(label),
    );

Widget _sheetFilledBtn(String label, VoidCallback onTap) => FilledButton(
      style: FilledButton.styleFrom(minimumSize: const Size(72, 48)),
      onPressed: onTap,
      child: Text(label),
    );

/// 启动后台检查：开关关闭/非 Android/已是最新/网络失败 → 静默返回；
/// 仅“有新版”时弹确认框（全程静默容错，永不抛到 fire-and-forget 的
/// 调用方）。与手动检查共享同一次在飞请求；无新版/失败不占用展示权，
/// 同期手动检查仍会提示自己的结果。
Future<void> maybePromptUpdateAtStartup(
  BuildContext context,
  AppModel model, {
  UpdateService service = const UpdateService(),
}) async {
  if (_startupChecked) return;
  _startupChecked = true;
  if (!model.autoUpdateCheck) return;
  if (defaultTargetPlatform != TargetPlatform.android) return;
  if (_checkTask != null || _downloadActive || !context.mounted) return;
  final task = _startCheckTask(service);
  try {
    final outcome = await task.result;
    // 启动检查失败静默：用户可在设置页手动重试
    final release = outcome.release;
    if (outcome.error != null || release == null) return;
    if (!service.shouldUpdate(outcome.current, release)) return;
    if (!context.mounted || !model.autoUpdateCheck || task.presented) return;
    task.presented = true;
    await showUpdateDialog(
      context,
      current: outcome.current,
      release: release,
      service: service,
    );
  } catch (_) {
    // 启动检查全程静默（含确认弹层异常），永不抛到调用方
  } finally {
    if (_checkTask == task) _checkTask = null;
  }
}

/// 设置页手动检查：进度弹层可随时用返回手势、点弹层外或下拉关闭——
/// 关闭后检查转后台继续，结果到达时再提示（已是最新/失败 SnackBar、
/// 发现新版弹确认框）。检查进行中重复点击复用同一次请求、只重开进度
/// 弹层；结果只提示一次（到达后认领，认领者的 context 已失效时让给
/// 后续挂接者补提示）。
Future<void> checkUpdateManually(
  BuildContext context, {
  UpdateService service = const UpdateService(),
}) async {
  if (!context.mounted) return;
  if (defaultTargetPlatform != TargetPlatform.android) {
    _showTip(context, const SnackBar(content: Text('当前平台暂不支持应用内更新')));
    return;
  }
  if (_downloadActive) return;
  final task = _checkTask ?? _startCheckTask(service);
  // 已完成的检查（结果尚无人认领/确认框已被别人弹着）直接接手，
  // 不再闪现进度弹层。
  final loading = task.done
      ? null
      : _UpdateProgressRoute(context, _checkingRow, dismissible: true);
  final _CheckOutcome outcome;
  try {
    outcome = await task.result;
  } finally {
    await loading?.close();
  }
  if (!context.mounted || task.presented) return;
  task.presented = true;
  try {
    final release = outcome.release;
    if (outcome.error != null || release == null) {
      _showTip(
        context,
        SnackBar(
          content: Text('检查更新失败：${_shortError(outcome.error)}，请稍后重试'),
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
    if (!service.shouldUpdate(outcome.current, release)) {
      _showTip(
        context,
        SnackBar(
          content: Text(
            '${UpdateService.appName}已是最新版本（${outcome.current}）',
          ),
        ),
      );
      return;
    }
    await showUpdateDialog(
      context,
      current: outcome.current,
      release: release,
      service: service,
    );
  } finally {
    if (_checkTask == task) _checkTask = null;
  }
}

/// 新版确认框：版本/大小/更新日志 + [稍后再说] [立即更新]。
Future<void> showUpdateDialog(
  BuildContext context, {
  required String current,
  required ReleaseInfo release,
  UpdateService service = const UpdateService(),
}) async {
  final ok = await _showUpdateSheet<bool>(
    context,
    title: '发现 ${UpdateService.appName} 新版本 ${release.version}',
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
    actions: (ctx) => [
      _sheetTextBtn('稍后再说', () => Navigator.pop(ctx, false)),
      _sheetFilledBtn('立即更新', () => Navigator.pop(ctx, true)),
    ],
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
      final go = await _showUpdateSheet<bool>(
        context,
        title: '需要安装权限',
        content: const Text('Android 要求先允许“安装未知应用”，才能安装下载的新版本。'),
        actions: (ctx) => [
          _sheetTextBtn('取消', () => Navigator.pop(ctx, false)),
          _sheetFilledBtn('去设置', () => Navigator.pop(ctx, true)),
        ],
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
    Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('正在下载 ${UpdateService.appName} ${release.version}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        ValueListenableBuilder<double>(
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
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _sheetTextBtn('取消', () {
              cancel.cancel('用户取消');
              unawaited(progressRoute.close());
            }),
          ],
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
    Future<void> downloadOnce() => service.downloadApk(
      url: release.apkUrl,
      savePath: savePath,
      cancelToken: cancel,
      onProgress: (got, total) {
        if (!cancel.isCancelled && total > 0) {
          progress.value = (got / total).clamp(0.0, 1.0);
        }
      },
    );
    // downloadApk 内部已断点续传+重试；这里只负责调起。
    await downloadOnce();
    if (cancel.isCancelled || !context.mounted) return;
    if (release.shaUrl != null && release.sha256 == null) {
      throw const FormatException('校验文件缺少有效的 APK SHA-256');
    }
    if (release.sha256 != null) {
      var actual = await UpdateService.sha256Of(f.openRead());
      if (actual.toLowerCase() != release.sha256!.toLowerCase()) {
        // 续传拼接损坏或传输坏块：删除后从零重下一次；仍不一致则拒绝安装。
        try {
          await f.delete();
        } catch (_) {}
        progress.value = 0;
        if (cancel.isCancelled || !context.mounted) return;
        await downloadOnce();
        if (cancel.isCancelled || !context.mounted) return;
        actual = await UpdateService.sha256Of(f.openRead());
        if (actual.toLowerCase() != release.sha256!.toLowerCase()) {
          throw const FormatException('安装包校验失败（SHA-256 不一致）');
        }
      }
    }
    // 包已验明：只保留最新一份，清掉历史残留（上次成功安装留下的包等）
    try {
      await for (final e in outDir.list()) {
        if (e.path != downloadDir.path) await e.delete(recursive: true);
      }
    } catch (_) {}
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
