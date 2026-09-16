//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'error_code.g.dart';

class ErrorCode extends EnumClass {

  @BuiltValueEnumConst(wireName: r'NOT_FOUND')
  static const ErrorCode NOT_FOUND = _$NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'INVALID_REQUEST')
  static const ErrorCode INVALID_REQUEST = _$INVALID_REQUEST;
  @BuiltValueEnumConst(wireName: r'INTERNAL_ERROR')
  static const ErrorCode INTERNAL_ERROR = _$INTERNAL_ERROR;
  @BuiltValueEnumConst(wireName: r'AUTHENTICATION_REQUIRED')
  static const ErrorCode AUTHENTICATION_REQUIRED = _$AUTHENTICATION_REQUIRED;
  @BuiltValueEnumConst(wireName: r'AUTHORIZATION_DENIED')
  static const ErrorCode AUTHORIZATION_DENIED = _$AUTHORIZATION_DENIED;
  @BuiltValueEnumConst(wireName: r'ACCOUNT_DISABLED')
  static const ErrorCode ACCOUNT_DISABLED = _$ACCOUNT_DISABLED;
  @BuiltValueEnumConst(wireName: r'DEVICE_REVOKED')
  static const ErrorCode DEVICE_REVOKED = _$DEVICE_REVOKED;
  @BuiltValueEnumConst(wireName: r'PROJECT_NOT_FOUND')
  static const ErrorCode PROJECT_NOT_FOUND = _$PROJECT_NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'PROJECT_MAINTENANCE')
  static const ErrorCode PROJECT_MAINTENANCE = _$PROJECT_MAINTENANCE;
  @BuiltValueEnumConst(wireName: r'GENERATION_MISMATCH')
  static const ErrorCode GENERATION_MISMATCH = _$GENERATION_MISMATCH;
  @BuiltValueEnumConst(wireName: r'REVISION_CONFLICT')
  static const ErrorCode REVISION_CONFLICT = _$REVISION_CONFLICT;
  @BuiltValueEnumConst(wireName: r'CONTENT_HASH_MISMATCH')
  static const ErrorCode CONTENT_HASH_MISMATCH = _$CONTENT_HASH_MISMATCH;
  @BuiltValueEnumConst(wireName: r'PAYLOAD_NOT_FOUND')
  static const ErrorCode PAYLOAD_NOT_FOUND = _$PAYLOAD_NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'PAYLOAD_TOO_LARGE')
  static const ErrorCode PAYLOAD_TOO_LARGE = _$PAYLOAD_TOO_LARGE;
  @BuiltValueEnumConst(wireName: r'CURSOR_INVALID')
  static const ErrorCode CURSOR_INVALID = _$CURSOR_INVALID;
  @BuiltValueEnumConst(wireName: r'IDEMPOTENCY_CONFLICT')
  static const ErrorCode IDEMPOTENCY_CONFLICT = _$IDEMPOTENCY_CONFLICT;
  @BuiltValueEnumConst(wireName: r'RATE_LIMITED')
  static const ErrorCode RATE_LIMITED = _$RATE_LIMITED;
  @BuiltValueEnumConst(wireName: r'REQUEST_TIMEOUT')
  static const ErrorCode REQUEST_TIMEOUT = _$REQUEST_TIMEOUT;
  @BuiltValueEnumConst(wireName: r'INVALID_ACCOUNT_STATUS_TRANSITION')
  static const ErrorCode INVALID_ACCOUNT_STATUS_TRANSITION = _$INVALID_ACCOUNT_STATUS_TRANSITION;
  @BuiltValueEnumConst(wireName: r'STORAGE_UNAVAILABLE')
  static const ErrorCode STORAGE_UNAVAILABLE = _$STORAGE_UNAVAILABLE;

  static Serializer<ErrorCode> get serializer => _$errorCodeSerializer;

  const ErrorCode._(String name): super(name);

  static BuiltSet<ErrorCode> get values => _$values;
  static ErrorCode valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ErrorCodeMixin = Object with _$ErrorCodeMixin;

