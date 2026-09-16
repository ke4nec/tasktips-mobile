// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_login_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminLoginRequest extends AdminLoginRequest {
  @override
  final String email;
  @override
  final String password;
  @override
  final String deviceId;

  factory _$AdminLoginRequest(
          [void Function(AdminLoginRequestBuilder)? updates]) =>
      (AdminLoginRequestBuilder()..update(updates))._build();

  _$AdminLoginRequest._(
      {required this.email, required this.password, required this.deviceId})
      : super._();
  @override
  AdminLoginRequest rebuild(void Function(AdminLoginRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminLoginRequestBuilder toBuilder() =>
      AdminLoginRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminLoginRequest &&
        email == other.email &&
        password == other.password &&
        deviceId == other.deviceId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminLoginRequest')
          ..add('email', email)
          ..add('password', password)
          ..add('deviceId', deviceId))
        .toString();
  }
}

class AdminLoginRequestBuilder
    implements Builder<AdminLoginRequest, AdminLoginRequestBuilder> {
  _$AdminLoginRequest? _$v;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  AdminLoginRequestBuilder() {
    AdminLoginRequest._defaults(this);
  }

  AdminLoginRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _email = $v.email;
      _password = $v.password;
      _deviceId = $v.deviceId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminLoginRequest other) {
    _$v = other as _$AdminLoginRequest;
  }

  @override
  void update(void Function(AdminLoginRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminLoginRequest build() => _build();

  _$AdminLoginRequest _build() {
    final _$result = _$v ??
        _$AdminLoginRequest._(
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'AdminLoginRequest', 'email'),
          password: BuiltValueNullFieldError.checkNotNull(
              password, r'AdminLoginRequest', 'password'),
          deviceId: BuiltValueNullFieldError.checkNotNull(
              deviceId, r'AdminLoginRequest', 'deviceId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
