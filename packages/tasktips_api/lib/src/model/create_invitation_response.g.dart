// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_invitation_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateInvitationResponse extends CreateInvitationResponse {
  @override
  final String id;
  @override
  final String email;
  @override
  final String invitationToken;
  @override
  final DateTime expiresAt;

  factory _$CreateInvitationResponse(
          [void Function(CreateInvitationResponseBuilder)? updates]) =>
      (CreateInvitationResponseBuilder()..update(updates))._build();

  _$CreateInvitationResponse._(
      {required this.id,
      required this.email,
      required this.invitationToken,
      required this.expiresAt})
      : super._();
  @override
  CreateInvitationResponse rebuild(
          void Function(CreateInvitationResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateInvitationResponseBuilder toBuilder() =>
      CreateInvitationResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateInvitationResponse &&
        id == other.id &&
        email == other.email &&
        invitationToken == other.invitationToken &&
        expiresAt == other.expiresAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, invitationToken.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateInvitationResponse')
          ..add('id', id)
          ..add('email', email)
          ..add('invitationToken', invitationToken)
          ..add('expiresAt', expiresAt))
        .toString();
  }
}

class CreateInvitationResponseBuilder
    implements
        Builder<CreateInvitationResponse, CreateInvitationResponseBuilder> {
  _$CreateInvitationResponse? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _invitationToken;
  String? get invitationToken => _$this._invitationToken;
  set invitationToken(String? invitationToken) =>
      _$this._invitationToken = invitationToken;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  CreateInvitationResponseBuilder() {
    CreateInvitationResponse._defaults(this);
  }

  CreateInvitationResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _email = $v.email;
      _invitationToken = $v.invitationToken;
      _expiresAt = $v.expiresAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateInvitationResponse other) {
    _$v = other as _$CreateInvitationResponse;
  }

  @override
  void update(void Function(CreateInvitationResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateInvitationResponse build() => _build();

  _$CreateInvitationResponse _build() {
    final _$result = _$v ??
        _$CreateInvitationResponse._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'CreateInvitationResponse', 'id'),
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'CreateInvitationResponse', 'email'),
          invitationToken: BuiltValueNullFieldError.checkNotNull(
              invitationToken, r'CreateInvitationResponse', 'invitationToken'),
          expiresAt: BuiltValueNullFieldError.checkNotNull(
              expiresAt, r'CreateInvitationResponse', 'expiresAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
