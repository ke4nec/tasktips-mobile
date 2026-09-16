// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restore_sequence_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RestoreSequenceRequest extends RestoreSequenceRequest {
  @override
  final int targetChangeSequence;
  @override
  final String reason;

  factory _$RestoreSequenceRequest(
          [void Function(RestoreSequenceRequestBuilder)? updates]) =>
      (RestoreSequenceRequestBuilder()..update(updates))._build();

  _$RestoreSequenceRequest._(
      {required this.targetChangeSequence, required this.reason})
      : super._();
  @override
  RestoreSequenceRequest rebuild(
          void Function(RestoreSequenceRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RestoreSequenceRequestBuilder toBuilder() =>
      RestoreSequenceRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RestoreSequenceRequest &&
        targetChangeSequence == other.targetChangeSequence &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, targetChangeSequence.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RestoreSequenceRequest')
          ..add('targetChangeSequence', targetChangeSequence)
          ..add('reason', reason))
        .toString();
  }
}

class RestoreSequenceRequestBuilder
    implements Builder<RestoreSequenceRequest, RestoreSequenceRequestBuilder> {
  _$RestoreSequenceRequest? _$v;

  int? _targetChangeSequence;
  int? get targetChangeSequence => _$this._targetChangeSequence;
  set targetChangeSequence(int? targetChangeSequence) =>
      _$this._targetChangeSequence = targetChangeSequence;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  RestoreSequenceRequestBuilder() {
    RestoreSequenceRequest._defaults(this);
  }

  RestoreSequenceRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _targetChangeSequence = $v.targetChangeSequence;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RestoreSequenceRequest other) {
    _$v = other as _$RestoreSequenceRequest;
  }

  @override
  void update(void Function(RestoreSequenceRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RestoreSequenceRequest build() => _build();

  _$RestoreSequenceRequest _build() {
    final _$result = _$v ??
        _$RestoreSequenceRequest._(
          targetChangeSequence: BuiltValueNullFieldError.checkNotNull(
              targetChangeSequence,
              r'RestoreSequenceRequest',
              'targetChangeSequence'),
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'RestoreSequenceRequest', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
