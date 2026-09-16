// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_object_change.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SyncObjectChange extends SyncObjectChange {
  @override
  final JsonObject? type;
  @override
  final ObjectKind kind;
  @override
  final String id;
  @override
  final int schemaVersion;
  @override
  final int revision;
  @override
  final int? baseRevision;
  @override
  final String contentHash;
  @override
  final DateTime updatedAt;
  @override
  final String deviceId;
  @override
  final int changeSequence;

  factory _$SyncObjectChange(
          [void Function(SyncObjectChangeBuilder)? updates]) =>
      (SyncObjectChangeBuilder()..update(updates))._build();

  _$SyncObjectChange._(
      {this.type,
      required this.kind,
      required this.id,
      required this.schemaVersion,
      required this.revision,
      this.baseRevision,
      required this.contentHash,
      required this.updatedAt,
      required this.deviceId,
      required this.changeSequence})
      : super._();
  @override
  SyncObjectChange rebuild(void Function(SyncObjectChangeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SyncObjectChangeBuilder toBuilder() =>
      SyncObjectChangeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SyncObjectChange &&
        type == other.type &&
        kind == other.kind &&
        id == other.id &&
        schemaVersion == other.schemaVersion &&
        revision == other.revision &&
        baseRevision == other.baseRevision &&
        contentHash == other.contentHash &&
        updatedAt == other.updatedAt &&
        deviceId == other.deviceId &&
        changeSequence == other.changeSequence;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, schemaVersion.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, baseRevision.hashCode);
    _$hash = $jc(_$hash, contentHash.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, changeSequence.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SyncObjectChange')
          ..add('type', type)
          ..add('kind', kind)
          ..add('id', id)
          ..add('schemaVersion', schemaVersion)
          ..add('revision', revision)
          ..add('baseRevision', baseRevision)
          ..add('contentHash', contentHash)
          ..add('updatedAt', updatedAt)
          ..add('deviceId', deviceId)
          ..add('changeSequence', changeSequence))
        .toString();
  }
}

class SyncObjectChangeBuilder
    implements Builder<SyncObjectChange, SyncObjectChangeBuilder> {
  _$SyncObjectChange? _$v;

  JsonObject? _type;
  JsonObject? get type => _$this._type;
  set type(JsonObject? type) => _$this._type = type;

  ObjectKind? _kind;
  ObjectKind? get kind => _$this._kind;
  set kind(ObjectKind? kind) => _$this._kind = kind;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  int? _schemaVersion;
  int? get schemaVersion => _$this._schemaVersion;
  set schemaVersion(int? schemaVersion) =>
      _$this._schemaVersion = schemaVersion;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  int? _baseRevision;
  int? get baseRevision => _$this._baseRevision;
  set baseRevision(int? baseRevision) => _$this._baseRevision = baseRevision;

  String? _contentHash;
  String? get contentHash => _$this._contentHash;
  set contentHash(String? contentHash) => _$this._contentHash = contentHash;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  int? _changeSequence;
  int? get changeSequence => _$this._changeSequence;
  set changeSequence(int? changeSequence) =>
      _$this._changeSequence = changeSequence;

  SyncObjectChangeBuilder() {
    SyncObjectChange._defaults(this);
  }

  SyncObjectChangeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _kind = $v.kind;
      _id = $v.id;
      _schemaVersion = $v.schemaVersion;
      _revision = $v.revision;
      _baseRevision = $v.baseRevision;
      _contentHash = $v.contentHash;
      _updatedAt = $v.updatedAt;
      _deviceId = $v.deviceId;
      _changeSequence = $v.changeSequence;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SyncObjectChange other) {
    _$v = other as _$SyncObjectChange;
  }

  @override
  void update(void Function(SyncObjectChangeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SyncObjectChange build() => _build();

  _$SyncObjectChange _build() {
    final _$result = _$v ??
        _$SyncObjectChange._(
          type: type,
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'SyncObjectChange', 'kind'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'SyncObjectChange', 'id'),
          schemaVersion: BuiltValueNullFieldError.checkNotNull(
              schemaVersion, r'SyncObjectChange', 'schemaVersion'),
          revision: BuiltValueNullFieldError.checkNotNull(
              revision, r'SyncObjectChange', 'revision'),
          baseRevision: baseRevision,
          contentHash: BuiltValueNullFieldError.checkNotNull(
              contentHash, r'SyncObjectChange', 'contentHash'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'SyncObjectChange', 'updatedAt'),
          deviceId: BuiltValueNullFieldError.checkNotNull(
              deviceId, r'SyncObjectChange', 'deviceId'),
          changeSequence: BuiltValueNullFieldError.checkNotNull(
              changeSequence, r'SyncObjectChange', 'changeSequence'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
