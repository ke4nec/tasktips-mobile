// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminUserRoleEnum _$adminUserRoleEnum_user =
    const AdminUserRoleEnum._('user');
const AdminUserRoleEnum _$adminUserRoleEnum_systemAdmin =
    const AdminUserRoleEnum._('systemAdmin');

AdminUserRoleEnum _$adminUserRoleEnumValueOf(String name) {
  switch (name) {
    case 'user':
      return _$adminUserRoleEnum_user;
    case 'systemAdmin':
      return _$adminUserRoleEnum_systemAdmin;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdminUserRoleEnum> _$adminUserRoleEnumValues =
    BuiltSet<AdminUserRoleEnum>(const <AdminUserRoleEnum>[
  _$adminUserRoleEnum_user,
  _$adminUserRoleEnum_systemAdmin,
]);

const AdminUserStatusEnum _$adminUserStatusEnum_active =
    const AdminUserStatusEnum._('active');
const AdminUserStatusEnum _$adminUserStatusEnum_disabled =
    const AdminUserStatusEnum._('disabled');
const AdminUserStatusEnum _$adminUserStatusEnum_pending =
    const AdminUserStatusEnum._('pending');
const AdminUserStatusEnum _$adminUserStatusEnum_deleting =
    const AdminUserStatusEnum._('deleting');
const AdminUserStatusEnum _$adminUserStatusEnum_deleted =
    const AdminUserStatusEnum._('deleted');

AdminUserStatusEnum _$adminUserStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$adminUserStatusEnum_active;
    case 'disabled':
      return _$adminUserStatusEnum_disabled;
    case 'pending':
      return _$adminUserStatusEnum_pending;
    case 'deleting':
      return _$adminUserStatusEnum_deleting;
    case 'deleted':
      return _$adminUserStatusEnum_deleted;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdminUserStatusEnum> _$adminUserStatusEnumValues =
    BuiltSet<AdminUserStatusEnum>(const <AdminUserStatusEnum>[
  _$adminUserStatusEnum_active,
  _$adminUserStatusEnum_disabled,
  _$adminUserStatusEnum_pending,
  _$adminUserStatusEnum_deleting,
  _$adminUserStatusEnum_deleted,
]);

Serializer<AdminUserRoleEnum> _$adminUserRoleEnumSerializer =
    _$AdminUserRoleEnumSerializer();
Serializer<AdminUserStatusEnum> _$adminUserStatusEnumSerializer =
    _$AdminUserStatusEnumSerializer();

class _$AdminUserRoleEnumSerializer
    implements PrimitiveSerializer<AdminUserRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'user': 'user',
    'systemAdmin': 'system_admin',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'user': 'user',
    'system_admin': 'systemAdmin',
  };

  @override
  final Iterable<Type> types = const <Type>[AdminUserRoleEnum];
  @override
  final String wireName = 'AdminUserRoleEnum';

  @override
  Object serialize(Serializers serializers, AdminUserRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdminUserRoleEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdminUserRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AdminUserStatusEnumSerializer
    implements PrimitiveSerializer<AdminUserStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'disabled': 'disabled',
    'pending': 'pending',
    'deleting': 'deleting',
    'deleted': 'deleted',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'disabled': 'disabled',
    'pending': 'pending',
    'deleting': 'deleting',
    'deleted': 'deleted',
  };

  @override
  final Iterable<Type> types = const <Type>[AdminUserStatusEnum];
  @override
  final String wireName = 'AdminUserStatusEnum';

  @override
  Object serialize(Serializers serializers, AdminUserStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdminUserStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdminUserStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AdminUser extends AdminUser {
  @override
  final String id;
  @override
  final String email;
  @override
  final AdminUserRoleEnum role;
  @override
  final AdminUserStatusEnum status;
  @override
  final DateTime createdAt;
  @override
  final DateTime? lastLoginAt;

  factory _$AdminUser([void Function(AdminUserBuilder)? updates]) =>
      (AdminUserBuilder()..update(updates))._build();

  _$AdminUser._(
      {required this.id,
      required this.email,
      required this.role,
      required this.status,
      required this.createdAt,
      this.lastLoginAt})
      : super._();
  @override
  AdminUser rebuild(void Function(AdminUserBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminUserBuilder toBuilder() => AdminUserBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminUser &&
        id == other.id &&
        email == other.email &&
        role == other.role &&
        status == other.status &&
        createdAt == other.createdAt &&
        lastLoginAt == other.lastLoginAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, lastLoginAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminUser')
          ..add('id', id)
          ..add('email', email)
          ..add('role', role)
          ..add('status', status)
          ..add('createdAt', createdAt)
          ..add('lastLoginAt', lastLoginAt))
        .toString();
  }
}

class AdminUserBuilder implements Builder<AdminUser, AdminUserBuilder> {
  _$AdminUser? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  AdminUserRoleEnum? _role;
  AdminUserRoleEnum? get role => _$this._role;
  set role(AdminUserRoleEnum? role) => _$this._role = role;

  AdminUserStatusEnum? _status;
  AdminUserStatusEnum? get status => _$this._status;
  set status(AdminUserStatusEnum? status) => _$this._status = status;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _lastLoginAt;
  DateTime? get lastLoginAt => _$this._lastLoginAt;
  set lastLoginAt(DateTime? lastLoginAt) => _$this._lastLoginAt = lastLoginAt;

  AdminUserBuilder() {
    AdminUser._defaults(this);
  }

  AdminUserBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _email = $v.email;
      _role = $v.role;
      _status = $v.status;
      _createdAt = $v.createdAt;
      _lastLoginAt = $v.lastLoginAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminUser other) {
    _$v = other as _$AdminUser;
  }

  @override
  void update(void Function(AdminUserBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminUser build() => _build();

  _$AdminUser _build() {
    final _$result = _$v ??
        _$AdminUser._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'AdminUser', 'id'),
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'AdminUser', 'email'),
          role:
              BuiltValueNullFieldError.checkNotNull(role, r'AdminUser', 'role'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'AdminUser', 'status'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'AdminUser', 'createdAt'),
          lastLoginAt: lastLoginAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
