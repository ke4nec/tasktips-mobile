// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_tombstone.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PushTombstone extends PushTombstone {
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

  factory _$PushTombstone([void Function(PushTombstoneBuilder)? updates]) =>
      (PushTombstoneBuilder()..update(updates))._build();

  _$PushTombstone._(
      {required this.kind,
      required this.id,
      required this.revision,
      this.baseRevision,
      required this.deletedAt,
      required this.deviceId})
      : super._();
  @override
  PushTombstone rebuild(void Function(PushTombstoneBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PushTombstoneBuilder toBuilder() => PushTombstoneBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PushTombstone &&
        kind == other.kind &&
        id == other.id &&
        revision == other.revision &&
        baseRevision == other.baseRevision &&
        deletedAt == other.deletedAt &&
        deviceId == other.deviceId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, baseRevision.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PushTombstone')
          ..add('kind', kind)
          ..add('id', id)
          ..add('revision', revision)
          ..add('baseRevision', baseRevision)
          ..add('deletedAt', deletedAt)
          ..add('deviceId', deviceId))
        .toString();
  }
}

class PushTombstoneBuilder
    implements Builder<PushTombstone, PushTombstoneBuilder> {
  _$PushTombstone? _$v;

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

  PushTombstoneBuilder() {
    PushTombstone._defaults(this);
  }

  PushTombstoneBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _id = $v.id;
      _revision = $v.revision;
      _baseRevision = $v.baseRevision;
      _deletedAt = $v.deletedAt;
      _deviceId = $v.deviceId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PushTombstone other) {
    _$v = other as _$PushTombstone;
  }

  @override
  void update(void Function(PushTombstoneBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PushTombstone build() => _build();

  _$PushTombstone _build() {
    final _$result = _$v ??
        _$PushTombstone._(
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'PushTombstone', 'kind'),
          id: BuiltValueNullFieldError.checkNotNull(id, r'PushTombstone', 'id'),
          revision: BuiltValueNullFieldError.checkNotNull(
              revision, r'PushTombstone', 'revision'),
          baseRevision: baseRevision,
          deletedAt: BuiltValueNullFieldError.checkNotNull(
              deletedAt, r'PushTombstone', 'deletedAt'),
          deviceId: BuiltValueNullFieldError.checkNotNull(
              deviceId, r'PushTombstone', 'deviceId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
