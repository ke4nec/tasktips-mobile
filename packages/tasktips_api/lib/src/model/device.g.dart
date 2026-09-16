// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Device extends Device {
  @override
  final String id;
  @override
  final String ownerUserId;
  @override
  final String displayName;
  @override
  final String platform;
  @override
  final String appVersion;
  @override
  final DateTime createdAt;
  @override
  final DateTime? lastSeenAt;
  @override
  final DateTime? lastLoginAt;
  @override
  final DateTime? lastPullAt;
  @override
  final DateTime? lastPushAt;
  @override
  final DateTime? revokedAt;

  factory _$Device([void Function(DeviceBuilder)? updates]) =>
      (DeviceBuilder()..update(updates))._build();

  _$Device._(
      {required this.id,
      required this.ownerUserId,
      required this.displayName,
      required this.platform,
      required this.appVersion,
      required this.createdAt,
      this.lastSeenAt,
      this.lastLoginAt,
      this.lastPullAt,
      this.lastPushAt,
      this.revokedAt})
      : super._();
  @override
  Device rebuild(void Function(DeviceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeviceBuilder toBuilder() => DeviceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Device &&
        id == other.id &&
        ownerUserId == other.ownerUserId &&
        displayName == other.displayName &&
        platform == other.platform &&
        appVersion == other.appVersion &&
        createdAt == other.createdAt &&
        lastSeenAt == other.lastSeenAt &&
        lastLoginAt == other.lastLoginAt &&
        lastPullAt == other.lastPullAt &&
        lastPushAt == other.lastPushAt &&
        revokedAt == other.revokedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, ownerUserId.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, appVersion.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, lastSeenAt.hashCode);
    _$hash = $jc(_$hash, lastLoginAt.hashCode);
    _$hash = $jc(_$hash, lastPullAt.hashCode);
    _$hash = $jc(_$hash, lastPushAt.hashCode);
    _$hash = $jc(_$hash, revokedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Device')
          ..add('id', id)
          ..add('ownerUserId', ownerUserId)
          ..add('displayName', displayName)
          ..add('platform', platform)
          ..add('appVersion', appVersion)
          ..add('createdAt', createdAt)
          ..add('lastSeenAt', lastSeenAt)
          ..add('lastLoginAt', lastLoginAt)
          ..add('lastPullAt', lastPullAt)
          ..add('lastPushAt', lastPushAt)
          ..add('revokedAt', revokedAt))
        .toString();
  }
}

class DeviceBuilder implements Builder<Device, DeviceBuilder> {
  _$Device? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _ownerUserId;
  String? get ownerUserId => _$this._ownerUserId;
  set ownerUserId(String? ownerUserId) => _$this._ownerUserId = ownerUserId;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _platform;
  String? get platform => _$this._platform;
  set platform(String? platform) => _$this._platform = platform;

  String? _appVersion;
  String? get appVersion => _$this._appVersion;
  set appVersion(String? appVersion) => _$this._appVersion = appVersion;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _lastSeenAt;
  DateTime? get lastSeenAt => _$this._lastSeenAt;
  set lastSeenAt(DateTime? lastSeenAt) => _$this._lastSeenAt = lastSeenAt;

  DateTime? _lastLoginAt;
  DateTime? get lastLoginAt => _$this._lastLoginAt;
  set lastLoginAt(DateTime? lastLoginAt) => _$this._lastLoginAt = lastLoginAt;

  DateTime? _lastPullAt;
  DateTime? get lastPullAt => _$this._lastPullAt;
  set lastPullAt(DateTime? lastPullAt) => _$this._lastPullAt = lastPullAt;

  DateTime? _lastPushAt;
  DateTime? get lastPushAt => _$this._lastPushAt;
  set lastPushAt(DateTime? lastPushAt) => _$this._lastPushAt = lastPushAt;

  DateTime? _revokedAt;
  DateTime? get revokedAt => _$this._revokedAt;
  set revokedAt(DateTime? revokedAt) => _$this._revokedAt = revokedAt;

  DeviceBuilder() {
    Device._defaults(this);
  }

  DeviceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _ownerUserId = $v.ownerUserId;
      _displayName = $v.displayName;
      _platform = $v.platform;
      _appVersion = $v.appVersion;
      _createdAt = $v.createdAt;
      _lastSeenAt = $v.lastSeenAt;
      _lastLoginAt = $v.lastLoginAt;
      _lastPullAt = $v.lastPullAt;
      _lastPushAt = $v.lastPushAt;
      _revokedAt = $v.revokedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Device other) {
    _$v = other as _$Device;
  }

  @override
  void update(void Function(DeviceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Device build() => _build();

  _$Device _build() {
    final _$result = _$v ??
        _$Device._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Device', 'id'),
          ownerUserId: BuiltValueNullFieldError.checkNotNull(
              ownerUserId, r'Device', 'ownerUserId'),
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName, r'Device', 'displayName'),
          platform: BuiltValueNullFieldError.checkNotNull(
              platform, r'Device', 'platform'),
          appVersion: BuiltValueNullFieldError.checkNotNull(
              appVersion, r'Device', 'appVersion'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'Device', 'createdAt'),
          lastSeenAt: lastSeenAt,
          lastLoginAt: lastLoginAt,
          lastPullAt: lastPullAt,
          lastPushAt: lastPushAt,
          revokedAt: revokedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
