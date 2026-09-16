//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'account_purge_request.g.dart';

/// AccountPurgeRequest
///
/// Properties:
/// * [exportId] 
/// * [confirmed] 
/// * [reason] 
@BuiltValue()
abstract class AccountPurgeRequest implements Built<AccountPurgeRequest, AccountPurgeRequestBuilder> {
  @BuiltValueField(wireName: r'exportId')
  String? get exportId;

  @BuiltValueField(wireName: r'confirmed')
  bool get confirmed;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  AccountPurgeRequest._();

  factory AccountPurgeRequest([void updates(AccountPurgeRequestBuilder b)]) = _$AccountPurgeRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AccountPurgeRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AccountPurgeRequest> get serializer => _$AccountPurgeRequestSerializer();
}

class _$AccountPurgeRequestSerializer implements PrimitiveSerializer<AccountPurgeRequest> {
  @override
  final Iterable<Type> types = const [AccountPurgeRequest, _$AccountPurgeRequest];

  @override
  final String wireName = r'AccountPurgeRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AccountPurgeRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.exportId != null) {
      yield r'exportId';
      yield serializers.serialize(
        object.exportId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'confirmed';
    yield serializers.serialize(
      object.confirmed,
      specifiedType: const FullType(bool),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AccountPurgeRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AccountPurgeRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'exportId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.exportId = valueDes;
          break;
        case r'confirmed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.confirmed = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AccountPurgeRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AccountPurgeRequestBuilder();
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


