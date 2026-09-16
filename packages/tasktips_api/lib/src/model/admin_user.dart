//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_user.g.dart';

/// AdminUser
///
/// Properties:
/// * [id] 
/// * [email] 
/// * [role] 
/// * [status] 
/// * [createdAt] 
/// * [lastLoginAt] 
@BuiltValue()
abstract class AdminUser implements Built<AdminUser, AdminUserBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'email')
  String get email;

  @BuiltValueField(wireName: r'role')
  AdminUserRoleEnum get role;
  // enum roleEnum {  user,  system_admin,  };

  @BuiltValueField(wireName: r'status')
  AdminUserStatusEnum get status;
  // enum statusEnum {  active,  disabled,  pending,  deleting,  deleted,  };

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'lastLoginAt')
  DateTime? get lastLoginAt;

  AdminUser._();

  factory AdminUser([void updates(AdminUserBuilder b)]) = _$AdminUser;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminUserBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminUser> get serializer => _$AdminUserSerializer();
}

class _$AdminUserSerializer implements PrimitiveSerializer<AdminUser> {
  @override
  final Iterable<Type> types = const [AdminUser, _$AdminUser];

  @override
  final String wireName = r'AdminUser';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminUser object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(AdminUserRoleEnum),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(AdminUserStatusEnum),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.lastLoginAt != null) {
      yield r'lastLoginAt';
      yield serializers.serialize(
        object.lastLoginAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminUser object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminUserBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminUserRoleEnum),
          ) as AdminUserRoleEnum;
          result.role = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminUserStatusEnum),
          ) as AdminUserStatusEnum;
          result.status = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'lastLoginAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastLoginAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminUser deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminUserBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}


class AdminUserRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'user')
  static const AdminUserRoleEnum user = _$adminUserRoleEnum_user;
  @BuiltValueEnumConst(wireName: r'system_admin')
  static const AdminUserRoleEnum systemAdmin = _$adminUserRoleEnum_systemAdmin;

  static Serializer<AdminUserRoleEnum> get serializer => _$adminUserRoleEnumSerializer;

  const AdminUserRoleEnum._(String name): super(name);

  static BuiltSet<AdminUserRoleEnum> get values => _$adminUserRoleEnumValues;
  static AdminUserRoleEnum valueOf(String name) => _$adminUserRoleEnumValueOf(name);
}

class AdminUserStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'active')
  static const AdminUserStatusEnum active = _$adminUserStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'disabled')
  static const AdminUserStatusEnum disabled = _$adminUserStatusEnum_disabled;
  @BuiltValueEnumConst(wireName: r'pending')
  static const AdminUserStatusEnum pending = _$adminUserStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'deleting')
  static const AdminUserStatusEnum deleting = _$adminUserStatusEnum_deleting;
  @BuiltValueEnumConst(wireName: r'deleted')
  static const AdminUserStatusEnum deleted = _$adminUserStatusEnum_deleted;

  static Serializer<AdminUserStatusEnum> get serializer => _$adminUserStatusEnumSerializer;

  const AdminUserStatusEnum._(String name): super(name);

  static BuiltSet<AdminUserStatusEnum> get values => _$adminUserStatusEnumValues;
  static AdminUserStatusEnum valueOf(String name) => _$adminUserStatusEnumValueOf(name);
}

