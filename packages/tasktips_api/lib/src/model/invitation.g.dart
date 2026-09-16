// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const InvitationStatusEnum _$invitationStatusEnum_pending =
    const InvitationStatusEnum._('pending');
const InvitationStatusEnum _$invitationStatusEnum_used =
    const InvitationStatusEnum._('used');
const InvitationStatusEnum _$invitationStatusEnum_expired =
    const InvitationStatusEnum._('expired');
const InvitationStatusEnum _$invitationStatusEnum_revoked =
    const InvitationStatusEnum._('revoked');

InvitationStatusEnum _$invitationStatusEnumValueOf(String name) {
  switch (name) {
    case 'pending':
      return _$invitationStatusEnum_pending;
    case 'used':
      return _$invitationStatusEnum_used;
    case 'expired':
      return _$invitationStatusEnum_expired;
    case 'revoked':
      return _$invitationStatusEnum_revoked;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<InvitationStatusEnum> _$invitationStatusEnumValues =
    BuiltSet<InvitationStatusEnum>(const <InvitationStatusEnum>[
  _$invitationStatusEnum_pending,
  _$invitationStatusEnum_used,
  _$invitationStatusEnum_expired,
  _$invitationStatusEnum_revoked,
]);

Serializer<InvitationStatusEnum> _$invitationStatusEnumSerializer =
    _$InvitationStatusEnumSerializer();

class _$InvitationStatusEnumSerializer
    implements PrimitiveSerializer<InvitationStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pending': 'pending',
    'used': 'used',
    'expired': 'expired',
    'revoked': 'revoked',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pending': 'pending',
    'used': 'used',
    'expired': 'expired',
    'revoked': 'revoked',
  };

  @override
  final Iterable<Type> types = const <Type>[InvitationStatusEnum];
  @override
  final String wireName = 'InvitationStatusEnum';

  @override
  Object serialize(Serializers serializers, InvitationStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  InvitationStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      InvitationStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Invitation extends Invitation {
  @override
  final String id;
  @override
  final String email;
  @override
  final DateTime createdAt;
  @override
  final DateTime expiresAt;
  @override
  final DateTime? usedAt;
  @override
  final DateTime? revokedAt;
  @override
  final InvitationStatusEnum status;

  factory _$Invitation([void Function(InvitationBuilder)? updates]) =>
      (InvitationBuilder()..update(updates))._build();

  _$Invitation._(
      {required this.id,
      required this.email,
      required this.createdAt,
      required this.expiresAt,
      this.usedAt,
      this.revokedAt,
      required this.status})
      : super._();
  @override
  Invitation rebuild(void Function(InvitationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InvitationBuilder toBuilder() => InvitationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Invitation &&
        id == other.id &&
        email == other.email &&
        createdAt == other.createdAt &&
        expiresAt == other.expiresAt &&
        usedAt == other.usedAt &&
        revokedAt == other.revokedAt &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, usedAt.hashCode);
    _$hash = $jc(_$hash, revokedAt.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Invitation')
          ..add('id', id)
          ..add('email', email)
          ..add('createdAt', createdAt)
          ..add('expiresAt', expiresAt)
          ..add('usedAt', usedAt)
          ..add('revokedAt', revokedAt)
          ..add('status', status))
        .toString();
  }
}

class InvitationBuilder implements Builder<Invitation, InvitationBuilder> {
  _$Invitation? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  DateTime? _usedAt;
  DateTime? get usedAt => _$this._usedAt;
  set usedAt(DateTime? usedAt) => _$this._usedAt = usedAt;

  DateTime? _revokedAt;
  DateTime? get revokedAt => _$this._revokedAt;
  set revokedAt(DateTime? revokedAt) => _$this._revokedAt = revokedAt;

  InvitationStatusEnum? _status;
  InvitationStatusEnum? get status => _$this._status;
  set status(InvitationStatusEnum? status) => _$this._status = status;

  InvitationBuilder() {
    Invitation._defaults(this);
  }

  InvitationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _email = $v.email;
      _createdAt = $v.createdAt;
      _expiresAt = $v.expiresAt;
      _usedAt = $v.usedAt;
      _revokedAt = $v.revokedAt;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Invitation other) {
    _$v = other as _$Invitation;
  }

  @override
  void update(void Function(InvitationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Invitation build() => _build();

  _$Invitation _build() {
    final _$result = _$v ??
        _$Invitation._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Invitation', 'id'),
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'Invitation', 'email'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'Invitation', 'createdAt'),
          expiresAt: BuiltValueNullFieldError.checkNotNull(
              expiresAt, r'Invitation', 'expiresAt'),
          usedAt: usedAt,
          revokedAt: revokedAt,
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'Invitation', 'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
