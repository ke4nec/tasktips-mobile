//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:tasktips_api/src/model/error_code.dart';
import 'package:tasktips_api/src/model/error_details.dart';
import 'package:tasktips_api/src/model/object_kind.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'push_rejected_result.g.dart';

/// PushRejectedResult
///
/// Properties:
/// * [status] 
/// * [kind] 
/// * [id] 
/// * [code] 
/// * [message] 
/// * [details] 
@BuiltValue()
abstract class PushRejectedResult implements Built<PushRejectedResult, PushRejectedResultBuilder> {
  @BuiltValueField(wireName: r'status')
  JsonObject? get status;

  @BuiltValueField(wireName: r'kind')
  ObjectKind get kind;
  // enum kindEnum {  todo,  classification,  index,  image,  };

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'code')
  ErrorCode get code;
  // enum codeEnum {  NOT_FOUND,  INVALID_REQUEST,  INTERNAL_ERROR,  AUTHENTICATION_REQUIRED,  AUTHORIZATION_DENIED,  ACCOUNT_DISABLED,  DEVICE_REVOKED,  PROJECT_NOT_FOUND,  PROJECT_MAINTENANCE,  GENERATION_MISMATCH,  REVISION_CONFLICT,  CONTENT_HASH_MISMATCH,  PAYLOAD_NOT_FOUND,  PAYLOAD_TOO_LARGE,  CURSOR_INVALID,  IDEMPOTENCY_CONFLICT,  RATE_LIMITED,  REQUEST_TIMEOUT,  INVALID_ACCOUNT_STATUS_TRANSITION,  STORAGE_UNAVAILABLE,  };

  @BuiltValueField(wireName: r'message')
  String? get message;

  @BuiltValueField(wireName: r'details')
  ErrorDetails? get details;

  PushRejectedResult._();

  factory PushRejectedResult([void updates(PushRejectedResultBuilder b)]) = _$PushRejectedResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PushRejectedResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PushRejectedResult> get serializer => _$PushRejectedResultSerializer();
}

class _$PushRejectedResultSerializer implements PrimitiveSerializer<PushRejectedResult> {
  @override
  final Iterable<Type> types = const [PushRejectedResult, _$PushRejectedResult];

  @override
  final String wireName = r'PushRejectedResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PushRejectedResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield object.status == null ? null : serializers.serialize(
      object.status,
      specifiedType: const FullType.nullable(JsonObject),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(ObjectKind),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(ErrorCode),
    );
    if (object.message != null) {
      yield r'message';
      yield serializers.serialize(
        object.message,
        specifiedType: const FullType(String),
      );
    }
    if (object.details != null) {
      yield r'details';
      yield serializers.serialize(
        object.details,
        specifiedType: const FullType(ErrorDetails),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PushRejectedResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PushRejectedResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ObjectKind),
          ) as ObjectKind;
          result.kind = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ErrorCode),
          ) as ErrorCode;
          result.code = valueDes;
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.message = valueDes;
          break;
        case r'details':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ErrorDetails),
          ) as ErrorDetails?;
          if (valueDes == null) continue;
          result.details.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PushRejectedResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PushRejectedResultBuilder();
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


