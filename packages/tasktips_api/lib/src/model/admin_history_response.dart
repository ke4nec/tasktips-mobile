//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:tasktips_api/src/model/admin_history_item.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_history_response.g.dart';

/// AdminHistoryResponse
///
/// Properties:
/// * [items] 
/// * [hasMore] 
/// * [nextSequence] 
@BuiltValue()
abstract class AdminHistoryResponse implements Built<AdminHistoryResponse, AdminHistoryResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<AdminHistoryItem> get items;

  @BuiltValueField(wireName: r'hasMore')
  bool get hasMore;

  @BuiltValueField(wireName: r'nextSequence')
  int? get nextSequence;

  AdminHistoryResponse._();

  factory AdminHistoryResponse([void updates(AdminHistoryResponseBuilder b)]) = _$AdminHistoryResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminHistoryResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminHistoryResponse> get serializer => _$AdminHistoryResponseSerializer();
}

class _$AdminHistoryResponseSerializer implements PrimitiveSerializer<AdminHistoryResponse> {
  @override
  final Iterable<Type> types = const [AdminHistoryResponse, _$AdminHistoryResponse];

  @override
  final String wireName = r'AdminHistoryResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminHistoryResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(AdminHistoryItem)]),
    );
    yield r'hasMore';
    yield serializers.serialize(
      object.hasMore,
      specifiedType: const FullType(bool),
    );
    if (object.nextSequence != null) {
      yield r'nextSequence';
      yield serializers.serialize(
        object.nextSequence,
        specifiedType: const FullType.nullable(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminHistoryResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminHistoryResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AdminHistoryItem)]),
          ) as BuiltList<AdminHistoryItem>;
          result.items.replace(valueDes);
          break;
        case r'hasMore':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasMore = valueDes;
          break;
        case r'nextSequence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.nextSequence = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminHistoryResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminHistoryResponseBuilder();
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


