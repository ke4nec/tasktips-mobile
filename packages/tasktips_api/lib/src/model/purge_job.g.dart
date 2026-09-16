// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purge_job.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PurgeJobKindEnum _$purgeJobKindEnum_projectPurge =
    const PurgeJobKindEnum._('projectPurge');

PurgeJobKindEnum _$purgeJobKindEnumValueOf(String name) {
  switch (name) {
    case 'projectPurge':
      return _$purgeJobKindEnum_projectPurge;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PurgeJobKindEnum> _$purgeJobKindEnumValues =
    BuiltSet<PurgeJobKindEnum>(const <PurgeJobKindEnum>[
  _$purgeJobKindEnum_projectPurge,
]);

const PurgeJobStatusEnum _$purgeJobStatusEnum_queued =
    const PurgeJobStatusEnum._('queued');
const PurgeJobStatusEnum _$purgeJobStatusEnum_running =
    const PurgeJobStatusEnum._('running');
const PurgeJobStatusEnum _$purgeJobStatusEnum_succeeded =
    const PurgeJobStatusEnum._('succeeded');
const PurgeJobStatusEnum _$purgeJobStatusEnum_failed =
    const PurgeJobStatusEnum._('failed');

PurgeJobStatusEnum _$purgeJobStatusEnumValueOf(String name) {
  switch (name) {
    case 'queued':
      return _$purgeJobStatusEnum_queued;
    case 'running':
      return _$purgeJobStatusEnum_running;
    case 'succeeded':
      return _$purgeJobStatusEnum_succeeded;
    case 'failed':
      return _$purgeJobStatusEnum_failed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PurgeJobStatusEnum> _$purgeJobStatusEnumValues =
    BuiltSet<PurgeJobStatusEnum>(const <PurgeJobStatusEnum>[
  _$purgeJobStatusEnum_queued,
  _$purgeJobStatusEnum_running,
  _$purgeJobStatusEnum_succeeded,
  _$purgeJobStatusEnum_failed,
]);

Serializer<PurgeJobKindEnum> _$purgeJobKindEnumSerializer =
    _$PurgeJobKindEnumSerializer();
Serializer<PurgeJobStatusEnum> _$purgeJobStatusEnumSerializer =
    _$PurgeJobStatusEnumSerializer();

class _$PurgeJobKindEnumSerializer
    implements PrimitiveSerializer<PurgeJobKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'projectPurge': 'project_purge',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'project_purge': 'projectPurge',
  };

  @override
  final Iterable<Type> types = const <Type>[PurgeJobKindEnum];
  @override
  final String wireName = 'PurgeJobKindEnum';

  @override
  Object serialize(Serializers serializers, PurgeJobKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PurgeJobKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PurgeJobKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PurgeJobStatusEnumSerializer
    implements PrimitiveSerializer<PurgeJobStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'queued': 'queued',
    'running': 'running',
    'succeeded': 'succeeded',
    'failed': 'failed',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'queued': 'queued',
    'running': 'running',
    'succeeded': 'succeeded',
    'failed': 'failed',
  };

  @override
  final Iterable<Type> types = const <Type>[PurgeJobStatusEnum];
  @override
  final String wireName = 'PurgeJobStatusEnum';

  @override
  Object serialize(Serializers serializers, PurgeJobStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PurgeJobStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PurgeJobStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PurgeJob extends PurgeJob {
  @override
  final String id;
  @override
  final PurgeJobKindEnum kind;
  @override
  final String ownerUserId;
  @override
  final String projectId;
  @override
  final PurgeJobStatusEnum status;
  @override
  final int attempts;
  @override
  final DateTime runAfter;
  @override
  final String? errorCode;
  @override
  final DateTime createdAt;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? finishedAt;

  factory _$PurgeJob([void Function(PurgeJobBuilder)? updates]) =>
      (PurgeJobBuilder()..update(updates))._build();

  _$PurgeJob._(
      {required this.id,
      required this.kind,
      required this.ownerUserId,
      required this.projectId,
      required this.status,
      required this.attempts,
      required this.runAfter,
      this.errorCode,
      required this.createdAt,
      this.startedAt,
      this.finishedAt})
      : super._();
  @override
  PurgeJob rebuild(void Function(PurgeJobBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PurgeJobBuilder toBuilder() => PurgeJobBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PurgeJob &&
        id == other.id &&
        kind == other.kind &&
        ownerUserId == other.ownerUserId &&
        projectId == other.projectId &&
        status == other.status &&
        attempts == other.attempts &&
        runAfter == other.runAfter &&
        errorCode == other.errorCode &&
        createdAt == other.createdAt &&
        startedAt == other.startedAt &&
        finishedAt == other.finishedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, ownerUserId.hashCode);
    _$hash = $jc(_$hash, projectId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, attempts.hashCode);
    _$hash = $jc(_$hash, runAfter.hashCode);
    _$hash = $jc(_$hash, errorCode.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, finishedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PurgeJob')
          ..add('id', id)
          ..add('kind', kind)
          ..add('ownerUserId', ownerUserId)
          ..add('projectId', projectId)
          ..add('status', status)
          ..add('attempts', attempts)
          ..add('runAfter', runAfter)
          ..add('errorCode', errorCode)
          ..add('createdAt', createdAt)
          ..add('startedAt', startedAt)
          ..add('finishedAt', finishedAt))
        .toString();
  }
}

class PurgeJobBuilder implements Builder<PurgeJob, PurgeJobBuilder> {
  _$PurgeJob? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  PurgeJobKindEnum? _kind;
  PurgeJobKindEnum? get kind => _$this._kind;
  set kind(PurgeJobKindEnum? kind) => _$this._kind = kind;

  String? _ownerUserId;
  String? get ownerUserId => _$this._ownerUserId;
  set ownerUserId(String? ownerUserId) => _$this._ownerUserId = ownerUserId;

  String? _projectId;
  String? get projectId => _$this._projectId;
  set projectId(String? projectId) => _$this._projectId = projectId;

  PurgeJobStatusEnum? _status;
  PurgeJobStatusEnum? get status => _$this._status;
  set status(PurgeJobStatusEnum? status) => _$this._status = status;

  int? _attempts;
  int? get attempts => _$this._attempts;
  set attempts(int? attempts) => _$this._attempts = attempts;

  DateTime? _runAfter;
  DateTime? get runAfter => _$this._runAfter;
  set runAfter(DateTime? runAfter) => _$this._runAfter = runAfter;

  String? _errorCode;
  String? get errorCode => _$this._errorCode;
  set errorCode(String? errorCode) => _$this._errorCode = errorCode;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  DateTime? _finishedAt;
  DateTime? get finishedAt => _$this._finishedAt;
  set finishedAt(DateTime? finishedAt) => _$this._finishedAt = finishedAt;

  PurgeJobBuilder() {
    PurgeJob._defaults(this);
  }

  PurgeJobBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _kind = $v.kind;
      _ownerUserId = $v.ownerUserId;
      _projectId = $v.projectId;
      _status = $v.status;
      _attempts = $v.attempts;
      _runAfter = $v.runAfter;
      _errorCode = $v.errorCode;
      _createdAt = $v.createdAt;
      _startedAt = $v.startedAt;
      _finishedAt = $v.finishedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PurgeJob other) {
    _$v = other as _$PurgeJob;
  }

  @override
  void update(void Function(PurgeJobBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PurgeJob build() => _build();

  _$PurgeJob _build() {
    final _$result = _$v ??
        _$PurgeJob._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'PurgeJob', 'id'),
          kind:
              BuiltValueNullFieldError.checkNotNull(kind, r'PurgeJob', 'kind'),
          ownerUserId: BuiltValueNullFieldError.checkNotNull(
              ownerUserId, r'PurgeJob', 'ownerUserId'),
          projectId: BuiltValueNullFieldError.checkNotNull(
              projectId, r'PurgeJob', 'projectId'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'PurgeJob', 'status'),
          attempts: BuiltValueNullFieldError.checkNotNull(
              attempts, r'PurgeJob', 'attempts'),
          runAfter: BuiltValueNullFieldError.checkNotNull(
              runAfter, r'PurgeJob', 'runAfter'),
          errorCode: errorCode,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'PurgeJob', 'createdAt'),
          startedAt: startedAt,
          finishedAt: finishedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
