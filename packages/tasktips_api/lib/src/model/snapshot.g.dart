// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snapshot.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SnapshotStatusEnum _$snapshotStatusEnum_pending =
    const SnapshotStatusEnum._('pending');
const SnapshotStatusEnum _$snapshotStatusEnum_ready =
    const SnapshotStatusEnum._('ready');
const SnapshotStatusEnum _$snapshotStatusEnum_failed =
    const SnapshotStatusEnum._('failed');

SnapshotStatusEnum _$snapshotStatusEnumValueOf(String name) {
  switch (name) {
    case 'pending':
      return _$snapshotStatusEnum_pending;
    case 'ready':
      return _$snapshotStatusEnum_ready;
    case 'failed':
      return _$snapshotStatusEnum_failed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<SnapshotStatusEnum> _$snapshotStatusEnumValues =
    BuiltSet<SnapshotStatusEnum>(const <SnapshotStatusEnum>[
  _$snapshotStatusEnum_pending,
  _$snapshotStatusEnum_ready,
  _$snapshotStatusEnum_failed,
]);

Serializer<SnapshotStatusEnum> _$snapshotStatusEnumSerializer =
    _$SnapshotStatusEnumSerializer();

class _$SnapshotStatusEnumSerializer
    implements PrimitiveSerializer<SnapshotStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pending': 'pending',
    'ready': 'ready',
    'failed': 'failed',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pending': 'pending',
    'ready': 'ready',
    'failed': 'failed',
  };

  @override
  final Iterable<Type> types = const <Type>[SnapshotStatusEnum];
  @override
  final String wireName = 'SnapshotStatusEnum';

  @override
  Object serialize(Serializers serializers, SnapshotStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  SnapshotStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      SnapshotStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Snapshot extends Snapshot {
  @override
  final String id;
  @override
  final String projectId;
  @override
  final int generation;
  @override
  final int changeSequence;
  @override
  final String manifestHash;
  @override
  final SnapshotStatusEnum status;
  @override
  final String createdBy;
  @override
  final DateTime createdAt;

  factory _$Snapshot([void Function(SnapshotBuilder)? updates]) =>
      (SnapshotBuilder()..update(updates))._build();

  _$Snapshot._(
      {required this.id,
      required this.projectId,
      required this.generation,
      required this.changeSequence,
      required this.manifestHash,
      required this.status,
      required this.createdBy,
      required this.createdAt})
      : super._();
  @override
  Snapshot rebuild(void Function(SnapshotBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SnapshotBuilder toBuilder() => SnapshotBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Snapshot &&
        id == other.id &&
        projectId == other.projectId &&
        generation == other.generation &&
        changeSequence == other.changeSequence &&
        manifestHash == other.manifestHash &&
        status == other.status &&
        createdBy == other.createdBy &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, projectId.hashCode);
    _$hash = $jc(_$hash, generation.hashCode);
    _$hash = $jc(_$hash, changeSequence.hashCode);
    _$hash = $jc(_$hash, manifestHash.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, createdBy.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Snapshot')
          ..add('id', id)
          ..add('projectId', projectId)
          ..add('generation', generation)
          ..add('changeSequence', changeSequence)
          ..add('manifestHash', manifestHash)
          ..add('status', status)
          ..add('createdBy', createdBy)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class SnapshotBuilder implements Builder<Snapshot, SnapshotBuilder> {
  _$Snapshot? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _projectId;
  String? get projectId => _$this._projectId;
  set projectId(String? projectId) => _$this._projectId = projectId;

  int? _generation;
  int? get generation => _$this._generation;
  set generation(int? generation) => _$this._generation = generation;

  int? _changeSequence;
  int? get changeSequence => _$this._changeSequence;
  set changeSequence(int? changeSequence) =>
      _$this._changeSequence = changeSequence;

  String? _manifestHash;
  String? get manifestHash => _$this._manifestHash;
  set manifestHash(String? manifestHash) => _$this._manifestHash = manifestHash;

  SnapshotStatusEnum? _status;
  SnapshotStatusEnum? get status => _$this._status;
  set status(SnapshotStatusEnum? status) => _$this._status = status;

  String? _createdBy;
  String? get createdBy => _$this._createdBy;
  set createdBy(String? createdBy) => _$this._createdBy = createdBy;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  SnapshotBuilder() {
    Snapshot._defaults(this);
  }

  SnapshotBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _projectId = $v.projectId;
      _generation = $v.generation;
      _changeSequence = $v.changeSequence;
      _manifestHash = $v.manifestHash;
      _status = $v.status;
      _createdBy = $v.createdBy;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Snapshot other) {
    _$v = other as _$Snapshot;
  }

  @override
  void update(void Function(SnapshotBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Snapshot build() => _build();

  _$Snapshot _build() {
    final _$result = _$v ??
        _$Snapshot._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Snapshot', 'id'),
          projectId: BuiltValueNullFieldError.checkNotNull(
              projectId, r'Snapshot', 'projectId'),
          generation: BuiltValueNullFieldError.checkNotNull(
              generation, r'Snapshot', 'generation'),
          changeSequence: BuiltValueNullFieldError.checkNotNull(
              changeSequence, r'Snapshot', 'changeSequence'),
          manifestHash: BuiltValueNullFieldError.checkNotNull(
              manifestHash, r'Snapshot', 'manifestHash'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'Snapshot', 'status'),
          createdBy: BuiltValueNullFieldError.checkNotNull(
              createdBy, r'Snapshot', 'createdBy'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'Snapshot', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
