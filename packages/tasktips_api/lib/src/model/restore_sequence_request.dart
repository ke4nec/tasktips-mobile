//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'restore_sequence_request.g.dart';

/// RestoreSequenceRequest
///
/// Properties:
/// * [targetChangeSequence] 
/// * [reason] 
@BuiltValue()
abstract class RestoreSequenceRequest implements Built<RestoreSequenceRequest, RestoreSequenceRequestBuilder> {
  @BuiltValueField(wireName: r'targetChangeSequence')
  int get targetChangeSequence;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  RestoreSequenceRequest._();

  factory RestoreSequenceRequest([void updates(RestoreSequenceRequestBuilder b)]) = _$RestoreSequenceRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RestoreSequenceRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RestoreSequenceRequest> get serializer => _$RestoreSequenceRequestSerializer();
}

class _$RestoreSequenceRequestSerializer implements PrimitiveSerializer<RestoreSequenceRequest> {
  @override
  final Iterable<Type> types = const [RestoreSequenceRequest, _$RestoreSequenceRequest];

  @override
  final String wireName = r'RestoreSequenceRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RestoreSequenceRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'targetChangeSequence';
    yield serializers.serialize(
      object.targetChangeSequence,
      specifiedType: const FullType(int),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RestoreSequenceRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RestoreSequenceRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'targetChangeSequence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.targetChangeSequence = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RestoreSequenceRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RestoreSequenceRequestBuilder();
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


