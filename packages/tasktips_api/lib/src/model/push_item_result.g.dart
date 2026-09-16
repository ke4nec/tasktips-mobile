// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_item_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PushItemResult extends PushItemResult {
  @override
  final OneOf oneOf;

  factory _$PushItemResult([void Function(PushItemResultBuilder)? updates]) =>
      (PushItemResultBuilder()..update(updates))._build();

  _$PushItemResult._({required this.oneOf}) : super._();
  @override
  PushItemResult rebuild(void Function(PushItemResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PushItemResultBuilder toBuilder() => PushItemResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PushItemResult && oneOf == other.oneOf;
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
    return (newBuiltValueToStringHelper(r'PushItemResult')..add('oneOf', oneOf))
        .toString();
  }
}

class PushItemResultBuilder
    implements Builder<PushItemResult, PushItemResultBuilder> {
  _$PushItemResult? _$v;

  OneOf? _oneOf;
  OneOf? get oneOf => _$this._oneOf;
  set oneOf(OneOf? oneOf) => _$this._oneOf = oneOf;

  PushItemResultBuilder() {
    PushItemResult._defaults(this);
  }

  PushItemResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _oneOf = $v.oneOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PushItemResult other) {
    _$v = other as _$PushItemResult;
  }

  @override
  void update(void Function(PushItemResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PushItemResult build() => _build();

  _$PushItemResult _build() {
    final _$result = _$v ??
        _$PushItemResult._(
          oneOf: BuiltValueNullFieldError.checkNotNull(
              oneOf, r'PushItemResult', 'oneOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
