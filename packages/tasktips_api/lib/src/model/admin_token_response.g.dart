// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_token_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminTokenResponse extends AdminTokenResponse {
  @override
  final String accessToken;
  @override
  final int expiresIn;

  factory _$AdminTokenResponse(
          [void Function(AdminTokenResponseBuilder)? updates]) =>
      (AdminTokenResponseBuilder()..update(updates))._build();

  _$AdminTokenResponse._({required this.accessToken, required this.expiresIn})
      : super._();
  @override
  AdminTokenResponse rebuild(
          void Function(AdminTokenResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminTokenResponseBuilder toBuilder() =>
      AdminTokenResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminTokenResponse &&
        accessToken == other.accessToken &&
        expiresIn == other.expiresIn;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accessToken.hashCode);
    _$hash = $jc(_$hash, expiresIn.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminTokenResponse')
          ..add('accessToken', accessToken)
          ..add('expiresIn', expiresIn))
        .toString();
  }
}

class AdminTokenResponseBuilder
    implements Builder<AdminTokenResponse, AdminTokenResponseBuilder> {
  _$AdminTokenResponse? _$v;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  int? _expiresIn;
  int? get expiresIn => _$this._expiresIn;
  set expiresIn(int? expiresIn) => _$this._expiresIn = expiresIn;

  AdminTokenResponseBuilder() {
    AdminTokenResponse._defaults(this);
  }

  AdminTokenResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accessToken = $v.accessToken;
      _expiresIn = $v.expiresIn;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminTokenResponse other) {
    _$v = other as _$AdminTokenResponse;
  }

  @override
  void update(void Function(AdminTokenResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminTokenResponse build() => _build();

  _$AdminTokenResponse _build() {
    final _$result = _$v ??
        _$AdminTokenResponse._(
          accessToken: BuiltValueNullFieldError.checkNotNull(
              accessToken, r'AdminTokenResponse', 'accessToken'),
          expiresIn: BuiltValueNullFieldError.checkNotNull(
              expiresIn, r'AdminTokenResponse', 'expiresIn'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
