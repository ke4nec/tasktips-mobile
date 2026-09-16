//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'snapshot.g.dart';

/// Snapshot
///
/// Properties:
/// * [id] 
/// * [projectId] 
/// * [generation] 
/// * [changeSequence] 
/// * [manifestHash] 
/// * [status] 
/// * [createdBy] 
/// * [createdAt] 
@BuiltValue()
abstract class Snapshot implements Built<Snapshot, SnapshotBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'projectId')
  String get projectId;

  @BuiltValueField(wireName: r'generation')
  int get generation;

  @BuiltValueField(wireName: r'changeSequence')
  int get changeSequence;

  @BuiltValueField(wireName: r'manifestHash')
  String get manifestHash;

  @BuiltValueField(wireName: r'status')
  SnapshotStatusEnum get status;
  // enum statusEnum {  pending,  ready,  failed,  };

  @BuiltValueField(wireName: r'createdBy')
  String get createdBy;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  Snapshot._();

  factory Snapshot([void updates(SnapshotBuilder b)]) = _$Snapshot;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SnapshotBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Snapshot> get serializer => _$SnapshotSerializer();
}

class _$SnapshotSerializer implements PrimitiveSerializer<Snapshot> {
  @override
  final Iterable<Type> types = const [Snapshot, _$Snapshot];

  @override
  final String wireName = r'Snapshot';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Snapshot object, {
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
    yield r'generation';
    yield serializers.serialize(
      object.generation,
      specifiedType: const FullType(int),
    );
    yield r'changeSequence';
    yield serializers.serialize(
      object.changeSequence,
      specifiedType: const FullType(int),
    );
    yield r'manifestHash';
    yield serializers.serialize(
      object.manifestHash,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(SnapshotStatusEnum),
    );
    yield r'createdBy';
    yield serializers.serialize(
      object.createdBy,
      specifiedType: const FullType(String),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Snapshot object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SnapshotBuilder result,
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
        case r'generation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.generation = valueDes;
          break;
        case r'changeSequence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.changeSequence = valueDes;
          break;
        case r'manifestHash':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.manifestHash = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SnapshotStatusEnum),
          ) as SnapshotStatusEnum;
          result.status = valueDes;
          break;
        case r'createdBy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.createdBy = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Snapshot deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SnapshotBuilder();
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


class SnapshotStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'pending')
  static const SnapshotStatusEnum pending = _$snapshotStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'ready')
  static const SnapshotStatusEnum ready = _$snapshotStatusEnum_ready;
  @BuiltValueEnumConst(wireName: r'failed')
  static const SnapshotStatusEnum failed = _$snapshotStatusEnum_failed;

  static Serializer<SnapshotStatusEnum> get serializer => _$snapshotStatusEnumSerializer;

  const SnapshotStatusEnum._(String name): super(name);

  static BuiltSet<SnapshotStatusEnum> get values => _$snapshotStatusEnumValues;
  static SnapshotStatusEnum valueOf(String name) => _$snapshotStatusEnumValueOf(name);
}

