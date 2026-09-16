// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_invitation_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateInvitationRequest extends CreateInvitationRequest {
  @override
  final String email;

  factory _$CreateInvitationRequest(
          [void Function(CreateInvitationRequestBuilder)? updates]) =>
      (CreateInvitationRequestBuilder()..update(updates))._build();

  _$CreateInvitationRequest._({required this.email}) : super._();
  @override
  CreateInvitationRequest rebuild(
          void Function(CreateInvitationRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateInvitationRequestBuilder toBuilder() =>
      CreateInvitationRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateInvitationRequest && email == other.email;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateInvitationRequest')
          ..add('email', email))
        .toString();
  }
}

class CreateInvitationRequestBuilder
    implements
        Builder<CreateInvitationRequest, CreateInvitationRequestBuilder> {
  _$CreateInvitationRequest? _$v;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  CreateInvitationRequestBuilder() {
    CreateInvitationRequest._defaults(this);
  }

  CreateInvitationRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _email = $v.email;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateInvitationRequest other) {
    _$v = other as _$CreateInvitationRequest;
  }

  @override
  void update(void Function(CreateInvitationRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateInvitationRequest build() => _build();

  _$CreateInvitationRequest _build() {
    final _$result = _$v ??
        _$CreateInvitationRequest._(
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'CreateInvitationRequest', 'email'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
