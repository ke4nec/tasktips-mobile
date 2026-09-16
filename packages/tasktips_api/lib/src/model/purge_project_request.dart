//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'purge_project_request.g.dart';

/// PurgeProjectRequest
///
/// Properties:
/// * [password] 
/// * [reason] 
@BuiltValue()
abstract class PurgeProjectRequest implements Built<PurgeProjectRequest, PurgeProjectRequestBuilder> {
  @BuiltValueField(wireName: r'password')
  String get password;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  PurgeProjectRequest._();

  factory PurgeProjectRequest([void updates(PurgeProjectRequestBuilder b)]) = _$PurgeProjectRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PurgeProjectRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PurgeProjectRequest> get serializer => _$PurgeProjectRequestSerializer();
}

class _$PurgeProjectRequestSerializer implements PrimitiveSerializer<PurgeProjectRequest> {
  @override
  final Iterable<Type> types = const [PurgeProjectRequest, _$PurgeProjectRequest];

  @override
  final String wireName = r'PurgeProjectRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PurgeProjectRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'password';
    yield serializers.serialize(
      object.password,
      specifiedType: const FullType(String),
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
    PurgeProjectRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PurgeProjectRequestBuilder result,
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
  PurgeProjectRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PurgeProjectRequestBuilder();
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


