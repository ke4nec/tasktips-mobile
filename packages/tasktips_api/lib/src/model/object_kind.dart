//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'object_kind.g.dart';

class ObjectKind extends EnumClass {

  @BuiltValueEnumConst(wireName: r'todo')
  static const ObjectKind todo = _$todo;
  @BuiltValueEnumConst(wireName: r'classification')
  static const ObjectKind classification = _$classification;
  @BuiltValueEnumConst(wireName: r'index')
  static const ObjectKind index = _$index;
  @BuiltValueEnumConst(wireName: r'image')
  static const ObjectKind image = _$image;

  static Serializer<ObjectKind> get serializer => _$objectKindSerializer;

  const ObjectKind._(String name): super(name);

  static BuiltSet<ObjectKind> get values => _$values;
  static ObjectKind valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ObjectKindMixin = Object with _$ObjectKindMixin;

