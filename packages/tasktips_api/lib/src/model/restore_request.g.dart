// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restore_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RestoreRequest extends RestoreRequest {
  @override
  final OneOf oneOf;

  factory _$RestoreRequest([void Function(RestoreRequestBuilder)? updates]) =>
      (RestoreRequestBuilder()..update(updates))._build();

  _$RestoreRequest._({required this.oneOf}) : super._();
  @override
  RestoreRequest rebuild(void Function(RestoreRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RestoreRequestBuilder toBuilder() => RestoreRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RestoreRequest && oneOf == other.oneOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, oneOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RestoreRequest')..add('oneOf', oneOf))
        .toString();
  }
}

class RestoreRequestBuilder
    implements Builder<RestoreRequest, RestoreRequestBuilder> {
  _$RestoreRequest? _$v;

  OneOf? _oneOf;
  OneOf? get oneOf => _$this._oneOf;
  set oneOf(OneOf? oneOf) => _$this._oneOf = oneOf;

  RestoreRequestBuilder() {
    RestoreRequest._defaults(this);
  }

  RestoreRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _oneOf = $v.oneOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RestoreRequest other) {
    _$v = other as _$RestoreRequest;
  }

  @override
  void update(void Function(RestoreRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RestoreRequest build() => _build();

  _$RestoreRequest _build() {
    final _$result = _$v ??
        _$RestoreRequest._(
          oneOf: BuiltValueNullFieldError.checkNotNull(
              oneOf, r'RestoreRequest', 'oneOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
