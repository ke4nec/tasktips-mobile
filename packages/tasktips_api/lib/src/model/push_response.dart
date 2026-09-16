//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:tasktips_api/src/model/push_item_result.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'push_response.g.dart';

/// PushResponse
///
/// Properties:
/// * [generation] 
/// * [results] 
@BuiltValue()
abstract class PushResponse implements Built<PushResponse, PushResponseBuilder> {
  @BuiltValueField(wireName: r'generation')
  int get generation;

  @BuiltValueField(wireName: r'results')
  BuiltList<PushItemResult> get results;

  PushResponse._();

  factory PushResponse([void updates(PushResponseBuilder b)]) = _$PushResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PushResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PushResponse> get serializer => _$PushResponseSerializer();
}

class _$PushResponseSerializer implements PrimitiveSerializer<PushResponse> {
  @override
  final Iterable<Type> types = const [PushResponse, _$PushResponse];

  @override
  final String wireName = r'PushResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PushResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'generation';
    yield serializers.serialize(
      object.generation,
      specifiedType: const FullType(int),
    );
    yield r'results';
    yield serializers.serialize(
      object.results,
      specifiedType: const FullType(BuiltList, [FullType(PushItemResult)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PushResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PushResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'generation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.generation = valueDes;
          break;
        case r'results':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(PushItemResult)]),
          ) as BuiltList<PushItemResult>;
          result.results.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PushResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PushResponseBuilder();
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


