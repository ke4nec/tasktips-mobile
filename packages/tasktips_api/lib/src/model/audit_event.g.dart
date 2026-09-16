// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_event.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuditEvent extends AuditEvent {
  @override
  final int id;
  @override
  final String? actorUserId;
  @override
  final String? subjectUserId;
  @override
  final String? projectId;
  @override
  final String action;
  @override
  final JsonObject metadata;
  @override
  final String? requestId;
  @override
  final DateTime createdAt;

  factory _$AuditEvent([void Function(AuditEventBuilder)? updates]) =>
      (AuditEventBuilder()..update(updates))._build();

  _$AuditEvent._(
      {required this.id,
      this.actorUserId,
      this.subjectUserId,
      this.projectId,
      required this.action,
      required this.metadata,
      this.requestId,
      required this.createdAt})
      : super._();
  @override
  AuditEvent rebuild(void Function(AuditEventBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuditEventBuilder toBuilder() => AuditEventBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuditEvent &&
        id == other.id &&
        actorUserId == other.actorUserId &&
        subjectUserId == other.subjectUserId &&
        projectId == other.projectId &&
        action == other.action &&
        metadata == other.metadata &&
        requestId == other.requestId &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, actorUserId.hashCode);
    _$hash = $jc(_$hash, subjectUserId.hashCode);
    _$hash = $jc(_$hash, projectId.hashCode);
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, metadata.hashCode);
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuditEvent')
          ..add('id', id)
          ..add('actorUserId', actorUserId)
          ..add('subjectUserId', subjectUserId)
          ..add('projectId', projectId)
          ..add('action', action)
          ..add('metadata', metadata)
          ..add('requestId', requestId)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class AuditEventBuilder implements Builder<AuditEvent, AuditEventBuilder> {
  _$AuditEvent? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  String? _actorUserId;
  String? get actorUserId => _$this._actorUserId;
  set actorUserId(String? actorUserId) => _$this._actorUserId = actorUserId;

  String? _subjectUserId;
  String? get subjectUserId => _$this._subjectUserId;
  set subjectUserId(String? subjectUserId) =>
      _$this._subjectUserId = subjectUserId;

  String? _projectId;
  String? get projectId => _$this._projectId;
  set projectId(String? projectId) => _$this._projectId = projectId;

  String? _action;
  String? get action => _$this._action;
  set action(String? action) => _$this._action = action;

  JsonObject? _metadata;
  JsonObject? get metadata => _$this._metadata;
  set metadata(JsonObject? metadata) => _$this._metadata = metadata;

  String? _requestId;
  String? get requestId => _$this._requestId;
  set requestId(String? requestId) => _$this._requestId = requestId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  AuditEventBuilder() {
    AuditEvent._defaults(this);
  }

  AuditEventBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _actorUserId = $v.actorUserId;
      _subjectUserId = $v.subjectUserId;
      _projectId = $v.projectId;
      _action = $v.action;
      _metadata = $v.metadata;
      _requestId = $v.requestId;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuditEvent other) {
    _$v = other as _$AuditEvent;
  }

  @override
  void update(void Function(AuditEventBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuditEvent build() => _build();

  _$AuditEvent _build() {
    final _$result = _$v ??
        _$AuditEvent._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'AuditEvent', 'id'),
          actorUserId: actorUserId,
          subjectUserId: subjectUserId,
          projectId: projectId,
          action: BuiltValueNullFieldError.checkNotNull(
              action, r'AuditEvent', 'action'),
          metadata: BuiltValueNullFieldError.checkNotNull(
              metadata, r'AuditEvent', 'metadata'),
          requestId: requestId,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'AuditEvent', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
