//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:tasktips_api/src/model/object_kind.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'push_applied_result.g.dart';

/// PushAppliedResult
///
/// Properties:
/// * [status] 
/// * [kind] 
/// * [id] 
/// * [revision] 
/// * [changeSequence] 
/// * [changedAt] 
@BuiltValue()
abstract class PushAppliedResult implements Built<PushAppliedResult, PushAppliedResultBuilder> {
  @BuiltValueField(wireName: r'status')
  JsonObject? get status;

  @BuiltValueField(wireName: r'kind')
  ObjectKind get kind;
  // enum kindEnum {  todo,  classification,  index,  image,  };

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'revision')
  int get revision;

  @BuiltValueField(wireName: r'changeSequence')
  int get changeSequence;

  @BuiltValueField(wireName: r'changedAt')
  DateTime get changedAt;

  PushAppliedResult._();

  factory PushAppliedResult([void updates(PushAppliedResultBuilder b)]) = _$PushAppliedResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PushAppliedResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PushAppliedResult> get serializer => _$PushAppliedResultSerializer();
}

class _$PushAppliedResultSerializer implements PrimitiveSerializer<PushAppliedResult> {
  @override
  final Iterable<Type> types = const [PushAppliedResult, _$PushAppliedResult];

  @override
  final String wireName = r'PushAppliedResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PushAppliedResult object, {
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
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(int),
    );
    yield r'changeSequence';
    yield serializers.serialize(
      object.changeSequence,
      specifiedType: const FullType(int),
    );
    yield r'changedAt';
    yield serializers.serialize(
      object.changedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PushAppliedResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PushAppliedResultBuilder result,
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
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.revision = valueDes;
          break;
        case r'changeSequence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.changeSequence = valueDes;
          break;
        case r'changedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.changedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PushAppliedResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PushAppliedResultBuilder();
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


