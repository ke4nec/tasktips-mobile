// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purge_project_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PurgeProjectRequest extends PurgeProjectRequest {
  @override
  final String password;
  @override
  final String reason;

  factory _$PurgeProjectRequest(
          [void Function(PurgeProjectRequestBuilder)? updates]) =>
      (PurgeProjectRequestBuilder()..update(updates))._build();

  _$PurgeProjectRequest._({required this.password, required this.reason})
      : super._();
  @override
  PurgeProjectRequest rebuild(
          void Function(PurgeProjectRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PurgeProjectRequestBuilder toBuilder() =>
      PurgeProjectRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PurgeProjectRequest &&
        password == other.password &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PurgeProjectRequest')
          ..add('password', password)
          ..add('reason', reason))
        .toString();
  }
}

class PurgeProjectRequestBuilder
    implements Builder<PurgeProjectRequest, PurgeProjectRequestBuilder> {
  _$PurgeProjectRequest? _$v;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  PurgeProjectRequestBuilder() {
    PurgeProjectRequest._defaults(this);
  }

  PurgeProjectRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _password = $v.password;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PurgeProjectRequest other) {
    _$v = other as _$PurgeProjectRequest;
  }

  @override
  void update(void Function(PurgeProjectRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PurgeProjectRequest build() => _build();

  _$PurgeProjectRequest _build() {
    final _$result = _$v ??
        _$PurgeProjectRequest._(
          password: BuiltValueNullFieldError.checkNotNull(
              password, r'PurgeProjectRequest', 'password'),
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'PurgeProjectRequest', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
