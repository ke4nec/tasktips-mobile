// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'object_kind.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ObjectKind _$todo = const ObjectKind._('todo');
const ObjectKind _$classification = const ObjectKind._('classification');
const ObjectKind _$index = const ObjectKind._('index');
const ObjectKind _$image = const ObjectKind._('image');

ObjectKind _$valueOf(String name) {
  switch (name) {
    case 'todo':
      return _$todo;
    case 'classification':
      return _$classification;
    case 'index':
      return _$index;
    case 'image':
      return _$image;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ObjectKind> _$values = BuiltSet<ObjectKind>(const <ObjectKind>[
  _$todo,
  _$classification,
  _$index,
  _$image,
]);

class _$ObjectKindMeta {
  const _$ObjectKindMeta();
  ObjectKind get todo => _$todo;
  ObjectKind get classification => _$classification;
  ObjectKind get index => _$index;
  ObjectKind get image => _$image;
  ObjectKind valueOf(String name) => _$valueOf(name);
  BuiltSet<ObjectKind> get values => _$values;
}

abstract class _$ObjectKindMixin {
  // ignore: non_constant_identifier_names
  _$ObjectKindMeta get ObjectKind => const _$ObjectKindMeta();
}

Serializer<ObjectKind> _$objectKindSerializer = _$ObjectKindSerializer();

class _$ObjectKindSerializer implements PrimitiveSerializer<ObjectKind> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'todo': 'todo',
    'classification': 'classification',
    'index': 'index',
    'image': 'image',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'todo': 'todo',
    'classification': 'classification',
    'index': 'index',
    'image': 'image',
  };

  @override
  final Iterable<Type> types = const <Type>[ObjectKind];
  @override
  final String wireName = 'ObjectKind';

  @override
  Object serialize(Serializers serializers, ObjectKind object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ObjectKind deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ObjectKind.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
