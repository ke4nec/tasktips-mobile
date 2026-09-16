//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_overview.g.dart';

/// AdminOverview
///
/// Properties:
/// * [users] 
/// * [activeUsers] 
/// * [projects] 
/// * [devices] 
/// * [revisions] 
/// * [tombstones] 
/// * [payloadBytes] 
/// * [queuedRestores] 
@BuiltValue()
abstract class AdminOverview implements Built<AdminOverview, AdminOverviewBuilder> {
  @BuiltValueField(wireName: r'users')
  int get users;

  @BuiltValueField(wireName: r'activeUsers')
  int get activeUsers;

  @BuiltValueField(wireName: r'projects')
  int get projects;

  @BuiltValueField(wireName: r'devices')
  int get devices;

  @BuiltValueField(wireName: r'revisions')
  int get revisions;

  @BuiltValueField(wireName: r'tombstones')
  int get tombstones;

  @BuiltValueField(wireName: r'payloadBytes')
  int get payloadBytes;

  @BuiltValueField(wireName: r'queuedRestores')
  int get queuedRestores;

  AdminOverview._();

  factory AdminOverview([void updates(AdminOverviewBuilder b)]) = _$AdminOverview;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminOverviewBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminOverview> get serializer => _$AdminOverviewSerializer();
}

class _$AdminOverviewSerializer implements PrimitiveSerializer<AdminOverview> {
  @override
  final Iterable<Type> types = const [AdminOverview, _$AdminOverview];

  @override
  final String wireName = r'AdminOverview';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminOverview object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'users';
    yield serializers.serialize(
      object.users,
      specifiedType: const FullType(int),
    );
    yield r'activeUsers';
    yield serializers.serialize(
      object.activeUsers,
      specifiedType: const FullType(int),
    );
    yield r'projects';
    yield serializers.serialize(
      object.projects,
      specifiedType: const FullType(int),
    );
    yield r'devices';
    yield serializers.serialize(
      object.devices,
      specifiedType: const FullType(int),
    );
    yield r'revisions';
    yield serializers.serialize(
      object.revisions,
      specifiedType: const FullType(int),
    );
    yield r'tombstones';
    yield serializers.serialize(
      object.tombstones,
      specifiedType: const FullType(int),
    );
    yield r'payloadBytes';
    yield serializers.serialize(
      object.payloadBytes,
      specifiedType: const FullType(int),
    );
    yield r'queuedRestores';
    yield serializers.serialize(
      object.queuedRestores,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminOverview object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminOverviewBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'users':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.users = valueDes;
          break;
        case r'activeUsers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.activeUsers = valueDes;
          break;
        case r'projects':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.projects = valueDes;
          break;
        case r'devices':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.devices = valueDes;
          break;
        case r'revisions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.revisions = valueDes;
          break;
        case r'tombstones':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.tombstones = valueDes;
          break;
        case r'payloadBytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.payloadBytes = valueDes;
          break;
        case r'queuedRestores':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.queuedRestores = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminOverview deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminOverviewBuilder();
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


