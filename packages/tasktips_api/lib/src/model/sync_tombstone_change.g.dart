// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_tombstone_change.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SyncTombstoneChange extends SyncTombstoneChange {
  @override
  final JsonObject? type;
  @override
  final ObjectKind kind;
  @override
  final String id;
  @override
  final int revision;
  @override
  final int? baseRevision;
  @override
  final DateTime deletedAt;
  @override
  final String deviceId;
  @override
  final int changeSequence;

  factory _$SyncTombstoneChange(
          [void Function(SyncTombstoneChangeBuilder)? updates]) =>
      (SyncTombstoneChangeBuilder()..update(updates))._build();

  _$SyncTombstoneChange._(
      {this.type,
      required this.kind,
      required this.id,
      required this.revision,
      this.baseRevision,
      required this.deletedAt,
      required this.deviceId,
      required this.changeSequence})
      : super._();
  @override
  SyncTombstoneChange rebuild(
          void Function(SyncTombstoneChangeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SyncTombstoneChangeBuilder toBuilder() =>
      SyncTombstoneChangeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SyncTombstoneChange &&
        type == other.type &&
        kind == other.kind &&
        id == other.id &&
        revision == other.revision &&
        baseRevision == other.baseRevision &&
        deletedAt == other.deletedAt &&
        deviceId == other.deviceId &&
        changeSequence == other.changeSequence;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, baseRevision.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, changeSequence.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SyncTombstoneChange')
          ..add('type', type)
          ..add('kind', kind)
          ..add('id', id)
          ..add('revision', revision)
          ..add('baseRevision', baseRevision)
          ..add('deletedAt', deletedAt)
          ..add('deviceId', deviceId)
          ..add('changeSequence', changeSequence))
        .toString();
  }
}

class SyncTombstoneChangeBuilder
    implements Builder<SyncTombstoneChange, SyncTombstoneChangeBuilder> {
  _$SyncTombstoneChange? _$v;

  JsonObject? _type;
  JsonObject? get type => _$this._type;
  set type(JsonObject? type) => _$this._type = type;

  ObjectKind? _kind;
  ObjectKind? get kind => _$this._kind;
  set kind(ObjectKind? kind) => _$this._kind = kind;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  int? _baseRevision;
  int? get baseRevision => _$this._baseRevision;
  set baseRevision(int? baseRevision) => _$this._baseRevision = baseRevision;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  int? _changeSequence;
  int? get changeSequence => _$this._changeSequence;
  set changeSequence(int? changeSequence) =>
      _$this._changeSequence = changeSequence;

  SyncTombstoneChangeBuilder() {
    SyncTombstoneChange._defaults(this);
  }

  SyncTombstoneChangeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _kind = $v.kind;
      _id = $v.id;
      _revision = $v.revision;
      _baseRevision = $v.baseRevision;
      _deletedAt = $v.deletedAt;
      _deviceId = $v.deviceId;
      _changeSequence = $v.changeSequence;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SyncTombstoneChange other) {
    _$v = other as _$SyncTombstoneChange;
  }

  @override
  void update(void Function(SyncTombstoneChangeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SyncTombstoneChange build() => _build();

  _$SyncTombstoneChange _build() {
    final _$result = _$v ??
        _$SyncTombstoneChange._(
          type: type,
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'SyncTombstoneChange', 'kind'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'SyncTombstoneChange', 'id'),
          revision: BuiltValueNullFieldError.checkNotNull(
              revision, r'SyncTombstoneChange', 'revision'),
          baseRevision: baseRevision,
          deletedAt: BuiltValueNullFieldError.checkNotNull(
              deletedAt, r'SyncTombstoneChange', 'deletedAt'),
          deviceId: BuiltValueNullFieldError.checkNotNull(
              deviceId, r'SyncTombstoneChange', 'deviceId'),
          changeSequence: BuiltValueNullFieldError.checkNotNull(
              changeSequence, r'SyncTombstoneChange', 'changeSequence'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
