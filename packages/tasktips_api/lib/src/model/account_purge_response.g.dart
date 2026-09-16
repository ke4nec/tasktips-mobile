// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_purge_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AccountPurgeResponseStatusEnum _$accountPurgeResponseStatusEnum_queued =
    const AccountPurgeResponseStatusEnum._('queued');
const AccountPurgeResponseStatusEnum _$accountPurgeResponseStatusEnum_running =
    const AccountPurgeResponseStatusEnum._('running');
const AccountPurgeResponseStatusEnum _$accountPurgeResponseStatusEnum_ready =
    const AccountPurgeResponseStatusEnum._('ready');

AccountPurgeResponseStatusEnum _$accountPurgeResponseStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'queued':
      return _$accountPurgeResponseStatusEnum_queued;
    case 'running':
      return _$accountPurgeResponseStatusEnum_running;
    case 'ready':
      return _$accountPurgeResponseStatusEnum_ready;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AccountPurgeResponseStatusEnum>
    _$accountPurgeResponseStatusEnumValues = BuiltSet<
        AccountPurgeResponseStatusEnum>(const <AccountPurgeResponseStatusEnum>[
  _$accountPurgeResponseStatusEnum_queued,
  _$accountPurgeResponseStatusEnum_running,
  _$accountPurgeResponseStatusEnum_ready,
]);

Serializer<AccountPurgeResponseStatusEnum>
    _$accountPurgeResponseStatusEnumSerializer =
    _$AccountPurgeResponseStatusEnumSerializer();

class _$AccountPurgeResponseStatusEnumSerializer
    implements PrimitiveSerializer<AccountPurgeResponseStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'queued': 'queued',
    'running': 'running',
    'ready': 'ready',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'queued': 'queued',
    'running': 'running',
    'ready': 'ready',
  };

  @override
  final Iterable<Type> types = const <Type>[AccountPurgeResponseStatusEnum];
  @override
  final String wireName = 'AccountPurgeResponseStatusEnum';

  @override
  Object serialize(
          Serializers serializers, AccountPurgeResponseStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AccountPurgeResponseStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AccountPurgeResponseStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AccountPurgeResponse extends AccountPurgeResponse {
  @override
  final String jobId;
  @override
  final String exportId;
  @override
  final AccountPurgeResponseStatusEnum status;
  @override
  final bool confirmationRequired;

  factory _$AccountPurgeResponse(
          [void Function(AccountPurgeResponseBuilder)? updates]) =>
      (AccountPurgeResponseBuilder()..update(updates))._build();

  _$AccountPurgeResponse._(
      {required this.jobId,
      required this.exportId,
      required this.status,
      required this.confirmationRequired})
      : super._();
  @override
  AccountPurgeResponse rebuild(
          void Function(AccountPurgeResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AccountPurgeResponseBuilder toBuilder() =>
      AccountPurgeResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AccountPurgeResponse &&
        jobId == other.jobId &&
        exportId == other.exportId &&
        status == other.status &&
        confirmationRequired == other.confirmationRequired;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, jobId.hashCode);
    _$hash = $jc(_$hash, exportId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, confirmationRequired.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AccountPurgeResponse')
          ..add('jobId', jobId)
          ..add('exportId', exportId)
          ..add('status', status)
          ..add('confirmationRequired', confirmationRequired))
        .toString();
  }
}

class AccountPurgeResponseBuilder
    implements Builder<AccountPurgeResponse, AccountPurgeResponseBuilder> {
  _$AccountPurgeResponse? _$v;

  String? _jobId;
  String? get jobId => _$this._jobId;
  set jobId(String? jobId) => _$this._jobId = jobId;

  String? _exportId;
  String? get exportId => _$this._exportId;
  set exportId(String? exportId) => _$this._exportId = exportId;

  AccountPurgeResponseStatusEnum? _status;
  AccountPurgeResponseStatusEnum? get status => _$this._status;
  set status(AccountPurgeResponseStatusEnum? status) => _$this._status = status;

  bool? _confirmationRequired;
  bool? get confirmationRequired => _$this._confirmationRequired;
  set confirmationRequired(bool? confirmationRequired) =>
      _$this._confirmationRequired = confirmationRequired;

  AccountPurgeResponseBuilder() {
    AccountPurgeResponse._defaults(this);
  }

  AccountPurgeResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _jobId = $v.jobId;
      _exportId = $v.exportId;
      _status = $v.status;
      _confirmationRequired = $v.confirmationRequired;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AccountPurgeResponse other) {
    _$v = other as _$AccountPurgeResponse;
  }

  @override
  void update(void Function(AccountPurgeResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AccountPurgeResponse build() => _build();

  _$AccountPurgeResponse _build() {
    final _$result = _$v ??
        _$AccountPurgeResponse._(
          jobId: BuiltValueNullFieldError.checkNotNull(
              jobId, r'AccountPurgeResponse', 'jobId'),
          exportId: BuiltValueNullFieldError.checkNotNull(
              exportId, r'AccountPurgeResponse', 'exportId'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'AccountPurgeResponse', 'status'),
          confirmationRequired: BuiltValueNullFieldError.checkNotNull(
              confirmationRequired,
              r'AccountPurgeResponse',
              'confirmationRequired'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
