//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:tasktips_api/src/model/push_tombstone.dart';
import 'package:tasktips_api/src/model/push_object.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'push_request.g.dart';

/// PushRequest
///
/// Properties:
/// * [requestId] 
/// * [generation] 
/// * [objects] 
/// * [tombstones] 
@BuiltValue()
abstract class PushRequest implements Built<PushRequest, PushRequestBuilder> {
  @BuiltValueField(wireName: r'requestId')
  String get requestId;

  @BuiltValueField(wireName: r'generation')
  int get generation;

  @BuiltValueField(wireName: r'objects')
  BuiltList<PushObject> get objects;

  @BuiltValueField(wireName: r'tombstones')
  BuiltList<PushTombstone> get tombstones;

  PushRequest._();

  factory PushRequest([void updates(PushRequestBuilder b)]) = _$PushRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PushRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PushRequest> get serializer => _$PushRequestSerializer();
}

class _$PushRequestSerializer implements PrimitiveSerializer<PushRequest> {
  @override
  final Iterable<Type> types = const [PushRequest, _$PushRequest];

  @override
  final String wireName = r'PushRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PushRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'requestId';
    yield serializers.serialize(
      object.requestId,
      specifiedType: const FullType(String),
    );
    yield r'generation';
    yield serializers.serialize(
      object.generation,
      specifiedType: const FullType(int),
    );
    yield r'objects';
    yield serializers.serialize(
      object.objects,
      specifiedType: const FullType(BuiltList, [FullType(PushObject)]),
    );
    yield r'tombstones';
    yield serializers.serialize(
      object.tombstones,
      specifiedType: const FullType(BuiltList, [FullType(PushTombstone)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PushRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PushRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'requestId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.requestId = valueDes;
          break;
        case r'generation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.generation = valueDes;
          break;
        case r'objects':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(PushObject)]),
          ) as BuiltList<PushObject>;
          result.objects.replace(valueDes);
          break;
        case r'tombstones':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(PushTombstone)]),
          ) as BuiltList<PushTombstone>;
          result.tombstones.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PushRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PushRequestBuilder();
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


