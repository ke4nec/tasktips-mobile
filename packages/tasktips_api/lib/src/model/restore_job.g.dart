// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restore_job.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RestoreJobStatusEnum _$restoreJobStatusEnum_queued =
    const RestoreJobStatusEnum._('queued');
const RestoreJobStatusEnum _$restoreJobStatusEnum_running =
    const RestoreJobStatusEnum._('running');
const RestoreJobStatusEnum _$restoreJobStatusEnum_succeeded =
    const RestoreJobStatusEnum._('succeeded');
const RestoreJobStatusEnum _$restoreJobStatusEnum_failed =
    const RestoreJobStatusEnum._('failed');
const RestoreJobStatusEnum _$restoreJobStatusEnum_cancelled =
    const RestoreJobStatusEnum._('cancelled');

RestoreJobStatusEnum _$restoreJobStatusEnumValueOf(String name) {
  switch (name) {
    case 'queued':
      return _$restoreJobStatusEnum_queued;
    case 'running':
      return _$restoreJobStatusEnum_running;
    case 'succeeded':
      return _$restoreJobStatusEnum_succeeded;
    case 'failed':
      return _$restoreJobStatusEnum_failed;
    case 'cancelled':
      return _$restoreJobStatusEnum_cancelled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RestoreJobStatusEnum> _$restoreJobStatusEnumValues =
    BuiltSet<RestoreJobStatusEnum>(const <RestoreJobStatusEnum>[
  _$restoreJobStatusEnum_queued,
  _$restoreJobStatusEnum_running,
  _$restoreJobStatusEnum_succeeded,
  _$restoreJobStatusEnum_failed,
  _$restoreJobStatusEnum_cancelled,
]);

Serializer<RestoreJobStatusEnum> _$restoreJobStatusEnumSerializer =
    _$RestoreJobStatusEnumSerializer();

class _$RestoreJobStatusEnumSerializer
    implements PrimitiveSerializer<RestoreJobStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'queued': 'queued',
    'running': 'running',
    'succeeded': 'succeeded',
    'failed': 'failed',
    'cancelled': 'cancelled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'queued': 'queued',
    'running': 'running',
    'succeeded': 'succeeded',
    'failed': 'failed',
    'cancelled': 'cancelled',
  };

  @override
  final Iterable<Type> types = const <Type>[RestoreJobStatusEnum];
  @override
  final String wireName = 'RestoreJobStatusEnum';

  @override
  Object serialize(Serializers serializers, RestoreJobStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RestoreJobStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RestoreJobStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RestoreJob extends RestoreJob {
  @override
  final String id;
  @override
  final String projectId;
  @override
  final String requestedBy;
  @override
  final String? snapshotId;
  @override
  final int? targetChangeSequence;
  @override
  final String reason;
  @override
  final RestoreJobStatusEnum status;
  @override
  final String? preRestoreSnapshotId;
  @override
  final int? generationBefore;
  @override
  final int? generationAfter;
  @override
  final int restoredObjects;
  @override
  final int restoredTombstones;
  @override
  final bool cancelRequested;
  @override
  final String? errorCode;
  @override
  final DateTime createdAt;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? finishedAt;
  @override
  final int? attempts;
  @override
  final DateTime? runAfter;

  factory _$RestoreJob([void Function(RestoreJobBuilder)? updates]) =>
      (RestoreJobBuilder()..update(updates))._build();

  _$RestoreJob._(
      {required this.id,
      required this.projectId,
      required this.requestedBy,
      this.snapshotId,
      this.targetChangeSequence,
      required this.reason,
      required this.status,
      this.preRestoreSnapshotId,
      this.generationBefore,
      this.generationAfter,
      required this.restoredObjects,
      required this.restoredTombstones,
      required this.cancelRequested,
      this.errorCode,
      required this.createdAt,
      this.startedAt,
      this.finishedAt,
      this.attempts,
      this.runAfter})
      : super._();
  @override
  RestoreJob rebuild(void Function(RestoreJobBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RestoreJobBuilder toBuilder() => RestoreJobBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RestoreJob &&
        id == other.id &&
        projectId == other.projectId &&
        requestedBy == other.requestedBy &&
        snapshotId == other.snapshotId &&
        targetChangeSequence == other.targetChangeSequence &&
        reason == other.reason &&
        status == other.status &&
        preRestoreSnapshotId == other.preRestoreSnapshotId &&
        generationBefore == other.generationBefore &&
        generationAfter == other.generationAfter &&
        restoredObjects == other.restoredObjects &&
        restoredTombstones == other.restoredTombstones &&
        cancelRequested == other.cancelRequested &&
        errorCode == other.errorCode &&
        createdAt == other.createdAt &&
        startedAt == other.startedAt &&
        finishedAt == other.finishedAt &&
        attempts == other.attempts &&
        runAfter == other.runAfter;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, projectId.hashCode);
    _$hash = $jc(_$hash, requestedBy.hashCode);
    _$hash = $jc(_$hash, snapshotId.hashCode);
    _$hash = $jc(_$hash, targetChangeSequence.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, preRestoreSnapshotId.hashCode);
    _$hash = $jc(_$hash, generationBefore.hashCode);
    _$hash = $jc(_$hash, generationAfter.hashCode);
    _$hash = $jc(_$hash, restoredObjects.hashCode);
    _$hash = $jc(_$hash, restoredTombstones.hashCode);
    _$hash = $jc(_$hash, cancelRequested.hashCode);
    _$hash = $jc(_$hash, errorCode.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, finishedAt.hashCode);
    _$hash = $jc(_$hash, attempts.hashCode);
    _$hash = $jc(_$hash, runAfter.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RestoreJob')
          ..add('id', id)
          ..add('projectId', projectId)
          ..add('requestedBy', requestedBy)
          ..add('snapshotId', snapshotId)
          ..add('targetChangeSequence', targetChangeSequence)
          ..add('reason', reason)
          ..add('status', status)
          ..add('preRestoreSnapshotId', preRestoreSnapshotId)
          ..add('generationBefore', generationBefore)
          ..add('generationAfter', generationAfter)
          ..add('restoredObjects', restoredObjects)
          ..add('restoredTombstones', restoredTombstones)
          ..add('cancelRequested', cancelRequested)
          ..add('errorCode', errorCode)
          ..add('createdAt', createdAt)
          ..add('startedAt', startedAt)
          ..add('finishedAt', finishedAt)
          ..add('attempts', attempts)
          ..add('runAfter', runAfter))
        .toString();
  }
}

class RestoreJobBuilder implements Builder<RestoreJob, RestoreJobBuilder> {
  _$RestoreJob? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _projectId;
  String? get projectId => _$this._projectId;
  set projectId(String? projectId) => _$this._projectId = projectId;

  String? _requestedBy;
  String? get requestedBy => _$this._requestedBy;
  set requestedBy(String? requestedBy) => _$this._requestedBy = requestedBy;

  String? _snapshotId;
  String? get snapshotId => _$this._snapshotId;
  set snapshotId(String? snapshotId) => _$this._snapshotId = snapshotId;

  int? _targetChangeSequence;
  int? get targetChangeSequence => _$this._targetChangeSequence;
  set targetChangeSequence(int? targetChangeSequence) =>
      _$this._targetChangeSequence = targetChangeSequence;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  RestoreJobStatusEnum? _status;
  RestoreJobStatusEnum? get status => _$this._status;
  set status(RestoreJobStatusEnum? status) => _$this._status = status;

  String? _preRestoreSnapshotId;
  String? get preRestoreSnapshotId => _$this._preRestoreSnapshotId;
  set preRestoreSnapshotId(String? preRestoreSnapshotId) =>
      _$this._preRestoreSnapshotId = preRestoreSnapshotId;

  int? _generationBefore;
  int? get generationBefore => _$this._generationBefore;
  set generationBefore(int? generationBefore) =>
      _$this._generationBefore = generationBefore;

  int? _generationAfter;
  int? get generationAfter => _$this._generationAfter;
  set generationAfter(int? generationAfter) =>
      _$this._generationAfter = generationAfter;

  int? _restoredObjects;
  int? get restoredObjects => _$this._restoredObjects;
  set restoredObjects(int? restoredObjects) =>
      _$this._restoredObjects = restoredObjects;

  int? _restoredTombstones;
  int? get restoredTombstones => _$this._restoredTombstones;
  set restoredTombstones(int? restoredTombstones) =>
      _$this._restoredTombstones = restoredTombstones;

  bool? _cancelRequested;
  bool? get cancelRequested => _$this._cancelRequested;
  set cancelRequested(bool? cancelRequested) =>
      _$this._cancelRequested = cancelRequested;

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

  int? _attempts;
  int? get attempts => _$this._attempts;
  set attempts(int? attempts) => _$this._attempts = attempts;

  DateTime? _runAfter;
  DateTime? get runAfter => _$this._runAfter;
  set runAfter(DateTime? runAfter) => _$this._runAfter = runAfter;

  RestoreJobBuilder() {
    RestoreJob._defaults(this);
  }

  RestoreJobBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _projectId = $v.projectId;
      _requestedBy = $v.requestedBy;
      _snapshotId = $v.snapshotId;
      _targetChangeSequence = $v.targetChangeSequence;
      _reason = $v.reason;
      _status = $v.status;
      _preRestoreSnapshotId = $v.preRestoreSnapshotId;
      _generationBefore = $v.generationBefore;
      _generationAfter = $v.generationAfter;
      _restoredObjects = $v.restoredObjects;
      _restoredTombstones = $v.restoredTombstones;
      _cancelRequested = $v.cancelRequested;
      _errorCode = $v.errorCode;
      _createdAt = $v.createdAt;
      _startedAt = $v.startedAt;
      _finishedAt = $v.finishedAt;
      _attempts = $v.attempts;
      _runAfter = $v.runAfter;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RestoreJob other) {
    _$v = other as _$RestoreJob;
  }

  @override
  void update(void Function(RestoreJobBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RestoreJob build() => _build();

  _$RestoreJob _build() {
    final _$result = _$v ??
        _$RestoreJob._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'RestoreJob', 'id'),
          projectId: BuiltValueNullFieldError.checkNotNull(
              projectId, r'RestoreJob', 'projectId'),
          requestedBy: BuiltValueNullFieldError.checkNotNull(
              requestedBy, r'RestoreJob', 'requestedBy'),
          snapshotId: snapshotId,
          targetChangeSequence: targetChangeSequence,
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'RestoreJob', 'reason'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'RestoreJob', 'status'),
          preRestoreSnapshotId: preRestoreSnapshotId,
          generationBefore: generationBefore,
          generationAfter: generationAfter,
          restoredObjects: BuiltValueNullFieldError.checkNotNull(
              restoredObjects, r'RestoreJob', 'restoredObjects'),
          restoredTombstones: BuiltValueNullFieldError.checkNotNull(
              restoredTombstones, r'RestoreJob', 'restoredTombstones'),
          cancelRequested: BuiltValueNullFieldError.checkNotNull(
              cancelRequested, r'RestoreJob', 'cancelRequested'),
          errorCode: errorCode,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'RestoreJob', 'createdAt'),
          startedAt: startedAt,
          finishedAt: finishedAt,
          attempts: attempts,
          runAfter: runAfter,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
