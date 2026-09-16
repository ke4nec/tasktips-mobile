//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_reauth_request.g.dart';

/// AdminReauthRequest
///
/// Properties:
/// * [password] 
@BuiltValue()
abstract class AdminReauthRequest implements Built<AdminReauthRequest, AdminReauthRequestBuilder> {
  @BuiltValueField(wireName: r'password')
  String get password;

  AdminReauthRequest._();

  factory AdminReauthRequest([void updates(AdminReauthRequestBuilder b)]) = _$AdminReauthRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminReauthRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminReauthRequest> get serializer => _$AdminReauthRequestSerializer();
}

class _$AdminReauthRequestSerializer implements PrimitiveSerializer<AdminReauthRequest> {
  @override
  final Iterable<Type> types = const [AdminReauthRequest, _$AdminReauthRequest];

  @override
  final String wireName = r'AdminReauthRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminReauthRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'password';
    yield serializers.serialize(
      object.password,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminReauthRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminReauthRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.password = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminReauthRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminReauthRequestBuilder();
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


