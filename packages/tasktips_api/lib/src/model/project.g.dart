// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ProjectStatusEnum _$projectStatusEnum_active =
    const ProjectStatusEnum._('active');
const ProjectStatusEnum _$projectStatusEnum_maintenance =
    const ProjectStatusEnum._('maintenance');
const ProjectStatusEnum _$projectStatusEnum_disabled =
    const ProjectStatusEnum._('disabled');
const ProjectStatusEnum _$projectStatusEnum_deleting =
    const ProjectStatusEnum._('deleting');

ProjectStatusEnum _$projectStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$projectStatusEnum_active;
    case 'maintenance':
      return _$projectStatusEnum_maintenance;
    case 'disabled':
      return _$projectStatusEnum_disabled;
    case 'deleting':
      return _$projectStatusEnum_deleting;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ProjectStatusEnum> _$projectStatusEnumValues =
    BuiltSet<ProjectStatusEnum>(const <ProjectStatusEnum>[
  _$projectStatusEnum_active,
  _$projectStatusEnum_maintenance,
  _$projectStatusEnum_disabled,
  _$projectStatusEnum_deleting,
]);

Serializer<ProjectStatusEnum> _$projectStatusEnumSerializer =
    _$ProjectStatusEnumSerializer();

class _$ProjectStatusEnumSerializer
    implements PrimitiveSerializer<ProjectStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'maintenance': 'maintenance',
    'disabled': 'disabled',
    'deleting': 'deleting',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'maintenance': 'maintenance',
    'disabled': 'disabled',
    'deleting': 'deleting',
  };

  @override
  final Iterable<Type> types = const <Type>[ProjectStatusEnum];
  @override
  final String wireName = 'ProjectStatusEnum';

  @override
  Object serialize(Serializers serializers, ProjectStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ProjectStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ProjectStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Project extends Project {
  @override
  final String id;
  @override
  final String ownerUserId;
  @override
  final String name;
  @override
  final int generation;
  @override
  final ProjectStatusEnum status;
  @override
  final int changeSequence;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$Project([void Function(ProjectBuilder)? updates]) =>
      (ProjectBuilder()..update(updates))._build();

  _$Project._(
      {required this.id,
      required this.ownerUserId,
      required this.name,
      required this.generation,
      required this.status,
      required this.changeSequence,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  Project rebuild(void Function(ProjectBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProjectBuilder toBuilder() => ProjectBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Project &&
        id == other.id &&
        ownerUserId == other.ownerUserId &&
        name == other.name &&
        generation == other.generation &&
        status == other.status &&
        changeSequence == other.changeSequence &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, ownerUserId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, generation.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, changeSequence.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Project')
          ..add('id', id)
          ..add('ownerUserId', ownerUserId)
          ..add('name', name)
          ..add('generation', generation)
          ..add('status', status)
          ..add('changeSequence', changeSequence)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class ProjectBuilder implements Builder<Project, ProjectBuilder> {
  _$Project? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _ownerUserId;
  String? get ownerUserId => _$this._ownerUserId;
  set ownerUserId(String? ownerUserId) => _$this._ownerUserId = ownerUserId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _generation;
  int? get generation => _$this._generation;
  set generation(int? generation) => _$this._generation = generation;

  ProjectStatusEnum? _status;
  ProjectStatusEnum? get status => _$this._status;
  set status(ProjectStatusEnum? status) => _$this._status = status;

  int? _changeSequence;
  int? get changeSequence => _$this._changeSequence;
  set changeSequence(int? changeSequence) =>
      _$this._changeSequence = changeSequence;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  ProjectBuilder() {
    Project._defaults(this);
  }

  ProjectBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _ownerUserId = $v.ownerUserId;
      _name = $v.name;
      _generation = $v.generation;
      _status = $v.status;
      _changeSequence = $v.changeSequence;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Project other) {
    _$v = other as _$Project;
  }

  @override
  void update(void Function(ProjectBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Project build() => _build();

  _$Project _build() {
    final _$result = _$v ??
        _$Project._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Project', 'id'),
          ownerUserId: BuiltValueNullFieldError.checkNotNull(
              ownerUserId, r'Project', 'ownerUserId'),
          name: BuiltValueNullFieldError.checkNotNull(name, r'Project', 'name'),
          generation: BuiltValueNullFieldError.checkNotNull(
              generation, r'Project', 'generation'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'Project', 'status'),
          changeSequence: BuiltValueNullFieldError.checkNotNull(
              changeSequence, r'Project', 'changeSequence'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'Project', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'Project', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
