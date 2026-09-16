// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_overview.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminOverview extends AdminOverview {
  @override
  final int users;
  @override
  final int activeUsers;
  @override
  final int projects;
  @override
  final int devices;
  @override
  final int revisions;
  @override
  final int tombstones;
  @override
  final int payloadBytes;
  @override
  final int queuedRestores;

  factory _$AdminOverview([void Function(AdminOverviewBuilder)? updates]) =>
      (AdminOverviewBuilder()..update(updates))._build();

  _$AdminOverview._(
      {required this.users,
      required this.activeUsers,
      required this.projects,
      required this.devices,
      required this.revisions,
      required this.tombstones,
      required this.payloadBytes,
      required this.queuedRestores})
      : super._();
  @override
  AdminOverview rebuild(void Function(AdminOverviewBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminOverviewBuilder toBuilder() => AdminOverviewBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminOverview &&
        users == other.users &&
        activeUsers == other.activeUsers &&
        projects == other.projects &&
        devices == other.devices &&
        revisions == other.revisions &&
        tombstones == other.tombstones &&
        payloadBytes == other.payloadBytes &&
        queuedRestores == other.queuedRestores;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, users.hashCode);
    _$hash = $jc(_$hash, activeUsers.hashCode);
    _$hash = $jc(_$hash, projects.hashCode);
    _$hash = $jc(_$hash, devices.hashCode);
    _$hash = $jc(_$hash, revisions.hashCode);
    _$hash = $jc(_$hash, tombstones.hashCode);
    _$hash = $jc(_$hash, payloadBytes.hashCode);
    _$hash = $jc(_$hash, queuedRestores.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminOverview')
          ..add('users', users)
          ..add('activeUsers', activeUsers)
          ..add('projects', projects)
          ..add('devices', devices)
          ..add('revisions', revisions)
          ..add('tombstones', tombstones)
          ..add('payloadBytes', payloadBytes)
          ..add('queuedRestores', queuedRestores))
        .toString();
  }
}

class AdminOverviewBuilder
    implements Builder<AdminOverview, AdminOverviewBuilder> {
  _$AdminOverview? _$v;

  int? _users;
  int? get users => _$this._users;
  set users(int? users) => _$this._users = users;

  int? _activeUsers;
  int? get activeUsers => _$this._activeUsers;
  set activeUsers(int? activeUsers) => _$this._activeUsers = activeUsers;

  int? _projects;
  int? get projects => _$this._projects;
  set projects(int? projects) => _$this._projects = projects;

  int? _devices;
  int? get devices => _$this._devices;
  set devices(int? devices) => _$this._devices = devices;

  int? _revisions;
  int? get revisions => _$this._revisions;
  set revisions(int? revisions) => _$this._revisions = revisions;

  int? _tombstones;
  int? get tombstones => _$this._tombstones;
  set tombstones(int? tombstones) => _$this._tombstones = tombstones;

  int? _payloadBytes;
  int? get payloadBytes => _$this._payloadBytes;
  set payloadBytes(int? payloadBytes) => _$this._payloadBytes = payloadBytes;

  int? _queuedRestores;
  int? get queuedRestores => _$this._queuedRestores;
  set queuedRestores(int? queuedRestores) =>
      _$this._queuedRestores = queuedRestores;

  AdminOverviewBuilder() {
    AdminOverview._defaults(this);
  }

  AdminOverviewBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _users = $v.users;
      _activeUsers = $v.activeUsers;
      _projects = $v.projects;
      _devices = $v.devices;
      _revisions = $v.revisions;
      _tombstones = $v.tombstones;
      _payloadBytes = $v.payloadBytes;
      _queuedRestores = $v.queuedRestores;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminOverview other) {
    _$v = other as _$AdminOverview;
  }

  @override
  void update(void Function(AdminOverviewBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminOverview build() => _build();

  _$AdminOverview _build() {
    final _$result = _$v ??
        _$AdminOverview._(
          users: BuiltValueNullFieldError.checkNotNull(
              users, r'AdminOverview', 'users'),
          activeUsers: BuiltValueNullFieldError.checkNotNull(
              activeUsers, r'AdminOverview', 'activeUsers'),
          projects: BuiltValueNullFieldError.checkNotNull(
              projects, r'AdminOverview', 'projects'),
          devices: BuiltValueNullFieldError.checkNotNull(
              devices, r'AdminOverview', 'devices'),
          revisions: BuiltValueNullFieldError.checkNotNull(
              revisions, r'AdminOverview', 'revisions'),
          tombstones: BuiltValueNullFieldError.checkNotNull(
              tombstones, r'AdminOverview', 'tombstones'),
          payloadBytes: BuiltValueNullFieldError.checkNotNull(
              payloadBytes, r'AdminOverview', 'payloadBytes'),
          queuedRestores: BuiltValueNullFieldError.checkNotNull(
              queuedRestores, r'AdminOverview', 'queuedRestores'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
