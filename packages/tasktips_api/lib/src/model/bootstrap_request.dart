//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bootstrap_request.g.dart';

/// BootstrapRequest
///
/// Properties:
/// * [pageToken] 
/// * [limit] 
@BuiltValue()
abstract class BootstrapRequest implements Built<BootstrapRequest, BootstrapRequestBuilder> {
  @BuiltValueField(wireName: r'pageToken')
  String? get pageToken;

  @BuiltValueField(wireName: r'limit')
  int? get limit;

  BootstrapRequest._();

  factory BootstrapRequest([void updates(BootstrapRequestBuilder b)]) = _$BootstrapRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BootstrapRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BootstrapRequest> get serializer => _$BootstrapRequestSerializer();
}

class _$BootstrapRequestSerializer implements PrimitiveSerializer<BootstrapRequest> {
  @override
  final Iterable<Type> types = const [BootstrapRequest, _$BootstrapRequest];

  @override
  final String wireName = r'BootstrapRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BootstrapRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.pageToken != null) {
      yield r'pageToken';
      yield serializers.serialize(
        object.pageToken,
        specifiedType: const FullType(String),
      );
    }
    if (object.limit != null) {
      yield r'limit';
      yield serializers.serialize(
        object.limit,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BootstrapRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BootstrapRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'pageToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.pageToken = valueDes;
          break;
        case r'limit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.limit = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BootstrapRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BootstrapRequestBuilder();
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


