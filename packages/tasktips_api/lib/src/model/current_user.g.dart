// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_user.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CurrentUserRoleEnum _$currentUserRoleEnum_user =
    const CurrentUserRoleEnum._('user');
const CurrentUserRoleEnum _$currentUserRoleEnum_systemAdmin =
    const CurrentUserRoleEnum._('systemAdmin');

CurrentUserRoleEnum _$currentUserRoleEnumValueOf(String name) {
  switch (name) {
    case 'user':
      return _$currentUserRoleEnum_user;
    case 'systemAdmin':
      return _$currentUserRoleEnum_systemAdmin;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CurrentUserRoleEnum> _$currentUserRoleEnumValues =
    BuiltSet<CurrentUserRoleEnum>(const <CurrentUserRoleEnum>[
  _$currentUserRoleEnum_user,
  _$currentUserRoleEnum_systemAdmin,
]);

const CurrentUserStatusEnum _$currentUserStatusEnum_active =
    const CurrentUserStatusEnum._('active');
const CurrentUserStatusEnum _$currentUserStatusEnum_disabled =
    const CurrentUserStatusEnum._('disabled');
const CurrentUserStatusEnum _$currentUserStatusEnum_pending =
    const CurrentUserStatusEnum._('pending');
const CurrentUserStatusEnum _$currentUserStatusEnum_deleting =
    const CurrentUserStatusEnum._('deleting');

CurrentUserStatusEnum _$currentUserStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$currentUserStatusEnum_active;
    case 'disabled':
      return _$currentUserStatusEnum_disabled;
    case 'pending':
      return _$currentUserStatusEnum_pending;
    case 'deleting':
      return _$currentUserStatusEnum_deleting;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CurrentUserStatusEnum> _$currentUserStatusEnumValues =
    BuiltSet<CurrentUserStatusEnum>(const <CurrentUserStatusEnum>[
  _$currentUserStatusEnum_active,
  _$currentUserStatusEnum_disabled,
  _$currentUserStatusEnum_pending,
  _$currentUserStatusEnum_deleting,
]);

Serializer<CurrentUserRoleEnum> _$currentUserRoleEnumSerializer =
    _$CurrentUserRoleEnumSerializer();
Serializer<CurrentUserStatusEnum> _$currentUserStatusEnumSerializer =
    _$CurrentUserStatusEnumSerializer();

class _$CurrentUserRoleEnumSerializer
    implements PrimitiveSerializer<CurrentUserRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'user': 'user',
    'systemAdmin': 'system_admin',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'user': 'user',
    'system_admin': 'systemAdmin',
  };

  @override
  final Iterable<Type> types = const <Type>[CurrentUserRoleEnum];
  @override
  final String wireName = 'CurrentUserRoleEnum';

  @override
  Object serialize(Serializers serializers, CurrentUserRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CurrentUserRoleEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CurrentUserRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CurrentUserStatusEnumSerializer
    implements PrimitiveSerializer<CurrentUserStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'disabled': 'disabled',
    'pending': 'pending',
    'deleting': 'deleting',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'disabled': 'disabled',
    'pending': 'pending',
    'deleting': 'deleting',
  };

  @override
  final Iterable<Type> types = const <Type>[CurrentUserStatusEnum];
  @override
  final String wireName = 'CurrentUserStatusEnum';

  @override
  Object serialize(Serializers serializers, CurrentUserStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CurrentUserStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CurrentUserStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CurrentUser extends CurrentUser {
  @override
  final String id;
  @override
  final String email;
  @override
  final CurrentUserRoleEnum role;
  @override
  final CurrentUserStatusEnum status;

  factory _$CurrentUser([void Function(CurrentUserBuilder)? updates]) =>
      (CurrentUserBuilder()..update(updates))._build();

  _$CurrentUser._(
      {required this.id,
      required this.email,
      required this.role,
      required this.status})
      : super._();
  @override
  CurrentUser rebuild(void Function(CurrentUserBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CurrentUserBuilder toBuilder() => CurrentUserBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CurrentUser &&
        id == other.id &&
        email == other.email &&
        role == other.role &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CurrentUser')
          ..add('id', id)
          ..add('email', email)
          ..add('role', role)
          ..add('status', status))
        .toString();
  }
}

class CurrentUserBuilder implements Builder<CurrentUser, CurrentUserBuilder> {
  _$CurrentUser? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  CurrentUserRoleEnum? _role;
  CurrentUserRoleEnum? get role => _$this._role;
  set role(CurrentUserRoleEnum? role) => _$this._role = role;

  CurrentUserStatusEnum? _status;
  CurrentUserStatusEnum? get status => _$this._status;
  set status(CurrentUserStatusEnum? status) => _$this._status = status;

  CurrentUserBuilder() {
    CurrentUser._defaults(this);
  }

  CurrentUserBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _email = $v.email;
      _role = $v.role;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CurrentUser other) {
    _$v = other as _$CurrentUser;
  }

  @override
  void update(void Function(CurrentUserBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CurrentUser build() => _build();

  _$CurrentUser _build() {
    final _$result = _$v ??
        _$CurrentUser._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'CurrentUser', 'id'),
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'CurrentUser', 'email'),
          role: BuiltValueNullFieldError.checkNotNull(
              role, r'CurrentUser', 'role'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'CurrentUser', 'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
