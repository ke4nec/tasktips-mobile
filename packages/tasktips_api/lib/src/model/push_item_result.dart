//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:tasktips_api/src/model/error_code.dart';
import 'package:tasktips_api/src/model/push_applied_result.dart';
import 'package:tasktips_api/src/model/error_details.dart';
import 'package:tasktips_api/src/model/push_rejected_result.dart';
import 'package:tasktips_api/src/model/push_conflict_result.dart';
import 'package:tasktips_api/src/model/object_kind.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'push_item_result.g.dart';

/// PushItemResult
///
/// Properties:
/// * [status] 
/// * [kind] 
/// * [id] 
/// * [revision] 
/// * [changeSequence] 
/// * [changedAt] 
/// * [expectedRevision] 
/// * [actualRevision] 
/// * [code] 
/// * [message] 
/// * [details] 
@BuiltValue()
abstract class PushItemResult implements Built<PushItemResult, PushItemResultBuilder> {
  /// One Of [PushAppliedResult], [PushConflictResult], [PushRejectedResult]
  OneOf get oneOf;

  static const String discriminatorFieldName = r'status';

  static const Map<String, Type> discriminatorMapping = {
    r'PushAppliedResult': PushAppliedResult,
    r'PushConflictResult': PushConflictResult,
    r'PushRejectedResult': PushRejectedResult,
  };

  PushItemResult._();

  factory PushItemResult([void updates(PushItemResultBuilder b)]) = _$PushItemResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PushItemResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PushItemResult> get serializer => _$PushItemResultSerializer();
}

extension PushItemResultDiscriminatorExt on PushItemResult {
    String? get discriminatorValue {
        if (this is PushAppliedResult) {
            return r'PushAppliedResult';
        }
        if (this is PushConflictResult) {
            return r'PushConflictResult';
        }
        if (this is PushRejectedResult) {
            return r'PushRejectedResult';
        }
        return null;
    }
}
extension PushItemResultBuilderDiscriminatorExt on PushItemResultBuilder {
    String? get discriminatorValue {
        if (this is PushAppliedResultBuilder) {
            return r'PushAppliedResult';
        }
        if (this is PushConflictResultBuilder) {
            return r'PushConflictResult';
        }
        if (this is PushRejectedResultBuilder) {
            return r'PushRejectedResult';
        }
        return null;
    }
}

class _$PushItemResultSerializer implements PrimitiveSerializer<PushItemResult> {
  @override
  final Iterable<Type> types = const [PushItemResult, _$PushItemResult];

  @override
  final String wireName = r'PushItemResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PushItemResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    PushItemResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value, specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  PushItemResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PushItemResultBuilder();
    Object? oneOfDataSrc;
    final serializedList = (serialized as Iterable<Object?>).toList();
    final discIndex = serializedList.indexOf(PushItemResult.discriminatorFieldName) + 1;
    final discValue = serializers.deserialize(serializedList[discIndex], specifiedType: FullType(String)) as String;
    oneOfDataSrc = serialized;
    final oneOfTypes = [PushAppliedResult, PushConflictResult, PushRejectedResult, ];
    Object oneOfResult;
    Type oneOfType;
    switch (discValue) {
      case r'PushAppliedResult':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(PushAppliedResult),
        ) as PushAppliedResult;
        oneOfType = PushAppliedResult;
        break;
      case r'PushConflictResult':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(PushConflictResult),
        ) as PushConflictResult;
        oneOfType = PushConflictResult;
        break;
      case r'PushRejectedResult':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(PushRejectedResult),
        ) as PushRejectedResult;
        oneOfType = PushRejectedResult;
        break;
      default:
        throw UnsupportedError("Couldn't deserialize oneOf for the discriminator value: ${discValue}");
    }
    result.oneOf = OneOfDynamic(typeIndex: oneOfTypes.indexOf(oneOfType), types: oneOfTypes, value: oneOfResult);
    return result.build();
  }
}


