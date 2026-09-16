//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_trend_list_items_inner.g.dart';

/// AdminTrendListItemsInner
///
/// Properties:
/// * [day] 
/// * [attempts] 
/// * [succeeded] 
/// * [conflicts] 
/// * [p50LatencyMs] 
/// * [p99LatencyMs] 
@BuiltValue()
abstract class AdminTrendListItemsInner implements Built<AdminTrendListItemsInner, AdminTrendListItemsInnerBuilder> {
  @BuiltValueField(wireName: r'day')
  DateTime get day;

  @BuiltValueField(wireName: r'attempts')
  int get attempts;

  @BuiltValueField(wireName: r'succeeded')
  int get succeeded;

  @BuiltValueField(wireName: r'conflicts')
  int get conflicts;

  @BuiltValueField(wireName: r'p50LatencyMs')
  num? get p50LatencyMs;

  @BuiltValueField(wireName: r'p99LatencyMs')
  num? get p99LatencyMs;

  AdminTrendListItemsInner._();

  factory AdminTrendListItemsInner([void updates(AdminTrendListItemsInnerBuilder b)]) = _$AdminTrendListItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminTrendListItemsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminTrendListItemsInner> get serializer => _$AdminTrendListItemsInnerSerializer();
}

class _$AdminTrendListItemsInnerSerializer implements PrimitiveSerializer<AdminTrendListItemsInner> {
  @override
  final Iterable<Type> types = const [AdminTrendListItemsInner, _$AdminTrendListItemsInner];

  @override
  final String wireName = r'AdminTrendListItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminTrendListItemsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'day';
    yield serializers.serialize(
      object.day,
      specifiedType: const FullType(DateTime),
    );
    yield r'attempts';
    yield serializers.serialize(
      object.attempts,
      specifiedType: const FullType(int),
    );
    yield r'succeeded';
    yield serializers.serialize(
      object.succeeded,
      specifiedType: const FullType(int),
    );
    yield r'conflicts';
    yield serializers.serialize(
      object.conflicts,
      specifiedType: const FullType(int),
    );
    if (object.p50LatencyMs != null) {
      yield r'p50LatencyMs';
      yield serializers.serialize(
        object.p50LatencyMs,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.p99LatencyMs != null) {
      yield r'p99LatencyMs';
      yield serializers.serialize(
        object.p99LatencyMs,
        specifiedType: const FullType.nullable(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminTrendListItemsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminTrendListItemsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'day':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.day = valueDes;
          break;
        case r'attempts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.attempts = valueDes;
          break;
        case r'succeeded':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.succeeded = valueDes;
          break;
        case r'conflicts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.conflicts = valueDes;
          break;
        case r'p50LatencyMs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.p50LatencyMs = valueDes;
          break;
        case r'p99LatencyMs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.p99LatencyMs = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminTrendListItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminTrendListItemsInnerBuilder();
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


