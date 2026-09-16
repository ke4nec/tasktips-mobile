//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'invitation_activation_request.g.dart';

/// InvitationActivationRequest
///
/// Properties:
/// * [invitationToken] 
/// * [password] 
/// * [deviceId] 
@BuiltValue()
abstract class InvitationActivationRequest implements Built<InvitationActivationRequest, InvitationActivationRequestBuilder> {
  @BuiltValueField(wireName: r'invitationToken')
  String get invitationToken;

  @BuiltValueField(wireName: r'password')
  String get password;

  @BuiltValueField(wireName: r'deviceId')
  String get deviceId;

  InvitationActivationRequest._();

  factory InvitationActivationRequest([void updates(InvitationActivationRequestBuilder b)]) = _$InvitationActivationRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InvitationActivationRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InvitationActivationRequest> get serializer => _$InvitationActivationRequestSerializer();
}

class _$InvitationActivationRequestSerializer implements PrimitiveSerializer<InvitationActivationRequest> {
  @override
  final Iterable<Type> types = const [InvitationActivationRequest, _$InvitationActivationRequest];

  @override
  final String wireName = r'InvitationActivationRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InvitationActivationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'invitationToken';
    yield serializers.serialize(
      object.invitationToken,
      specifiedType: const FullType(String),
    );
    yield r'password';
    yield serializers.serialize(
      object.password,
      specifiedType: const FullType(String),
    );
    yield r'deviceId';
    yield serializers.serialize(
      object.deviceId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    InvitationActivationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required InvitationActivationRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'invitationToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.invitationToken = valueDes;
          break;
        case r'password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.password = valueDes;
          break;
        case r'deviceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InvitationActivationRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InvitationActivationRequestBuilder();
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


