//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:tasktips_api/src/model/sync_change.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bootstrap_response.g.dart';

/// BootstrapResponse
///
/// Properties:
/// * [generation] 
/// * [items] 
/// * [hasMore] 
/// * [nextPageToken] 
/// * [cursor] 
@BuiltValue()
abstract class BootstrapResponse implements Built<BootstrapResponse, BootstrapResponseBuilder> {
  @BuiltValueField(wireName: r'generation')
  int get generation;

  @BuiltValueField(wireName: r'items')
  BuiltList<SyncChange> get items;

  @BuiltValueField(wireName: r'hasMore')
  bool get hasMore;

  @BuiltValueField(wireName: r'nextPageToken')
  String? get nextPageToken;

  @BuiltValueField(wireName: r'cursor')
  String? get cursor;

  BootstrapResponse._();

  factory BootstrapResponse([void updates(BootstrapResponseBuilder b)]) = _$BootstrapResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BootstrapResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BootstrapResponse> get serializer => _$BootstrapResponseSerializer();
}

class _$BootstrapResponseSerializer implements PrimitiveSerializer<BootstrapResponse> {
  @override
  final Iterable<Type> types = const [BootstrapResponse, _$BootstrapResponse];

  @override
  final String wireName = r'BootstrapResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BootstrapResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'generation';
    yield serializers.serialize(
      object.generation,
      specifiedType: const FullType(int),
    );
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
    yield r'nextPageToken';
    yield object.nextPageToken == null ? null : serializers.serialize(
      object.nextPageToken,
      specifiedType: const FullType.nullable(String),
    );
    yield r'cursor';
    yield object.cursor == null ? null : serializers.serialize(
      object.cursor,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BootstrapResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BootstrapResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'generation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.generation = valueDes;
          break;
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
        case r'nextPageToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nextPageToken = valueDes;
          break;
        case r'cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.cursor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BootstrapResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BootstrapResponseBuilder();
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


