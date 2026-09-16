// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reauth_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReauthResponse extends ReauthResponse {
  @override
  final String nonce;
  @override
  final int expiresIn;

  factory _$ReauthResponse([void Function(ReauthResponseBuilder)? updates]) =>
      (ReauthResponseBuilder()..update(updates))._build();

  _$ReauthResponse._({required this.nonce, required this.expiresIn})
      : super._();
  @override
  ReauthResponse rebuild(void Function(ReauthResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReauthResponseBuilder toBuilder() => ReauthResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReauthResponse &&
        nonce == other.nonce &&
        expiresIn == other.expiresIn;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, nonce.hashCode);
    _$hash = $jc(_$hash, expiresIn.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReauthResponse')
          ..add('nonce', nonce)
          ..add('expiresIn', expiresIn))
        .toString();
  }
}

class ReauthResponseBuilder
    implements Builder<ReauthResponse, ReauthResponseBuilder> {
  _$ReauthResponse? _$v;

  String? _nonce;
  String? get nonce => _$this._nonce;
  set nonce(String? nonce) => _$this._nonce = nonce;

  int? _expiresIn;
  int? get expiresIn => _$this._expiresIn;
  set expiresIn(int? expiresIn) => _$this._expiresIn = expiresIn;

  ReauthResponseBuilder() {
    ReauthResponse._defaults(this);
  }

  ReauthResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _nonce = $v.nonce;
      _expiresIn = $v.expiresIn;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReauthResponse other) {
    _$v = other as _$ReauthResponse;
  }

  @override
  void update(void Function(ReauthResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReauthResponse build() => _build();

  _$ReauthResponse _build() {
    final _$result = _$v ??
        _$ReauthResponse._(
          nonce: BuiltValueNullFieldError.checkNotNull(
              nonce, r'ReauthResponse', 'nonce'),
          expiresIn: BuiltValueNullFieldError.checkNotNull(
              expiresIn, r'ReauthResponse', 'expiresIn'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
