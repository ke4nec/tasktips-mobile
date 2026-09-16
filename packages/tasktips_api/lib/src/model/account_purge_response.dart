//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'account_purge_response.g.dart';

/// AccountPurgeResponse
///
/// Properties:
/// * [jobId] 
/// * [exportId] 
/// * [status] 
/// * [confirmationRequired] 
@BuiltValue()
abstract class AccountPurgeResponse implements Built<AccountPurgeResponse, AccountPurgeResponseBuilder> {
  @BuiltValueField(wireName: r'jobId')
  String get jobId;

  @BuiltValueField(wireName: r'exportId')
  String get exportId;

  @BuiltValueField(wireName: r'status')
  AccountPurgeResponseStatusEnum get status;
  // enum statusEnum {  queued,  running,  ready,  };

  @BuiltValueField(wireName: r'confirmationRequired')
  bool get confirmationRequired;

  AccountPurgeResponse._();

  factory AccountPurgeResponse([void updates(AccountPurgeResponseBuilder b)]) = _$AccountPurgeResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AccountPurgeResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AccountPurgeResponse> get serializer => _$AccountPurgeResponseSerializer();
}

class _$AccountPurgeResponseSerializer implements PrimitiveSerializer<AccountPurgeResponse> {
  @override
  final Iterable<Type> types = const [AccountPurgeResponse, _$AccountPurgeResponse];

  @override
  final String wireName = r'AccountPurgeResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AccountPurgeResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'jobId';
    yield serializers.serialize(
      object.jobId,
      specifiedType: const FullType(String),
    );
    yield r'exportId';
    yield serializers.serialize(
      object.exportId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(AccountPurgeResponseStatusEnum),
    );
    yield r'confirmationRequired';
    yield serializers.serialize(
      object.confirmationRequired,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AccountPurgeResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AccountPurgeResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'jobId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.jobId = valueDes;
          break;
        case r'exportId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.exportId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AccountPurgeResponseStatusEnum),
          ) as AccountPurgeResponseStatusEnum;
          result.status = valueDes;
          break;
        case r'confirmationRequired':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.confirmationRequired = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AccountPurgeResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AccountPurgeResponseBuilder();
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


class AccountPurgeResponseStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'queued')
  static const AccountPurgeResponseStatusEnum queued = _$accountPurgeResponseStatusEnum_queued;
  @BuiltValueEnumConst(wireName: r'running')
  static const AccountPurgeResponseStatusEnum running = _$accountPurgeResponseStatusEnum_running;
  @BuiltValueEnumConst(wireName: r'ready')
  static const AccountPurgeResponseStatusEnum ready = _$accountPurgeResponseStatusEnum_ready;

  static Serializer<AccountPurgeResponseStatusEnum> get serializer => _$accountPurgeResponseStatusEnumSerializer;

  const AccountPurgeResponseStatusEnum._(String name): super(name);

  static BuiltSet<AccountPurgeResponseStatusEnum> get values => _$accountPurgeResponseStatusEnumValues;
  static AccountPurgeResponseStatusEnum valueOf(String name) => _$accountPurgeResponseStatusEnumValueOf(name);
}

