//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:tasktips_api/src/model/object_kind.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_history_item.g.dart';

/// AdminHistoryItem
///
/// Properties:
/// * [kind] 
/// * [objectId] 
/// * [revision] 
/// * [baseRevision] 
/// * [changedAt] 
/// * [deviceId] 
/// * [tombstone] 
/// * [changeSequence] 
@BuiltValue()
abstract class AdminHistoryItem implements Built<AdminHistoryItem, AdminHistoryItemBuilder> {
  @BuiltValueField(wireName: r'kind')
  ObjectKind get kind;
  // enum kindEnum {  todo,  classification,  index,  image,  };

  @BuiltValueField(wireName: r'objectId')
  String get objectId;

  @BuiltValueField(wireName: r'revision')
  int get revision;

  @BuiltValueField(wireName: r'baseRevision')
  int? get baseRevision;

  @BuiltValueField(wireName: r'changedAt')
  DateTime get changedAt;

  @BuiltValueField(wireName: r'deviceId')
  String get deviceId;

  @BuiltValueField(wireName: r'tombstone')
  bool get tombstone;

  @BuiltValueField(wireName: r'changeSequence')
  int get changeSequence;

  AdminHistoryItem._();

  factory AdminHistoryItem([void updates(AdminHistoryItemBuilder b)]) = _$AdminHistoryItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminHistoryItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminHistoryItem> get serializer => _$AdminHistoryItemSerializer();
}

class _$AdminHistoryItemSerializer implements PrimitiveSerializer<AdminHistoryItem> {
  @override
  final Iterable<Type> types = const [AdminHistoryItem, _$AdminHistoryItem];

  @override
  final String wireName = r'AdminHistoryItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminHistoryItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(ObjectKind),
    );
    yield r'objectId';
    yield serializers.serialize(
      object.objectId,
      specifiedType: const FullType(String),
    );
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(int),
    );
    yield r'baseRevision';
    yield object.baseRevision == null ? null : serializers.serialize(
      object.baseRevision,
      specifiedType: const FullType.nullable(int),
    );
    yield r'changedAt';
    yield serializers.serialize(
      object.changedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'deviceId';
    yield serializers.serialize(
      object.deviceId,
      specifiedType: const FullType(String),
    );
    yield r'tombstone';
    yield serializers.serialize(
      object.tombstone,
      specifiedType: const FullType(bool),
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
    AdminHistoryItem object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminHistoryItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ObjectKind),
          ) as ObjectKind;
          result.kind = valueDes;
          break;
        case r'objectId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.objectId = valueDes;
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
        case r'changedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.changedAt = valueDes;
          break;
        case r'deviceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceId = valueDes;
          break;
        case r'tombstone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.tombstone = valueDes;
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
  AdminHistoryItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminHistoryItemBuilder();
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


