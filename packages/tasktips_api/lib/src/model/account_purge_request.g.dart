// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_purge_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AccountPurgeRequest extends AccountPurgeRequest {
  @override
  final String? exportId;
  @override
  final bool confirmed;
  @override
  final String reason;

  factory _$AccountPurgeRequest(
          [void Function(AccountPurgeRequestBuilder)? updates]) =>
      (AccountPurgeRequestBuilder()..update(updates))._build();

  _$AccountPurgeRequest._(
      {this.exportId, required this.confirmed, required this.reason})
      : super._();
  @override
  AccountPurgeRequest rebuild(
          void Function(AccountPurgeRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AccountPurgeRequestBuilder toBuilder() =>
      AccountPurgeRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AccountPurgeRequest &&
        exportId == other.exportId &&
        confirmed == other.confirmed &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, exportId.hashCode);
    _$hash = $jc(_$hash, confirmed.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AccountPurgeRequest')
          ..add('exportId', exportId)
          ..add('confirmed', confirmed)
          ..add('reason', reason))
        .toString();
  }
}

class AccountPurgeRequestBuilder
    implements Builder<AccountPurgeRequest, AccountPurgeRequestBuilder> {
  _$AccountPurgeRequest? _$v;

  String? _exportId;
  String? get exportId => _$this._exportId;
  set exportId(String? exportId) => _$this._exportId = exportId;

  bool? _confirmed;
  bool? get confirmed => _$this._confirmed;
  set confirmed(bool? confirmed) => _$this._confirmed = confirmed;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  AccountPurgeRequestBuilder() {
    AccountPurgeRequest._defaults(this);
  }

  AccountPurgeRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _exportId = $v.exportId;
      _confirmed = $v.confirmed;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AccountPurgeRequest other) {
    _$v = other as _$AccountPurgeRequest;
  }

  @override
  void update(void Function(AccountPurgeRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AccountPurgeRequest build() => _build();

  _$AccountPurgeRequest _build() {
    final _$result = _$v ??
        _$AccountPurgeRequest._(
          exportId: exportId,
          confirmed: BuiltValueNullFieldError.checkNotNull(
              confirmed, r'AccountPurgeRequest', 'confirmed'),
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'AccountPurgeRequest', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
