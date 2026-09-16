//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_invitation_response.g.dart';

/// CreateInvitationResponse
///
/// Properties:
/// * [id] 
/// * [email] 
/// * [invitationToken] 
/// * [expiresAt] 
@BuiltValue()
abstract class CreateInvitationResponse implements Built<CreateInvitationResponse, CreateInvitationResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'email')
  String get email;

  @BuiltValueField(wireName: r'invitationToken')
  String get invitationToken;

  @BuiltValueField(wireName: r'expiresAt')
  DateTime get expiresAt;

  CreateInvitationResponse._();

  factory CreateInvitationResponse([void updates(CreateInvitationResponseBuilder b)]) = _$CreateInvitationResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateInvitationResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateInvitationResponse> get serializer => _$CreateInvitationResponseSerializer();
}

class _$CreateInvitationResponseSerializer implements PrimitiveSerializer<CreateInvitationResponse> {
  @override
  final Iterable<Type> types = const [CreateInvitationResponse, _$CreateInvitationResponse];

  @override
  final String wireName = r'CreateInvitationResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateInvitationResponse object, {
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
    yield r'invitationToken';
    yield serializers.serialize(
      object.invitationToken,
      specifiedType: const FullType(String),
    );
    yield r'expiresAt';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateInvitationResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateInvitationResponseBuilder result,
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
        case r'invitationToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.invitationToken = valueDes;
          break;
        case r'expiresAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateInvitationResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateInvitationResponseBuilder();
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


