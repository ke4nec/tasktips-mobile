/// 登录会话：access token 只放内存，refresh token 放系统安全存储。
library;

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
