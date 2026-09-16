//
// AUTO-GENERATED FILE, DO NOT MODIFY!
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
      case r'SyncObjectChange':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(SyncObjectChange),
        ) as SyncObjectChange;
        oneOfType = SyncObjectChange;
        break;
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


