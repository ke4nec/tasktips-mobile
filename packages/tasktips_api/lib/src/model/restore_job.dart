//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'restore_job.g.dart';

/// RestoreJob
///
/// Properties:
/// * [id] 
/// * [projectId] 
/// * [requestedBy] 
/// * [snapshotId] 
/// * [targetChangeSequence] 
/// * [reason] 
/// * [status] 
/// * [preRestoreSnapshotId] 
/// * [generationBefore] 
/// * [generationAfter] 
/// * [restoredObjects] 
/// * [restoredTombstones] 
/// * [cancelRequested] 
/// * [errorCode] 
/// * [createdAt] 
/// * [startedAt] 
/// * [finishedAt] 
/// * [attempts] 
/// * [runAfter] 
@BuiltValue()
abstract class RestoreJob implements Built<RestoreJob, RestoreJobBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'projectId')
  String get projectId;

  @BuiltValueField(wireName: r'requestedBy')
  String get requestedBy;

  @BuiltValueField(wireName: r'snapshotId')
  String? get snapshotId;

  @BuiltValueField(wireName: r'targetChangeSequence')
  int? get targetChangeSequence;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  @BuiltValueField(wireName: r'status')
  RestoreJobStatusEnum get status;
  // enum statusEnum {  queued,  running,  succeeded,  failed,  cancelled,  };

  @BuiltValueField(wireName: r'preRestoreSnapshotId')
  String? get preRestoreSnapshotId;

  @BuiltValueField(wireName: r'generationBefore')
  int? get generationBefore;

  @BuiltValueField(wireName: r'generationAfter')
  int? get generationAfter;

  @BuiltValueField(wireName: r'restoredObjects')
  int get restoredObjects;

  @BuiltValueField(wireName: r'restoredTombstones')
  int get restoredTombstones;

  @BuiltValueField(wireName: r'cancelRequested')
  bool get cancelRequested;

  @BuiltValueField(wireName: r'errorCode')
  String? get errorCode;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'startedAt')
  DateTime? get startedAt;

  @BuiltValueField(wireName: r'finishedAt')
  DateTime? get finishedAt;

  @BuiltValueField(wireName: r'attempts')
  int? get attempts;

  @BuiltValueField(wireName: r'runAfter')
  DateTime? get runAfter;

  RestoreJob._();

  factory RestoreJob([void updates(RestoreJobBuilder b)]) = _$RestoreJob;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RestoreJobBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RestoreJob> get serializer => _$RestoreJobSerializer();
}

class _$RestoreJobSerializer implements PrimitiveSerializer<RestoreJob> {
  @override
  final Iterable<Type> types = const [RestoreJob, _$RestoreJob];

  @override
  final String wireName = r'RestoreJob';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RestoreJob object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'projectId';
    yield serializers.serialize(
      object.projectId,
      specifiedType: const FullType(String),
    );
    yield r'requestedBy';
    yield serializers.serialize(
      object.requestedBy,
      specifiedType: const FullType(String),
    );
    if (object.snapshotId != null) {
      yield r'snapshotId';
      yield serializers.serialize(
        object.snapshotId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.targetChangeSequence != null) {
      yield r'targetChangeSequence';
      yield serializers.serialize(
        object.targetChangeSequence,
        specifiedType: const FullType.nullable(int),
      );
    }
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(RestoreJobStatusEnum),
    );
    if (object.preRestoreSnapshotId != null) {
      yield r'preRestoreSnapshotId';
      yield serializers.serialize(
        object.preRestoreSnapshotId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.generationBefore != null) {
      yield r'generationBefore';
      yield serializers.serialize(
        object.generationBefore,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.generationAfter != null) {
      yield r'generationAfter';
      yield serializers.serialize(
        object.generationAfter,
        specifiedType: const FullType.nullable(int),
      );
    }
    yield r'restoredObjects';
    yield serializers.serialize(
      object.restoredObjects,
      specifiedType: const FullType(int),
    );
    yield r'restoredTombstones';
    yield serializers.serialize(
      object.restoredTombstones,
      specifiedType: const FullType(int),
    );
    yield r'cancelRequested';
    yield serializers.serialize(
      object.cancelRequested,
      specifiedType: const FullType(bool),
    );
    if (object.errorCode != null) {
      yield r'errorCode';
      yield serializers.serialize(
        object.errorCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.startedAt != null) {
      yield r'startedAt';
      yield serializers.serialize(
        object.startedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.finishedAt != null) {
      yield r'finishedAt';
      yield serializers.serialize(
        object.finishedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.attempts != null) {
      yield r'attempts';
      yield serializers.serialize(
        object.attempts,
        specifiedType: const FullType(int),
      );
    }
    if (object.runAfter != null) {
      yield r'runAfter';
      yield serializers.serialize(
        object.runAfter,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RestoreJob object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RestoreJobBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'projectId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.projectId = valueDes;
          break;
        case r'requestedBy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.requestedBy = valueDes;
          break;
        case r'snapshotId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.snapshotId = valueDes;
          break;
        case r'targetChangeSequence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.targetChangeSequence = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RestoreJobStatusEnum),
          ) as RestoreJobStatusEnum;
          result.status = valueDes;
          break;
        case r'preRestoreSnapshotId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.preRestoreSnapshotId = valueDes;
          break;
        case r'generationBefore':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.generationBefore = valueDes;
          break;
        case r'generationAfter':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.generationAfter = valueDes;
          break;
        case r'restoredObjects':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.restoredObjects = valueDes;
          break;
        case r'restoredTombstones':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.restoredTombstones = valueDes;
          break;
        case r'cancelRequested':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.cancelRequested = valueDes;
          break;
        case r'errorCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.errorCode = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'startedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.startedAt = valueDes;
          break;
        case r'finishedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.finishedAt = valueDes;
          break;
        case r'attempts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.attempts = valueDes;
          break;
        case r'runAfter':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.runAfter = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RestoreJob deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RestoreJobBuilder();
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


class RestoreJobStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'queued')
  static const RestoreJobStatusEnum queued = _$restoreJobStatusEnum_queued;
  @BuiltValueEnumConst(wireName: r'running')
  static const RestoreJobStatusEnum running = _$restoreJobStatusEnum_running;
  @BuiltValueEnumConst(wireName: r'succeeded')
  static const RestoreJobStatusEnum succeeded = _$restoreJobStatusEnum_succeeded;
  @BuiltValueEnumConst(wireName: r'failed')
  static const RestoreJobStatusEnum failed = _$restoreJobStatusEnum_failed;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const RestoreJobStatusEnum cancelled = _$restoreJobStatusEnum_cancelled;

  static Serializer<RestoreJobStatusEnum> get serializer => _$restoreJobStatusEnumSerializer;

  const RestoreJobStatusEnum._(String name): super(name);

  static BuiltSet<RestoreJobStatusEnum> get values => _$restoreJobStatusEnumValues;
  static RestoreJobStatusEnum valueOf(String name) => _$restoreJobStatusEnumValueOf(name);
}

