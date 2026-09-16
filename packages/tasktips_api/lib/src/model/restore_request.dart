//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:tasktips_api/src/model/restore_snapshot_request.dart';
import 'package:tasktips_api/src/model/restore_sequence_request.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'restore_request.g.dart';

/// RestoreRequest
///
/// Properties:
/// * [snapshotId] 
/// * [reason] 
/// * [targetChangeSequence] 
@BuiltValue()
abstract class RestoreRequest implements Built<RestoreRequest, RestoreRequestBuilder> {
  /// One Of [RestoreSequenceRequest], [RestoreSnapshotRequest]
  OneOf get oneOf;

  RestoreRequest._();

  factory RestoreRequest([void updates(RestoreRequestBuilder b)]) = _$RestoreRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RestoreRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RestoreRequest> get serializer => _$RestoreRequestSerializer();
}

class _$RestoreRequestSerializer implements PrimitiveSerializer<RestoreRequest> {
  @override
  final Iterable<Type> types = const [RestoreRequest, _$RestoreRequest];

  @override
  final String wireName = r'RestoreRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RestoreRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    RestoreRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value, specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  RestoreRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RestoreRequestBuilder();
    Object? oneOfDataSrc;
    final targetType = const FullType(OneOf, [FullType(RestoreSnapshotRequest), FullType(RestoreSequenceRequest), ]);
    oneOfDataSrc = serialized;
    result.oneOf = serializers.deserialize(oneOfDataSrc, specifiedType: targetType) as OneOf;
    return result.build();
  }
}


