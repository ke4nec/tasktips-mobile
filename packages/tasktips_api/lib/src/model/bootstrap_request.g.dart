// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bootstrap_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BootstrapRequest extends BootstrapRequest {
  @override
  final String? pageToken;
  @override
  final int? limit;

  factory _$BootstrapRequest(
          [void Function(BootstrapRequestBuilder)? updates]) =>
      (BootstrapRequestBuilder()..update(updates))._build();

  _$BootstrapRequest._({this.pageToken, this.limit}) : super._();
  @override
  BootstrapRequest rebuild(void Function(BootstrapRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BootstrapRequestBuilder toBuilder() =>
      BootstrapRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BootstrapRequest &&
        pageToken == other.pageToken &&
        limit == other.limit;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, pageToken.hashCode);
    _$hash = $jc(_$hash, limit.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BootstrapRequest')
          ..add('pageToken', pageToken)
          ..add('limit', limit))
        .toString();
  }
}

class BootstrapRequestBuilder
    implements Builder<BootstrapRequest, BootstrapRequestBuilder> {
  _$BootstrapRequest? _$v;

  String? _pageToken;
  String? get pageToken => _$this._pageToken;
  set pageToken(String? pageToken) => _$this._pageToken = pageToken;

  int? _limit;
  int? get limit => _$this._limit;
  set limit(int? limit) => _$this._limit = limit;

  BootstrapRequestBuilder() {
    BootstrapRequest._defaults(this);
  }

  BootstrapRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _pageToken = $v.pageToken;
      _limit = $v.limit;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BootstrapRequest other) {
    _$v = other as _$BootstrapRequest;
  }

  @override
  void update(void Function(BootstrapRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BootstrapRequest build() => _build();

  _$BootstrapRequest _build() {
    final _$result = _$v ??
        _$BootstrapRequest._(
          pageToken: pageToken,
          limit: limit,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
