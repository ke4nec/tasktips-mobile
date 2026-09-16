//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pull_request.g.dart';

/// PullRequest
///
/// Properties:
/// * [cursor] 
/// * [limit] 
@BuiltValue()
abstract class PullRequest implements Built<PullRequest, PullRequestBuilder> {
  @BuiltValueField(wireName: r'cursor')
  String get cursor;

  @BuiltValueField(wireName: r'limit')
  int? get limit;

  PullRequest._();

  factory PullRequest([void updates(PullRequestBuilder b)]) = _$PullRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PullRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PullRequest> get serializer => _$PullRequestSerializer();
}

class _$PullRequestSerializer implements PrimitiveSerializer<PullRequest> {
  @override
  final Iterable<Type> types = const [PullRequest, _$PullRequest];

  @override
  final String wireName = r'PullRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PullRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'cursor';
    yield serializers.serialize(
      object.cursor,
      specifiedType: const FullType(String),
    );
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
    PullRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PullRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cursor = valueDes;
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
  PullRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PullRequestBuilder();
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


