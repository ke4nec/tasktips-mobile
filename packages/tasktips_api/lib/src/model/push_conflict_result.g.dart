// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_conflict_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PushConflictResult extends PushConflictResult {
  @override
  final JsonObject? status;
  @override
  final ObjectKind kind;
  @override
  final String id;
  @override
  final int? expectedRevision;
  @override
  final int? actualRevision;

  factory _$PushConflictResult(
          [void Function(PushConflictResultBuilder)? updates]) =>
      (PushConflictResultBuilder()..update(updates))._build();

  _$PushConflictResult._(
      {this.status,
      required this.kind,
      required this.id,
      this.expectedRevision,
      this.actualRevision})
      : super._();
  @override
  PushConflictResult rebuild(
          void Function(PushConflictResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PushConflictResultBuilder toBuilder() =>
      PushConflictResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PushConflictResult &&
        status == other.status &&
        kind == other.kind &&
        id == other.id &&
        expectedRevision == other.expectedRevision &&
        actualRevision == other.actualRevision;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, expectedRevision.hashCode);
    _$hash = $jc(_$hash, actualRevision.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PushConflictResult')
          ..add('status', status)
          ..add('kind', kind)
          ..add('id', id)
          ..add('expectedRevision', expectedRevision)
          ..add('actualRevision', actualRevision))
        .toString();
  }
}

class PushConflictResultBuilder
    implements Builder<PushConflictResult, PushConflictResultBuilder> {
  _$PushConflictResult? _$v;

  JsonObject? _status;
  JsonObject? get status => _$this._status;
  set status(JsonObject? status) => _$this._status = status;

  ObjectKind? _kind;
  ObjectKind? get kind => _$this._kind;
  set kind(ObjectKind? kind) => _$this._kind = kind;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  int? _expectedRevision;
  int? get expectedRevision => _$this._expectedRevision;
  set expectedRevision(int? expectedRevision) =>
      _$this._expectedRevision = expectedRevision;

  int? _actualRevision;
  int? get actualRevision => _$this._actualRevision;
  set actualRevision(int? actualRevision) =>
      _$this._actualRevision = actualRevision;

  PushConflictResultBuilder() {
    PushConflictResult._defaults(this);
  }

  PushConflictResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _kind = $v.kind;
      _id = $v.id;
      _expectedRevision = $v.expectedRevision;
      _actualRevision = $v.actualRevision;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PushConflictResult other) {
    _$v = other as _$PushConflictResult;
  }

  @override
  void update(void Function(PushConflictResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PushConflictResult build() => _build();

  _$PushConflictResult _build() {
    final _$result = _$v ??
        _$PushConflictResult._(
          status: status,
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'PushConflictResult', 'kind'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'PushConflictResult', 'id'),
          expectedRevision: expectedRevision,
          actualRevision: actualRevision,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
