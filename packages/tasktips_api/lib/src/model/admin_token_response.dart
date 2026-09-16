//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_token_response.g.dart';

/// AdminTokenResponse
///
/// Properties:
/// * [accessToken] 
/// * [expiresIn] 
@BuiltValue()
abstract class AdminTokenResponse implements Built<AdminTokenResponse, AdminTokenResponseBuilder> {
  @BuiltValueField(wireName: r'accessToken')
  String get accessToken;

  @BuiltValueField(wireName: r'expiresIn')
  int get expiresIn;

  AdminTokenResponse._();

  factory AdminTokenResponse([void updates(AdminTokenResponseBuilder b)]) = _$AdminTokenResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminTokenResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminTokenResponse> get serializer => _$AdminTokenResponseSerializer();
}

class _$AdminTokenResponseSerializer implements PrimitiveSerializer<AdminTokenResponse> {
  @override
  final Iterable<Type> types = const [AdminTokenResponse, _$AdminTokenResponse];

  @override
  final String wireName = r'AdminTokenResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminTokenResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'accessToken';
    yield serializers.serialize(
      object.accessToken,
      specifiedType: const FullType(String),
    );
    yield r'expiresIn';
    yield serializers.serialize(
      object.expiresIn,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminTokenResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminTokenResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'accessToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.accessToken = valueDes;
          break;
        case r'expiresIn':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expiresIn = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminTokenResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminTokenResponseBuilder();
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


