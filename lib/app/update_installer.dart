/// APK 安装通道：Dart 侧封装，Native 实现见 MainActivity（FileProvider）。
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ApkInstaller {
  static const MethodChannel _channel =
      MethodChannel('dev.tasktips.tasktips/install_apk');

  const ApkInstaller();

  /// Android 8+ 未知来源安装是否已授权；非 Android 一律 true。
  Future<bool> canInstall() async {
    if (!Platform.isAndroid) return true;
    try {
      final v = await _channel.invokeMethod<bool>('canRequestPackageInstalls');
      return v ?? true;
    } catch (_) {
      return true;
    }
  }

  /// 跳到“允许来自此来源的应用”系统设置页，返回应用后完成。
  Future<void> openInstallSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('openInstallSettings');
    } catch (e) {
      debugPrint('打开安装权限设置失败：$e');
      rethrow;
    }
  }

  /// 调起系统安装器安装 [apkPath]。返回 Native 是否成功拉起。
  Future<void> install(String apkPath) async {
    try {
      await _channel.invokeMethod<void>('installApk', {'path': apkPath});
    } on PlatformException catch (e) {
      debugPrint('调起安装器失败：${e.code} ${e.message}');
      rethrow;
    }
  }
}
