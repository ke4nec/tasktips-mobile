//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:tasktips_api/src/model/object_kind.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sync_tombstone_change.g.dart';

/// SyncTombstoneChange
///
/// Properties:
/// * [type] 
/// * [kind] 
/// * [id] 
/// * [revision] 
/// * [baseRevision] 
/// * [deletedAt] 
/// * [deviceId] 
/// * [changeSequence] 
@BuiltValue()
abstract class SyncTombstoneChange implements Built<SyncTombstoneChange, SyncTombstoneChangeBuilder> {
  @BuiltValueField(wireName: r'type')
  JsonObject? get type;

  @BuiltValueField(wireName: r'kind')
  ObjectKind get kind;
  // enum kindEnum {  todo,  classification,  index,  image,  };

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'revision')
  int get revision;

  @BuiltValueField(wireName: r'baseRevision')
  int? get baseRevision;

  @BuiltValueField(wireName: r'deletedAt')
  DateTime get deletedAt;

  @BuiltValueField(wireName: r'deviceId')
  String get deviceId;

  @BuiltValueField(wireName: r'changeSequence')
  int get changeSequence;

  SyncTombstoneChange._();

  factory SyncTombstoneChange([void updates(SyncTombstoneChangeBuilder b)]) = _$SyncTombstoneChange;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SyncTombstoneChangeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SyncTombstoneChange> get serializer => _$SyncTombstoneChangeSerializer();
}

class _$SyncTombstoneChangeSerializer implements PrimitiveSerializer<SyncTombstoneChange> {
  @override
  final Iterable<Type> types = const [SyncTombstoneChange, _$SyncTombstoneChange];

  @override
  final String wireName = r'SyncTombstoneChange';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SyncTombstoneChange object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield object.type == null ? null : serializers.serialize(
      object.type,
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
    if (object.baseRevision != null) {
      yield r'baseRevision';
      yield serializers.serialize(
        object.baseRevision,
        specifiedType: const FullType.nullable(int),
      );
    }
    yield r'deletedAt';
    yield serializers.serialize(
      object.deletedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'deviceId';
    yield serializers.serialize(
      object.deviceId,
      specifiedType: const FullType(String),
    );
    yield r'changeSequence';
    yield serializers.serialize(
      object.changeSequence,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SyncTombstoneChange object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SyncTombstoneChangeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.type = valueDes;
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
        case r'baseRevision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.baseRevision = valueDes;
          break;
        case r'deletedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.deletedAt = valueDes;
          break;
        case r'deviceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceId = valueDes;
          break;
        case r'changeSequence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.changeSequence = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SyncTombstoneChange deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SyncTombstoneChangeBuilder();
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


