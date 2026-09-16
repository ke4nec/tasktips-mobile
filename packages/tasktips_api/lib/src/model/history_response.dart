//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:tasktips_api/src/model/sync_change.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'history_response.g.dart';

/// HistoryResponse
///
/// Properties:
/// * [items] 
/// * [hasMore] 
/// * [nextSequence] 
@BuiltValue()
abstract class HistoryResponse implements Built<HistoryResponse, HistoryResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<SyncChange> get items;

  @BuiltValueField(wireName: r'hasMore')
  bool get hasMore;

  @BuiltValueField(wireName: r'nextSequence')
  int? get nextSequence;

  HistoryResponse._();

  factory HistoryResponse([void updates(HistoryResponseBuilder b)]) = _$HistoryResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HistoryResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HistoryResponse> get serializer => _$HistoryResponseSerializer();
}

class _$HistoryResponseSerializer implements PrimitiveSerializer<HistoryResponse> {
  @override
  final Iterable<Type> types = const [HistoryResponse, _$HistoryResponse];

  @override
  final String wireName = r'HistoryResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HistoryResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(SyncChange)]),
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
    HistoryResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required HistoryResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SyncChange)]),
          ) as BuiltList<SyncChange>;
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
  HistoryResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HistoryResponseBuilder();
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


