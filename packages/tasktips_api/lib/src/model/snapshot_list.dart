//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:tasktips_api/src/model/snapshot.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'snapshot_list.g.dart';

/// SnapshotList
///
/// Properties:
/// * [items] 
@BuiltValue()
abstract class SnapshotList implements Built<SnapshotList, SnapshotListBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<Snapshot> get items;

  SnapshotList._();

  factory SnapshotList([void updates(SnapshotListBuilder b)]) = _$SnapshotList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SnapshotListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SnapshotList> get serializer => _$SnapshotListSerializer();
}

class _$SnapshotListSerializer implements PrimitiveSerializer<SnapshotList> {
  @override
  final Iterable<Type> types = const [SnapshotList, _$SnapshotList];

  @override
  final String wireName = r'SnapshotList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SnapshotList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(Snapshot)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SnapshotList object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SnapshotListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Snapshot)]),
          ) as BuiltList<Snapshot>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SnapshotList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SnapshotListBuilder();
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


