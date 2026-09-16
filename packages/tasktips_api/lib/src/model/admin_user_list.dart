//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:tasktips_api/src/model/admin_user.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_user_list.g.dart';

/// AdminUserList
///
/// Properties:
/// * [items] 
/// * [hasMore] 
/// * [nextOffset] 
/// * [limit] 
/// * [offset] 
@BuiltValue()
abstract class AdminUserList implements Built<AdminUserList, AdminUserListBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<AdminUser> get items;

  @BuiltValueField(wireName: r'hasMore')
  bool? get hasMore;

  @BuiltValueField(wireName: r'nextOffset')
  int? get nextOffset;

  @BuiltValueField(wireName: r'limit')
  int? get limit;

  @BuiltValueField(wireName: r'offset')
  int? get offset;

  AdminUserList._();

  factory AdminUserList([void updates(AdminUserListBuilder b)]) = _$AdminUserList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminUserListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminUserList> get serializer => _$AdminUserListSerializer();
}

class _$AdminUserListSerializer implements PrimitiveSerializer<AdminUserList> {
  @override
  final Iterable<Type> types = const [AdminUserList, _$AdminUserList];

  @override
  final String wireName = r'AdminUserList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminUserList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(AdminUser)]),
    );
    if (object.hasMore != null) {
      yield r'hasMore';
      yield serializers.serialize(
        object.hasMore,
        specifiedType: const FullType(bool),
      );
    }
    if (object.nextOffset != null) {
      yield r'nextOffset';
      yield serializers.serialize(
        object.nextOffset,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.limit != null) {
      yield r'limit';
      yield serializers.serialize(
        object.limit,
        specifiedType: const FullType(int),
      );
    }
    if (object.offset != null) {
      yield r'offset';
      yield serializers.serialize(
        object.offset,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminUserList object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminUserListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AdminUser)]),
          ) as BuiltList<AdminUser>;
          result.items.replace(valueDes);
          break;
        case r'hasMore':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.hasMore = valueDes;
          break;
        case r'nextOffset':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.nextOffset = valueDes;
          break;
        case r'limit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.limit = valueDes;
          break;
        case r'offset':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.offset = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminUserList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminUserListBuilder();
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


