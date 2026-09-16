//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:tasktips_api/src/model/object_kind.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'push_conflict_result.g.dart';

/// PushConflictResult
///
/// Properties:
/// * [status] 
/// * [kind] 
/// * [id] 
/// * [expectedRevision] 
/// * [actualRevision] 
@BuiltValue()
abstract class PushConflictResult implements Built<PushConflictResult, PushConflictResultBuilder> {
  @BuiltValueField(wireName: r'status')
  JsonObject? get status;

  @BuiltValueField(wireName: r'kind')
  ObjectKind get kind;
  // enum kindEnum {  todo,  classification,  index,  image,  };

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'expectedRevision')
  int? get expectedRevision;

  @BuiltValueField(wireName: r'actualRevision')
  int? get actualRevision;

  PushConflictResult._();

  factory PushConflictResult([void updates(PushConflictResultBuilder b)]) = _$PushConflictResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PushConflictResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PushConflictResult> get serializer => _$PushConflictResultSerializer();
}

class _$PushConflictResultSerializer implements PrimitiveSerializer<PushConflictResult> {
  @override
  final Iterable<Type> types = const [PushConflictResult, _$PushConflictResult];

  @override
  final String wireName = r'PushConflictResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PushConflictResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield object.status == null ? null : serializers.serialize(
      object.status,
      specifiedType: const FullType.nullable(JsonObject),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(ObjectKind),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'expectedRevision';
    yield object.expectedRevision == null ? null : serializers.serialize(
      object.expectedRevision,
      specifiedType: const FullType.nullable(int),
    );
    yield r'actualRevision';
    yield object.actualRevision == null ? null : serializers.serialize(
      object.actualRevision,
      specifiedType: const FullType.nullable(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PushConflictResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PushConflictResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ObjectKind),
          ) as ObjectKind;
          result.kind = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'expectedRevision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.expectedRevision = valueDes;
          break;
        case r'actualRevision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.actualRevision = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PushConflictResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PushConflictResultBuilder();
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


