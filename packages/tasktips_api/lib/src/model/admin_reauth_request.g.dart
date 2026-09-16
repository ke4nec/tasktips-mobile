// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_reauth_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminReauthRequest extends AdminReauthRequest {
  @override
  final String password;

  factory _$AdminReauthRequest(
          [void Function(AdminReauthRequestBuilder)? updates]) =>
      (AdminReauthRequestBuilder()..update(updates))._build();

  _$AdminReauthRequest._({required this.password}) : super._();
  @override
  AdminReauthRequest rebuild(
          void Function(AdminReauthRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminReauthRequestBuilder toBuilder() =>
      AdminReauthRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminReauthRequest && password == other.password;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminReauthRequest')
          ..add('password', password))
        .toString();
  }
}

class AdminReauthRequestBuilder
    implements Builder<AdminReauthRequest, AdminReauthRequestBuilder> {
  _$AdminReauthRequest? _$v;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  AdminReauthRequestBuilder() {
    AdminReauthRequest._defaults(this);
  }

  AdminReauthRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _password = $v.password;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminReauthRequest other) {
    _$v = other as _$AdminReauthRequest;
  }

  @override
  void update(void Function(AdminReauthRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminReauthRequest build() => _build();

  _$AdminReauthRequest _build() {
    final _$result = _$v ??
        _$AdminReauthRequest._(
          password: BuiltValueNullFieldError.checkNotNull(
              password, r'AdminReauthRequest', 'password'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
