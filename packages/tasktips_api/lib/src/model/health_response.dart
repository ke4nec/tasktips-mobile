//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'health_response.g.dart';

/// HealthResponse
///
/// Properties:
/// * [status] 
/// * [database] 
/// * [objectStore] 
@BuiltValue()
abstract class HealthResponse implements Built<HealthResponse, HealthResponseBuilder> {
  @BuiltValueField(wireName: r'status')
  HealthResponseStatusEnum get status;
  // enum statusEnum {  live,  ready,  notReady,  };

  @BuiltValueField(wireName: r'database')
  bool? get database;

  @BuiltValueField(wireName: r'objectStore')
  bool? get objectStore;

  HealthResponse._();

  factory HealthResponse([void updates(HealthResponseBuilder b)]) = _$HealthResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HealthResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HealthResponse> get serializer => _$HealthResponseSerializer();
}

class _$HealthResponseSerializer implements PrimitiveSerializer<HealthResponse> {
  @override
  final Iterable<Type> types = const [HealthResponse, _$HealthResponse];

  @override
  final String wireName = r'HealthResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HealthResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(HealthResponseStatusEnum),
    );
    yield r'database';
    yield object.database == null ? null : serializers.serialize(
      object.database,
      specifiedType: const FullType.nullable(bool),
    );
    yield r'objectStore';
    yield object.objectStore == null ? null : serializers.serialize(
      object.objectStore,
      specifiedType: const FullType.nullable(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    HealthResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required HealthResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HealthResponseStatusEnum),
          ) as HealthResponseStatusEnum;
          result.status = valueDes;
          break;
        case r'database':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.database = valueDes;
          break;
        case r'objectStore':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.objectStore = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  HealthResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HealthResponseBuilder();
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


class HealthResponseStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'live')
  static const HealthResponseStatusEnum live = _$healthResponseStatusEnum_live;
  @BuiltValueEnumConst(wireName: r'ready')
  static const HealthResponseStatusEnum ready = _$healthResponseStatusEnum_ready;
  @BuiltValueEnumConst(wireName: r'notReady')
  static const HealthResponseStatusEnum notReady = _$healthResponseStatusEnum_notReady;

  static Serializer<HealthResponseStatusEnum> get serializer => _$healthResponseStatusEnumSerializer;

  const HealthResponseStatusEnum._(String name): super(name);

  static BuiltSet<HealthResponseStatusEnum> get values => _$healthResponseStatusEnumValues;
  static HealthResponseStatusEnum valueOf(String name) => _$healthResponseStatusEnumValueOf(name);
}

