//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'restore_snapshot_request.g.dart';

/// RestoreSnapshotRequest
///
/// Properties:
/// * [snapshotId] 
/// * [reason] 
@BuiltValue()
abstract class RestoreSnapshotRequest implements Built<RestoreSnapshotRequest, RestoreSnapshotRequestBuilder> {
  @BuiltValueField(wireName: r'snapshotId')
  String get snapshotId;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  RestoreSnapshotRequest._();

  factory RestoreSnapshotRequest([void updates(RestoreSnapshotRequestBuilder b)]) = _$RestoreSnapshotRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RestoreSnapshotRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RestoreSnapshotRequest> get serializer => _$RestoreSnapshotRequestSerializer();
}

class _$RestoreSnapshotRequestSerializer implements PrimitiveSerializer<RestoreSnapshotRequest> {
  @override
  final Iterable<Type> types = const [RestoreSnapshotRequest, _$RestoreSnapshotRequest];

  @override
  final String wireName = r'RestoreSnapshotRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RestoreSnapshotRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'snapshotId';
    yield serializers.serialize(
      object.snapshotId,
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
    RestoreSnapshotRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RestoreSnapshotRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'snapshotId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.snapshotId = valueDes;
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
  RestoreSnapshotRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RestoreSnapshotRequestBuilder();
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


