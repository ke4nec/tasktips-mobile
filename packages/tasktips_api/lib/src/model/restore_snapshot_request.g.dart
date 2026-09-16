// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restore_snapshot_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RestoreSnapshotRequest extends RestoreSnapshotRequest {
  @override
  final String snapshotId;
  @override
  final String reason;

  factory _$RestoreSnapshotRequest(
          [void Function(RestoreSnapshotRequestBuilder)? updates]) =>
      (RestoreSnapshotRequestBuilder()..update(updates))._build();

  _$RestoreSnapshotRequest._({required this.snapshotId, required this.reason})
      : super._();
  @override
  RestoreSnapshotRequest rebuild(
          void Function(RestoreSnapshotRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RestoreSnapshotRequestBuilder toBuilder() =>
      RestoreSnapshotRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RestoreSnapshotRequest &&
        snapshotId == other.snapshotId &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, snapshotId.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RestoreSnapshotRequest')
          ..add('snapshotId', snapshotId)
          ..add('reason', reason))
        .toString();
  }
}

class RestoreSnapshotRequestBuilder
    implements Builder<RestoreSnapshotRequest, RestoreSnapshotRequestBuilder> {
  _$RestoreSnapshotRequest? _$v;

  String? _snapshotId;
  String? get snapshotId => _$this._snapshotId;
  set snapshotId(String? snapshotId) => _$this._snapshotId = snapshotId;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  RestoreSnapshotRequestBuilder() {
    RestoreSnapshotRequest._defaults(this);
  }

  RestoreSnapshotRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _snapshotId = $v.snapshotId;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RestoreSnapshotRequest other) {
    _$v = other as _$RestoreSnapshotRequest;
  }

  @override
  void update(void Function(RestoreSnapshotRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RestoreSnapshotRequest build() => _build();

  _$RestoreSnapshotRequest _build() {
    final _$result = _$v ??
        _$RestoreSnapshotRequest._(
          snapshotId: BuiltValueNullFieldError.checkNotNull(
              snapshotId, r'RestoreSnapshotRequest', 'snapshotId'),
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'RestoreSnapshotRequest', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
