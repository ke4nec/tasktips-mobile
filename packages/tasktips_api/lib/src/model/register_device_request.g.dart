// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_device_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RegisterDeviceRequest extends RegisterDeviceRequest {
  @override
  final String deviceId;
  @override
  final String displayName;
  @override
  final String platform;
  @override
  final String appVersion;

  factory _$RegisterDeviceRequest(
          [void Function(RegisterDeviceRequestBuilder)? updates]) =>
      (RegisterDeviceRequestBuilder()..update(updates))._build();

  _$RegisterDeviceRequest._(
      {required this.deviceId,
      required this.displayName,
      required this.platform,
      required this.appVersion})
      : super._();
  @override
  RegisterDeviceRequest rebuild(
          void Function(RegisterDeviceRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RegisterDeviceRequestBuilder toBuilder() =>
      RegisterDeviceRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RegisterDeviceRequest &&
        deviceId == other.deviceId &&
        displayName == other.displayName &&
        platform == other.platform &&
        appVersion == other.appVersion;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, appVersion.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RegisterDeviceRequest')
          ..add('deviceId', deviceId)
          ..add('displayName', displayName)
          ..add('platform', platform)
          ..add('appVersion', appVersion))
        .toString();
  }
}

class RegisterDeviceRequestBuilder
    implements Builder<RegisterDeviceRequest, RegisterDeviceRequestBuilder> {
  _$RegisterDeviceRequest? _$v;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _platform;
  String? get platform => _$this._platform;
  set platform(String? platform) => _$this._platform = platform;

  String? _appVersion;
  String? get appVersion => _$this._appVersion;
  set appVersion(String? appVersion) => _$this._appVersion = appVersion;

  RegisterDeviceRequestBuilder() {
    RegisterDeviceRequest._defaults(this);
  }

  RegisterDeviceRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _deviceId = $v.deviceId;
      _displayName = $v.displayName;
      _platform = $v.platform;
      _appVersion = $v.appVersion;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RegisterDeviceRequest other) {
    _$v = other as _$RegisterDeviceRequest;
  }

  @override
  void update(void Function(RegisterDeviceRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RegisterDeviceRequest build() => _build();

  _$RegisterDeviceRequest _build() {
    final _$result = _$v ??
        _$RegisterDeviceRequest._(
          deviceId: BuiltValueNullFieldError.checkNotNull(
              deviceId, r'RegisterDeviceRequest', 'deviceId'),
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName, r'RegisterDeviceRequest', 'displayName'),
          platform: BuiltValueNullFieldError.checkNotNull(
              platform, r'RegisterDeviceRequest', 'platform'),
          appVersion: BuiltValueNullFieldError.checkNotNull(
              appVersion, r'RegisterDeviceRequest', 'appVersion'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
