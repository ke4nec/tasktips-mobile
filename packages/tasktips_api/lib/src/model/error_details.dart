//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:tasktips_api/src/model/object_kind.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'error_details.g.dart';

/// ErrorDetails
///
/// Properties:
/// * [expectedRevision] 
/// * [actualRevision] 
/// * [expectedGeneration] 
/// * [actualGeneration] 
/// * [kind] 
/// * [maxBytes] 
/// * [actualBytes] 
@BuiltValue()
abstract class ErrorDetails implements Built<ErrorDetails, ErrorDetailsBuilder> {
  @BuiltValueField(wireName: r'expectedRevision')
  int? get expectedRevision;

  @BuiltValueField(wireName: r'actualRevision')
  int? get actualRevision;

  @BuiltValueField(wireName: r'expectedGeneration')
  int? get expectedGeneration;

  @BuiltValueField(wireName: r'actualGeneration')
  int? get actualGeneration;

  @BuiltValueField(wireName: r'kind')
  ObjectKind? get kind;
  // enum kindEnum {  todo,  classification,  index,  image,  };

  @BuiltValueField(wireName: r'maxBytes')
  int? get maxBytes;

  @BuiltValueField(wireName: r'actualBytes')
  int? get actualBytes;

  ErrorDetails._();

  factory ErrorDetails([void updates(ErrorDetailsBuilder b)]) = _$ErrorDetails;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ErrorDetailsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ErrorDetails> get serializer => _$ErrorDetailsSerializer();
}

class _$ErrorDetailsSerializer implements PrimitiveSerializer<ErrorDetails> {
  @override
  final Iterable<Type> types = const [ErrorDetails, _$ErrorDetails];

  @override
  final String wireName = r'ErrorDetails';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ErrorDetails object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.expectedRevision != null) {
      yield r'expectedRevision';
      yield serializers.serialize(
        object.expectedRevision,
        specifiedType: const FullType(int),
      );
    }
    if (object.actualRevision != null) {
      yield r'actualRevision';
      yield serializers.serialize(
        object.actualRevision,
        specifiedType: const FullType(int),
      );
    }
    if (object.expectedGeneration != null) {
      yield r'expectedGeneration';
      yield serializers.serialize(
        object.expectedGeneration,
        specifiedType: const FullType(int),
      );
    }
    if (object.actualGeneration != null) {
      yield r'actualGeneration';
      yield serializers.serialize(
        object.actualGeneration,
        specifiedType: const FullType(int),
      );
    }
    if (object.kind != null) {
      yield r'kind';
      yield serializers.serialize(
        object.kind,
        specifiedType: const FullType(ObjectKind),
      );
    }
    if (object.maxBytes != null) {
      yield r'maxBytes';
      yield serializers.serialize(
        object.maxBytes,
        specifiedType: const FullType(int),
      );
    }
    if (object.actualBytes != null) {
      yield r'actualBytes';
      yield serializers.serialize(
        object.actualBytes,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ErrorDetails object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ErrorDetailsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'expectedGeneration':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.expectedGeneration = valueDes;
          break;
        case r'actualGeneration':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.actualGeneration = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ObjectKind),
          ) as ObjectKind?;
          if (valueDes == null) continue;
          result.kind = valueDes;
          break;
        case r'maxBytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.maxBytes = valueDes;
          break;
        case r'actualBytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.actualBytes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ErrorDetails deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ErrorDetailsBuilder();
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


