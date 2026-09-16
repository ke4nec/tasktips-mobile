// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_operation.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminOperation extends AdminOperation {
  @override
  final String id;
  @override
  final String operation;
  @override
  final String status;
  @override
  final int attempts;
  @override
  final DateTime? runAfter;
  @override
  final bool cancelRequested;
  @override
  final String? projectId;
  @override
  final String? deviceId;
  @override
  final int? itemCount;
  @override
  final int? latencyMs;
  @override
  final String? errorCode;
  @override
  final DateTime createdAt;

  factory _$AdminOperation([void Function(AdminOperationBuilder)? updates]) =>
      (AdminOperationBuilder()..update(updates))._build();

  _$AdminOperation._(
      {required this.id,
      required this.operation,
      required this.status,
      required this.attempts,
      this.runAfter,
      required this.cancelRequested,
      this.projectId,
      this.deviceId,
      this.itemCount,
      this.latencyMs,
      this.errorCode,
      required this.createdAt})
      : super._();
  @override
  AdminOperation rebuild(void Function(AdminOperationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminOperationBuilder toBuilder() => AdminOperationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminOperation &&
        id == other.id &&
        operation == other.operation &&
        status == other.status &&
        attempts == other.attempts &&
        runAfter == other.runAfter &&
        cancelRequested == other.cancelRequested &&
        projectId == other.projectId &&
        deviceId == other.deviceId &&
        itemCount == other.itemCount &&
        latencyMs == other.latencyMs &&
        errorCode == other.errorCode &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, operation.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, attempts.hashCode);
    _$hash = $jc(_$hash, runAfter.hashCode);
    _$hash = $jc(_$hash, cancelRequested.hashCode);
    _$hash = $jc(_$hash, projectId.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, itemCount.hashCode);
    _$hash = $jc(_$hash, latencyMs.hashCode);
    _$hash = $jc(_$hash, errorCode.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminOperation')
          ..add('id', id)
          ..add('operation', operation)
          ..add('status', status)
          ..add('attempts', attempts)
          ..add('runAfter', runAfter)
          ..add('cancelRequested', cancelRequested)
          ..add('projectId', projectId)
          ..add('deviceId', deviceId)
          ..add('itemCount', itemCount)
          ..add('latencyMs', latencyMs)
          ..add('errorCode', errorCode)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class AdminOperationBuilder
    implements Builder<AdminOperation, AdminOperationBuilder> {
  _$AdminOperation? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _operation;
  String? get operation => _$this._operation;
  set operation(String? operation) => _$this._operation = operation;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  int? _attempts;
  int? get attempts => _$this._attempts;
  set attempts(int? attempts) => _$this._attempts = attempts;

  DateTime? _runAfter;
  DateTime? get runAfter => _$this._runAfter;
  set runAfter(DateTime? runAfter) => _$this._runAfter = runAfter;

  bool? _cancelRequested;
  bool? get cancelRequested => _$this._cancelRequested;
  set cancelRequested(bool? cancelRequested) =>
      _$this._cancelRequested = cancelRequested;

  String? _projectId;
  String? get projectId => _$this._projectId;
  set projectId(String? projectId) => _$this._projectId = projectId;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  int? _itemCount;
  int? get itemCount => _$this._itemCount;
  set itemCount(int? itemCount) => _$this._itemCount = itemCount;

  int? _latencyMs;
  int? get latencyMs => _$this._latencyMs;
  set latencyMs(int? latencyMs) => _$this._latencyMs = latencyMs;

  String? _errorCode;
  String? get errorCode => _$this._errorCode;
  set errorCode(String? errorCode) => _$this._errorCode = errorCode;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  AdminOperationBuilder() {
    AdminOperation._defaults(this);
  }

  AdminOperationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _operation = $v.operation;
      _status = $v.status;
      _attempts = $v.attempts;
      _runAfter = $v.runAfter;
      _cancelRequested = $v.cancelRequested;
      _projectId = $v.projectId;
      _deviceId = $v.deviceId;
      _itemCount = $v.itemCount;
      _latencyMs = $v.latencyMs;
      _errorCode = $v.errorCode;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminOperation other) {
    _$v = other as _$AdminOperation;
  }

  @override
  void update(void Function(AdminOperationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminOperation build() => _build();

  _$AdminOperation _build() {
    final _$result = _$v ??
        _$AdminOperation._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'AdminOperation', 'id'),
          operation: BuiltValueNullFieldError.checkNotNull(
              operation, r'AdminOperation', 'operation'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'AdminOperation', 'status'),
          attempts: BuiltValueNullFieldError.checkNotNull(
              attempts, r'AdminOperation', 'attempts'),
          runAfter: runAfter,
          cancelRequested: BuiltValueNullFieldError.checkNotNull(
              cancelRequested, r'AdminOperation', 'cancelRequested'),
          projectId: projectId,
          deviceId: deviceId,
          itemCount: itemCount,
          latencyMs: latencyMs,
          errorCode: errorCode,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'AdminOperation', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
