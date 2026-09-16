// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_applied_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PushAppliedResult extends PushAppliedResult {
  @override
  final JsonObject? status;
  @override
  final ObjectKind kind;
  @override
  final String id;
  @override
  final int revision;
  @override
  final int changeSequence;
  @override
  final DateTime changedAt;

  factory _$PushAppliedResult(
          [void Function(PushAppliedResultBuilder)? updates]) =>
      (PushAppliedResultBuilder()..update(updates))._build();

  _$PushAppliedResult._(
      {this.status,
      required this.kind,
      required this.id,
      required this.revision,
      required this.changeSequence,
      required this.changedAt})
      : super._();
  @override
  PushAppliedResult rebuild(void Function(PushAppliedResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PushAppliedResultBuilder toBuilder() =>
      PushAppliedResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PushAppliedResult &&
        status == other.status &&
        kind == other.kind &&
        id == other.id &&
        revision == other.revision &&
        changeSequence == other.changeSequence &&
        changedAt == other.changedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, changeSequence.hashCode);
    _$hash = $jc(_$hash, changedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PushAppliedResult')
          ..add('status', status)
          ..add('kind', kind)
          ..add('id', id)
          ..add('revision', revision)
          ..add('changeSequence', changeSequence)
          ..add('changedAt', changedAt))
        .toString();
  }
}

class PushAppliedResultBuilder
    implements Builder<PushAppliedResult, PushAppliedResultBuilder> {
  _$PushAppliedResult? _$v;

  JsonObject? _status;
  JsonObject? get status => _$this._status;
  set status(JsonObject? status) => _$this._status = status;

  ObjectKind? _kind;
  ObjectKind? get kind => _$this._kind;
  set kind(ObjectKind? kind) => _$this._kind = kind;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  int? _changeSequence;
  int? get changeSequence => _$this._changeSequence;
  set changeSequence(int? changeSequence) =>
      _$this._changeSequence = changeSequence;

  DateTime? _changedAt;
  DateTime? get changedAt => _$this._changedAt;
  set changedAt(DateTime? changedAt) => _$this._changedAt = changedAt;

  PushAppliedResultBuilder() {
    PushAppliedResult._defaults(this);
  }

  PushAppliedResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _kind = $v.kind;
      _id = $v.id;
      _revision = $v.revision;
      _changeSequence = $v.changeSequence;
      _changedAt = $v.changedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PushAppliedResult other) {
    _$v = other as _$PushAppliedResult;
  }

  @override
  void update(void Function(PushAppliedResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PushAppliedResult build() => _build();

  _$PushAppliedResult _build() {
    final _$result = _$v ??
        _$PushAppliedResult._(
          status: status,
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'PushAppliedResult', 'kind'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'PushAppliedResult', 'id'),
          revision: BuiltValueNullFieldError.checkNotNull(
              revision, r'PushAppliedResult', 'revision'),
          changeSequence: BuiltValueNullFieldError.checkNotNull(
              changeSequence, r'PushAppliedResult', 'changeSequence'),
          changedAt: BuiltValueNullFieldError.checkNotNull(
              changedAt, r'PushAppliedResult', 'changedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
