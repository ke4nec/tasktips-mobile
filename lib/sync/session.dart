/// 登录会话：access token 只放内存；refresh token 与“记住的登录”
/// （server → email → password，浏览器密码管理器语义）放系统安全存储。
library;

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SyncSession {
  final FlutterSecureStorage _storage;
  String? accessToken;
  String? refreshToken;
  DateTime? accessExpiresAt;
  int? expiresIn;

  // Token 刷新串行协调
  Future<void>? _refreshing;

  SyncSession([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const _kRefresh = 'tasktips.refresh_token';
  static const _kRememberedLogins = 'tasktips.remembered_logins';

  /// 每个服务端地址最多记住的邮箱数：按最近登录截断，防无限增长。
  static const rememberedLoginsPerServer = 5;

  /// 已记住登录的内存缓存（server → email → password）。
  /// 登录表单按邮箱切换即时取密，不必每次击键读平台通道。
  Map<String, Map<String, String>>? _rememberedLogins;

  Future<void> loadRefreshToken() async {
    refreshToken = await _storage.read(key: _kRefresh);
  }

  Future<void> updateTokens(String access, String refresh, int expiresInSeconds) async {
    accessToken = access;
    accessExpiresAt = DateTime.now().add(Duration(seconds: expiresInSeconds - 30));
    expiresIn = expiresInSeconds;
    refreshToken = refresh;
    await _storage.write(key: _kRefresh, value: refresh);
  }

  Future<void> loadRememberedLogins() async {
    _rememberedLogins = {};
    try {
      final raw = await _storage.read(key: _kRememberedLogins);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      for (final e in decoded.entries) {
        if (e.key is String && e.value is Map) {
          _rememberedLogins![e.key as String] = (e.value as Map)
              .map((k, v) => MapEntry(k as String, v as String));
        }
      }
    } catch (_) {
      // 存储内容损坏：当作没有记住的登录，登录流程不受影响
      _rememberedLogins = {};
    }
  }

  bool get hasRememberedLogins =>
      _rememberedLogins?.values.any((m) => m.isNotEmpty) ?? false;

  /// 取记住的密码。须先 [loadRememberedLogins]；未加载或未命中返回 null。
  String? rememberedPassword(String serverUrl, String email) =>
      _rememberedLogins?[serverUrl]?[email];

  /// 记住一次成功登录（覆盖同地址同邮箱的旧密码）。
  /// 退出登录/session 过期都不清除（浏览器语义），由用户在登录表单显式清除。
  Future<void> rememberLogin(String serverUrl, String email, String password) async {
    final logins = _rememberedLogins ??= {};
    final byEmail = logins.putIfAbsent(serverUrl, () => <String, String>{});
    byEmail.remove(email); // 重插到末尾：超出上限时淘汰最久未登录的
    byEmail[email] = password;
    while (byEmail.length > rememberedLoginsPerServer) {
      byEmail.remove(byEmail.keys.first);
    }
    await _storage.write(key: _kRememberedLogins, value: jsonEncode(logins));
  }

  /// 清除全部记住的登录（登录表单“清除记住的登录密码”）。
  Future<void> clearRememberedLogins() async {
    _rememberedLogins = {};
    await _storage.delete(key: _kRememberedLogins);
  }

  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
    accessExpiresAt = null;
    await _storage.delete(key: _kRefresh);
  }

  bool get needsRefresh =>
      accessToken == null ||
      accessExpiresAt == null ||
      DateTime.now().isAfter(accessExpiresAt!);

  /// 串行刷新；凭据轮换不得并发使用。
  Future<void> serializeRefresh(Future<void> Function() doRefresh) {
    return _refreshing ??= doRefresh().whenComplete(() => _refreshing = null);
  }
}

/// 服务端地址校验：支持 HTTP/HTTPS，拒绝含凭据、查询或片段的地址。
String? validateServerUrl(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return '请输入服务端地址';
  final uri = Uri.tryParse(s);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return '地址格式不正确';
  if (uri.scheme != 'https' && uri.scheme != 'http') return '仅支持 HTTP/HTTPS 地址';
  if (uri.userInfo.isNotEmpty) return '地址不能包含凭据';
  if (uri.hasQuery || uri.hasFragment) return '地址不能包含查询或片段';
  return null;
}

String normalizeServerUrl(String raw) {
  final uri = Uri.parse(raw.trim());
  final port = uri.hasPort ? ':${uri.port}' : '';
  return '${uri.scheme}://${uri.host}$port';
}

/// 宽松版地址规范化：输入尚在键入、不成形（无 scheme 等）时返回 null。
/// 供登录表单用当前输入查“记住的登录”对应的键。
String? tryNormalizeServerUrl(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;
  final uri = Uri.tryParse(s);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
  final port = uri.hasPort ? ':${uri.port}' : '';
  return '${uri.scheme}://${uri.host}$port';
}
