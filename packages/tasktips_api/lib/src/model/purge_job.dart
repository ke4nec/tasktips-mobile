//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'purge_job.g.dart';

/// PurgeJob
///
/// Properties:
/// * [id] 
/// * [kind] 
/// * [ownerUserId] 
/// * [projectId] 
/// * [status] 
/// * [attempts] 
/// * [runAfter] 
/// * [errorCode] 
/// * [createdAt] 
/// * [startedAt] 
/// * [finishedAt] 
@BuiltValue()
abstract class PurgeJob implements Built<PurgeJob, PurgeJobBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'kind')
  PurgeJobKindEnum get kind;
  // enum kindEnum {  project_purge,  };

  @BuiltValueField(wireName: r'ownerUserId')
  String get ownerUserId;

  @BuiltValueField(wireName: r'projectId')
  String get projectId;

  @BuiltValueField(wireName: r'status')
  PurgeJobStatusEnum get status;
  // enum statusEnum {  queued,  running,  succeeded,  failed,  };

  @BuiltValueField(wireName: r'attempts')
  int get attempts;

  @BuiltValueField(wireName: r'runAfter')
  DateTime get runAfter;

  @BuiltValueField(wireName: r'errorCode')
  String? get errorCode;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'startedAt')
  DateTime? get startedAt;

  @BuiltValueField(wireName: r'finishedAt')
  DateTime? get finishedAt;

  PurgeJob._();

  factory PurgeJob([void updates(PurgeJobBuilder b)]) = _$PurgeJob;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PurgeJobBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PurgeJob> get serializer => _$PurgeJobSerializer();
}

class _$PurgeJobSerializer implements PrimitiveSerializer<PurgeJob> {
  @override
  final Iterable<Type> types = const [PurgeJob, _$PurgeJob];

  @override
  final String wireName = r'PurgeJob';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PurgeJob object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(PurgeJobKindEnum),
    );
    yield r'ownerUserId';
    yield serializers.serialize(
      object.ownerUserId,
      specifiedType: const FullType(String),
    );
    yield r'projectId';
    yield serializers.serialize(
      object.projectId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(PurgeJobStatusEnum),
    );
    yield r'attempts';
    yield serializers.serialize(
      object.attempts,
      specifiedType: const FullType(int),
    );
    yield r'runAfter';
    yield serializers.serialize(
      object.runAfter,
      specifiedType: const FullType(DateTime),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    PurgeJob object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PurgeJobBuilder result,
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
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PurgeJobKindEnum),
          ) as PurgeJobKindEnum;
          result.kind = valueDes;
          break;
        case r'ownerUserId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ownerUserId = valueDes;
          break;
        case r'projectId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.projectId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PurgeJobStatusEnum),
          ) as PurgeJobStatusEnum;
          result.status = valueDes;
          break;
        case r'attempts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.attempts = valueDes;
          break;
        case r'runAfter':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.runAfter = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PurgeJob deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PurgeJobBuilder();
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


class PurgeJobKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'project_purge')
  static const PurgeJobKindEnum projectPurge = _$purgeJobKindEnum_projectPurge;

  static Serializer<PurgeJobKindEnum> get serializer => _$purgeJobKindEnumSerializer;

  const PurgeJobKindEnum._(String name): super(name);

  static BuiltSet<PurgeJobKindEnum> get values => _$purgeJobKindEnumValues;
  static PurgeJobKindEnum valueOf(String name) => _$purgeJobKindEnumValueOf(name);
}

class PurgeJobStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'queued')
  static const PurgeJobStatusEnum queued = _$purgeJobStatusEnum_queued;
  @BuiltValueEnumConst(wireName: r'running')
  static const PurgeJobStatusEnum running = _$purgeJobStatusEnum_running;
  @BuiltValueEnumConst(wireName: r'succeeded')
  static const PurgeJobStatusEnum succeeded = _$purgeJobStatusEnum_succeeded;
  @BuiltValueEnumConst(wireName: r'failed')
  static const PurgeJobStatusEnum failed = _$purgeJobStatusEnum_failed;

  static Serializer<PurgeJobStatusEnum> get serializer => _$purgeJobStatusEnumSerializer;

  const PurgeJobStatusEnum._(String name): super(name);

  static BuiltSet<PurgeJobStatusEnum> get values => _$purgeJobStatusEnumValues;
  static PurgeJobStatusEnum valueOf(String name) => _$purgeJobStatusEnumValueOf(name);
}

