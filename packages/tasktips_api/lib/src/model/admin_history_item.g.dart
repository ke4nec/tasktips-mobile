// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_history_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminHistoryItem extends AdminHistoryItem {
  @override
  final ObjectKind kind;
  @override
  final String objectId;
  @override
  final int revision;
  @override
  final int? baseRevision;
  @override
  final DateTime changedAt;
  @override
  final String deviceId;
  @override
  final bool tombstone;
  @override
  final int changeSequence;

  factory _$AdminHistoryItem(
          [void Function(AdminHistoryItemBuilder)? updates]) =>
      (AdminHistoryItemBuilder()..update(updates))._build();

  _$AdminHistoryItem._(
      {required this.kind,
      required this.objectId,
      required this.revision,
      this.baseRevision,
      required this.changedAt,
      required this.deviceId,
      required this.tombstone,
      required this.changeSequence})
      : super._();
  @override
  AdminHistoryItem rebuild(void Function(AdminHistoryItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminHistoryItemBuilder toBuilder() =>
      AdminHistoryItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminHistoryItem &&
        kind == other.kind &&
        objectId == other.objectId &&
        revision == other.revision &&
        baseRevision == other.baseRevision &&
        changedAt == other.changedAt &&
        deviceId == other.deviceId &&
        tombstone == other.tombstone &&
        changeSequence == other.changeSequence;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, objectId.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, baseRevision.hashCode);
    _$hash = $jc(_$hash, changedAt.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, tombstone.hashCode);
    _$hash = $jc(_$hash, changeSequence.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminHistoryItem')
          ..add('kind', kind)
          ..add('objectId', objectId)
          ..add('revision', revision)
          ..add('baseRevision', baseRevision)
          ..add('changedAt', changedAt)
          ..add('deviceId', deviceId)
          ..add('tombstone', tombstone)
          ..add('changeSequence', changeSequence))
        .toString();
  }
}

class AdminHistoryItemBuilder
    implements Builder<AdminHistoryItem, AdminHistoryItemBuilder> {
  _$AdminHistoryItem? _$v;

  ObjectKind? _kind;
  ObjectKind? get kind => _$this._kind;
  set kind(ObjectKind? kind) => _$this._kind = kind;

  String? _objectId;
  String? get objectId => _$this._objectId;
  set objectId(String? objectId) => _$this._objectId = objectId;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  int? _baseRevision;
  int? get baseRevision => _$this._baseRevision;
  set baseRevision(int? baseRevision) => _$this._baseRevision = baseRevision;

  DateTime? _changedAt;
  DateTime? get changedAt => _$this._changedAt;
  set changedAt(DateTime? changedAt) => _$this._changedAt = changedAt;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  bool? _tombstone;
  bool? get tombstone => _$this._tombstone;
  set tombstone(bool? tombstone) => _$this._tombstone = tombstone;

  int? _changeSequence;
  int? get changeSequence => _$this._changeSequence;
  set changeSequence(int? changeSequence) =>
      _$this._changeSequence = changeSequence;

  AdminHistoryItemBuilder() {
    AdminHistoryItem._defaults(this);
  }

  AdminHistoryItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _objectId = $v.objectId;
      _revision = $v.revision;
      _baseRevision = $v.baseRevision;
      _changedAt = $v.changedAt;
      _deviceId = $v.deviceId;
      _tombstone = $v.tombstone;
      _changeSequence = $v.changeSequence;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminHistoryItem other) {
    _$v = other as _$AdminHistoryItem;
  }

  @override
  void update(void Function(AdminHistoryItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminHistoryItem build() => _build();

  _$AdminHistoryItem _build() {
    final _$result = _$v ??
        _$AdminHistoryItem._(
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'AdminHistoryItem', 'kind'),
          objectId: BuiltValueNullFieldError.checkNotNull(
              objectId, r'AdminHistoryItem', 'objectId'),
          revision: BuiltValueNullFieldError.checkNotNull(
              revision, r'AdminHistoryItem', 'revision'),
          baseRevision: baseRevision,
          changedAt: BuiltValueNullFieldError.checkNotNull(
              changedAt, r'AdminHistoryItem', 'changedAt'),
          deviceId: BuiltValueNullFieldError.checkNotNull(
              deviceId, r'AdminHistoryItem', 'deviceId'),
          tombstone: BuiltValueNullFieldError.checkNotNull(
              tombstone, r'AdminHistoryItem', 'tombstone'),
          changeSequence: BuiltValueNullFieldError.checkNotNull(
              changeSequence, r'AdminHistoryItem', 'changeSequence'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
