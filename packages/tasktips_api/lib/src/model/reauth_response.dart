//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reauth_response.g.dart';

/// ReauthResponse
///
/// Properties:
/// * [nonce] 
/// * [expiresIn] 
@BuiltValue()
abstract class ReauthResponse implements Built<ReauthResponse, ReauthResponseBuilder> {
  @BuiltValueField(wireName: r'nonce')
  String get nonce;

  @BuiltValueField(wireName: r'expiresIn')
  int get expiresIn;

  ReauthResponse._();

  factory ReauthResponse([void updates(ReauthResponseBuilder b)]) = _$ReauthResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReauthResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReauthResponse> get serializer => _$ReauthResponseSerializer();
}

class _$ReauthResponseSerializer implements PrimitiveSerializer<ReauthResponse> {
  @override
  final Iterable<Type> types = const [ReauthResponse, _$ReauthResponse];

  @override
  final String wireName = r'ReauthResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReauthResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'nonce';
    yield serializers.serialize(
      object.nonce,
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
    ReauthResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReauthResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'nonce':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.nonce = valueDes;
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
  ReauthResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReauthResponseBuilder();
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


