//
// AUTO-GENERATED FILE, DO NOT MODIFY!（本文件含手工补丁，见下方 MANUAL PATCH 标记；
// 重新 codegen 后必须重新应用并跑 test/sync_engine_test.dart 的线格式回归用例）
//
// ignore_for_file: unused_element
import 'package:tasktips_api/src/model/object_kind.dart';
import 'package:tasktips_api/src/model/sync_tombstone_change.dart';
import 'package:tasktips_api/src/model/sync_object_change.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'sync_change.g.dart';

/// SyncChange
///
/// Properties:
/// * [type] 
/// * [kind] 
/// * [id] 
/// * [schemaVersion] 
/// * [revision] 
/// * [baseRevision] 
/// * [contentHash] 
/// * [updatedAt] 
/// * [deviceId] 
/// * [changeSequence] 
/// * [deletedAt] 
@BuiltValue()
abstract class SyncChange implements Built<SyncChange, SyncChangeBuilder> {
  /// One Of [SyncObjectChange], [SyncTombstoneChange]
  OneOf get oneOf;

  static const String discriminatorFieldName = r'type';

  static const Map<String, Type> discriminatorMapping = {
    r'SyncObjectChange': SyncObjectChange,
    r'SyncTombstoneChange': SyncTombstoneChange,
  };

  SyncChange._();

  factory SyncChange([void updates(SyncChangeBuilder b)]) = _$SyncChange;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SyncChangeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SyncChange> get serializer => _$SyncChangeSerializer();
}

extension SyncChangeDiscriminatorExt on SyncChange {
    String? get discriminatorValue {
        if (this is SyncObjectChange) {
            return r'SyncObjectChange';
        }
        if (this is SyncTombstoneChange) {
            return r'SyncTombstoneChange';
        }
        return null;
    }
}
extension SyncChangeBuilderDiscriminatorExt on SyncChangeBuilder {
    String? get discriminatorValue {
        if (this is SyncObjectChangeBuilder) {
            return r'SyncObjectChange';
        }
        if (this is SyncTombstoneChangeBuilder) {
            return r'SyncTombstoneChange';
        }
        return null;
    }
}

class _$SyncChangeSerializer implements PrimitiveSerializer<SyncChange> {
  @override
  final Iterable<Type> types = const [SyncChange, _$SyncChange];

  @override
  final String wireName = r'SyncChange';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SyncChange object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    SyncChange object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value, specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  SyncChange deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SyncChangeBuilder();
    Object? oneOfDataSrc;
    final serializedList = (serialized as Iterable<Object?>).toList();
    final discIndex = serializedList.indexOf(SyncChange.discriminatorFieldName) + 1;
    final discValue = serializers.deserialize(serializedList[discIndex], specifiedType: FullType(String)) as String;
    oneOfDataSrc = serialized;
    final oneOfTypes = [SyncObjectChange, SyncTombstoneChange, ];
    Object oneOfResult;
    Type oneOfType;
    switch (discValue) {
      // MANUAL PATCH（codegen 缺陷）：openapi-generator 按类型名生成辨别器，
      // 但契约实际线值为 const: object/tombstone（openapi.yaml SyncChange）。
      // 两种都接受；codegen 的类型名分支保留作兼容。
      case r'object':
      case r'SyncObjectChange':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(SyncObjectChange),
        ) as SyncObjectChange;
        oneOfType = SyncObjectChange;
        break;
      case r'tombstone':
      case r'SyncTombstoneChange':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(SyncTombstoneChange),
        ) as SyncTombstoneChange;
        oneOfType = SyncTombstoneChange;
        break;
      default:
        throw UnsupportedError("Couldn't deserialize oneOf for the discriminator value: ${discValue}");
    }
    result.oneOf = OneOfDynamic(typeIndex: oneOfTypes.indexOf(oneOfType), types: oneOfTypes, value: oneOfResult);
    return result.build();
  }
}


