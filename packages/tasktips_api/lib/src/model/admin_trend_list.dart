//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:tasktips_api/src/model/admin_trend_list_items_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_trend_list.g.dart';

/// AdminTrendList
///
/// Properties:
/// * [days] 
/// * [items] 
@BuiltValue()
abstract class AdminTrendList implements Built<AdminTrendList, AdminTrendListBuilder> {
  @BuiltValueField(wireName: r'days')
  int get days;

  @BuiltValueField(wireName: r'items')
  BuiltList<AdminTrendListItemsInner> get items;

  AdminTrendList._();

  factory AdminTrendList([void updates(AdminTrendListBuilder b)]) = _$AdminTrendList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminTrendListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminTrendList> get serializer => _$AdminTrendListSerializer();
}

class _$AdminTrendListSerializer implements PrimitiveSerializer<AdminTrendList> {
  @override
  final Iterable<Type> types = const [AdminTrendList, _$AdminTrendList];

  @override
  final String wireName = r'AdminTrendList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminTrendList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'days';
    yield serializers.serialize(
      object.days,
      specifiedType: const FullType(int),
    );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(AdminTrendListItemsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminTrendList object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminTrendListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'days':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.days = valueDes;
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AdminTrendListItemsInner)]),
          ) as BuiltList<AdminTrendListItemsInner>;
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
  AdminTrendList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminTrendListBuilder();
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


