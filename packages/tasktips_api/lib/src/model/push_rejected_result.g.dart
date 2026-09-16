// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_rejected_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PushRejectedResult extends PushRejectedResult {
  @override
  final JsonObject? status;
  @override
  final ObjectKind kind;
  @override
  final String id;
  @override
  final ErrorCode code;
  @override
  final String? message;
  @override
  final ErrorDetails? details;

  factory _$PushRejectedResult(
          [void Function(PushRejectedResultBuilder)? updates]) =>
      (PushRejectedResultBuilder()..update(updates))._build();

  _$PushRejectedResult._(
      {this.status,
      required this.kind,
      required this.id,
      required this.code,
      this.message,
      this.details})
      : super._();
  @override
  PushRejectedResult rebuild(
          void Function(PushRejectedResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PushRejectedResultBuilder toBuilder() =>
      PushRejectedResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PushRejectedResult &&
        status == other.status &&
        kind == other.kind &&
        id == other.id &&
        code == other.code &&
        message == other.message &&
        details == other.details;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jc(_$hash, details.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PushRejectedResult')
          ..add('status', status)
          ..add('kind', kind)
          ..add('id', id)
          ..add('code', code)
          ..add('message', message)
          ..add('details', details))
        .toString();
  }
}

class PushRejectedResultBuilder
    implements Builder<PushRejectedResult, PushRejectedResultBuilder> {
  _$PushRejectedResult? _$v;

  JsonObject? _status;
  JsonObject? get status => _$this._status;
  set status(JsonObject? status) => _$this._status = status;

  ObjectKind? _kind;
  ObjectKind? get kind => _$this._kind;
  set kind(ObjectKind? kind) => _$this._kind = kind;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  ErrorCode? _code;
  ErrorCode? get code => _$this._code;
  set code(ErrorCode? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  ErrorDetailsBuilder? _details;
  ErrorDetailsBuilder get details => _$this._details ??= ErrorDetailsBuilder();
  set details(ErrorDetailsBuilder? details) => _$this._details = details;

  PushRejectedResultBuilder() {
    PushRejectedResult._defaults(this);
  }

  PushRejectedResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _kind = $v.kind;
      _id = $v.id;
      _code = $v.code;
      _message = $v.message;
      _details = $v.details?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PushRejectedResult other) {
    _$v = other as _$PushRejectedResult;
  }

  @override
  void update(void Function(PushRejectedResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PushRejectedResult build() => _build();

  _$PushRejectedResult _build() {
    _$PushRejectedResult _$result;
    try {
      _$result = _$v ??
          _$PushRejectedResult._(
            status: status,
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'PushRejectedResult', 'kind'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'PushRejectedResult', 'id'),
            code: BuiltValueNullFieldError.checkNotNull(
                code, r'PushRejectedResult', 'code'),
            message: message,
            details: _details?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'details';
        _details?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PushRejectedResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
