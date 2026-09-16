// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_object.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PushObject extends PushObject {
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

  factory _$PushObject([void Function(PushObjectBuilder)? updates]) =>
      (PushObjectBuilder()..update(updates))._build();

  _$PushObject._(
      {required this.kind,
      required this.id,
      required this.schemaVersion,
      required this.revision,
      this.baseRevision,
      required this.contentHash,
      required this.updatedAt,
      required this.deviceId})
      : super._();
  @override
  PushObject rebuild(void Function(PushObjectBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PushObjectBuilder toBuilder() => PushObjectBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PushObject &&
        kind == other.kind &&
        id == other.id &&
        schemaVersion == other.schemaVersion &&
        revision == other.revision &&
        baseRevision == other.baseRevision &&
        contentHash == other.contentHash &&
        updatedAt == other.updatedAt &&
        deviceId == other.deviceId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, schemaVersion.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, baseRevision.hashCode);
    _$hash = $jc(_$hash, contentHash.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PushObject')
          ..add('kind', kind)
          ..add('id', id)
          ..add('schemaVersion', schemaVersion)
          ..add('revision', revision)
          ..add('baseRevision', baseRevision)
          ..add('contentHash', contentHash)
          ..add('updatedAt', updatedAt)
          ..add('deviceId', deviceId))
        .toString();
  }
}

class PushObjectBuilder implements Builder<PushObject, PushObjectBuilder> {
  _$PushObject? _$v;

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

  PushObjectBuilder() {
    PushObject._defaults(this);
  }

  PushObjectBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _id = $v.id;
      _schemaVersion = $v.schemaVersion;
      _revision = $v.revision;
      _baseRevision = $v.baseRevision;
      _contentHash = $v.contentHash;
      _updatedAt = $v.updatedAt;
      _deviceId = $v.deviceId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PushObject other) {
    _$v = other as _$PushObject;
  }

  @override
  void update(void Function(PushObjectBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PushObject build() => _build();

  _$PushObject _build() {
    final _$result = _$v ??
        _$PushObject._(
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'PushObject', 'kind'),
          id: BuiltValueNullFieldError.checkNotNull(id, r'PushObject', 'id'),
          schemaVersion: BuiltValueNullFieldError.checkNotNull(
              schemaVersion, r'PushObject', 'schemaVersion'),
          revision: BuiltValueNullFieldError.checkNotNull(
              revision, r'PushObject', 'revision'),
          baseRevision: baseRevision,
          contentHash: BuiltValueNullFieldError.checkNotNull(
              contentHash, r'PushObject', 'contentHash'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'PushObject', 'updatedAt'),
          deviceId: BuiltValueNullFieldError.checkNotNull(
              deviceId, r'PushObject', 'deviceId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
