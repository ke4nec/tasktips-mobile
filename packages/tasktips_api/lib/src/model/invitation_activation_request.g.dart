// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_activation_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InvitationActivationRequest extends InvitationActivationRequest {
  @override
  final String invitationToken;
  @override
  final String password;
  @override
  final String deviceId;

  factory _$InvitationActivationRequest(
          [void Function(InvitationActivationRequestBuilder)? updates]) =>
      (InvitationActivationRequestBuilder()..update(updates))._build();

  _$InvitationActivationRequest._(
      {required this.invitationToken,
      required this.password,
      required this.deviceId})
      : super._();
  @override
  InvitationActivationRequest rebuild(
          void Function(InvitationActivationRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InvitationActivationRequestBuilder toBuilder() =>
      InvitationActivationRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InvitationActivationRequest &&
        invitationToken == other.invitationToken &&
        password == other.password &&
        deviceId == other.deviceId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, invitationToken.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'InvitationActivationRequest')
          ..add('invitationToken', invitationToken)
          ..add('password', password)
          ..add('deviceId', deviceId))
        .toString();
  }
}

class InvitationActivationRequestBuilder
    implements
        Builder<InvitationActivationRequest,
            InvitationActivationRequestBuilder> {
  _$InvitationActivationRequest? _$v;

  String? _invitationToken;
  String? get invitationToken => _$this._invitationToken;
  set invitationToken(String? invitationToken) =>
      _$this._invitationToken = invitationToken;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  InvitationActivationRequestBuilder() {
    InvitationActivationRequest._defaults(this);
  }

  InvitationActivationRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _invitationToken = $v.invitationToken;
      _password = $v.password;
      _deviceId = $v.deviceId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InvitationActivationRequest other) {
    _$v = other as _$InvitationActivationRequest;
  }

  @override
  void update(void Function(InvitationActivationRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InvitationActivationRequest build() => _build();

  _$InvitationActivationRequest _build() {
    final _$result = _$v ??
        _$InvitationActivationRequest._(
          invitationToken: BuiltValueNullFieldError.checkNotNull(
              invitationToken,
              r'InvitationActivationRequest',
              'invitationToken'),
          password: BuiltValueNullFieldError.checkNotNull(
              password, r'InvitationActivationRequest', 'password'),
          deviceId: BuiltValueNullFieldError.checkNotNull(
              deviceId, r'InvitationActivationRequest', 'deviceId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
