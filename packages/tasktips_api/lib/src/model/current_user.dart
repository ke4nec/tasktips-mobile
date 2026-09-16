//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'current_user.g.dart';

/// CurrentUser
///
/// Properties:
/// * [id] 
/// * [email] 
/// * [role] 
/// * [status] 
@BuiltValue()
abstract class CurrentUser implements Built<CurrentUser, CurrentUserBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'email')
  String get email;

  @BuiltValueField(wireName: r'role')
  CurrentUserRoleEnum get role;
  // enum roleEnum {  user,  system_admin,  };

  @BuiltValueField(wireName: r'status')
  CurrentUserStatusEnum get status;
  // enum statusEnum {  active,  disabled,  pending,  deleting,  };

  CurrentUser._();

  factory CurrentUser([void updates(CurrentUserBuilder b)]) = _$CurrentUser;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CurrentUserBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CurrentUser> get serializer => _$CurrentUserSerializer();
}

class _$CurrentUserSerializer implements PrimitiveSerializer<CurrentUser> {
  @override
  final Iterable<Type> types = const [CurrentUser, _$CurrentUser];

  @override
  final String wireName = r'CurrentUser';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CurrentUser object, {
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
      specifiedType: const FullType(CurrentUserRoleEnum),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(CurrentUserStatusEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CurrentUser object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CurrentUserBuilder result,
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
            specifiedType: const FullType(CurrentUserRoleEnum),
          ) as CurrentUserRoleEnum;
          result.role = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CurrentUserStatusEnum),
          ) as CurrentUserStatusEnum;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CurrentUser deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CurrentUserBuilder();
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


class CurrentUserRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'user')
  static const CurrentUserRoleEnum user = _$currentUserRoleEnum_user;
  @BuiltValueEnumConst(wireName: r'system_admin')
  static const CurrentUserRoleEnum systemAdmin = _$currentUserRoleEnum_systemAdmin;

  static Serializer<CurrentUserRoleEnum> get serializer => _$currentUserRoleEnumSerializer;

  const CurrentUserRoleEnum._(String name): super(name);

  static BuiltSet<CurrentUserRoleEnum> get values => _$currentUserRoleEnumValues;
  static CurrentUserRoleEnum valueOf(String name) => _$currentUserRoleEnumValueOf(name);
}

class CurrentUserStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'active')
  static const CurrentUserStatusEnum active = _$currentUserStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'disabled')
  static const CurrentUserStatusEnum disabled = _$currentUserStatusEnum_disabled;
  @BuiltValueEnumConst(wireName: r'pending')
  static const CurrentUserStatusEnum pending = _$currentUserStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'deleting')
  static const CurrentUserStatusEnum deleting = _$currentUserStatusEnum_deleting;

  static Serializer<CurrentUserStatusEnum> get serializer => _$currentUserStatusEnumSerializer;

  const CurrentUserStatusEnum._(String name): super(name);

  static BuiltSet<CurrentUserStatusEnum> get values => _$currentUserStatusEnumValues;
  static CurrentUserStatusEnum valueOf(String name) => _$currentUserStatusEnumValueOf(name);
}

