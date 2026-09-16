// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_details.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ErrorDetails extends ErrorDetails {
  @override
  final int? expectedRevision;
  @override
  final int? actualRevision;
  @override
  final int? expectedGeneration;
  @override
  final int? actualGeneration;
  @override
  final ObjectKind? kind;
  @override
  final int? maxBytes;
  @override
  final int? actualBytes;

  factory _$ErrorDetails([void Function(ErrorDetailsBuilder)? updates]) =>
      (ErrorDetailsBuilder()..update(updates))._build();

  _$ErrorDetails._(
      {this.expectedRevision,
      this.actualRevision,
      this.expectedGeneration,
      this.actualGeneration,
      this.kind,
      this.maxBytes,
      this.actualBytes})
      : super._();
  @override
  ErrorDetails rebuild(void Function(ErrorDetailsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ErrorDetailsBuilder toBuilder() => ErrorDetailsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ErrorDetails &&
        expectedRevision == other.expectedRevision &&
        actualRevision == other.actualRevision &&
        expectedGeneration == other.expectedGeneration &&
        actualGeneration == other.actualGeneration &&
        kind == other.kind &&
        maxBytes == other.maxBytes &&
        actualBytes == other.actualBytes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expectedRevision.hashCode);
    _$hash = $jc(_$hash, actualRevision.hashCode);
    _$hash = $jc(_$hash, expectedGeneration.hashCode);
    _$hash = $jc(_$hash, actualGeneration.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, maxBytes.hashCode);
    _$hash = $jc(_$hash, actualBytes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ErrorDetails')
          ..add('expectedRevision', expectedRevision)
          ..add('actualRevision', actualRevision)
          ..add('expectedGeneration', expectedGeneration)
          ..add('actualGeneration', actualGeneration)
          ..add('kind', kind)
          ..add('maxBytes', maxBytes)
          ..add('actualBytes', actualBytes))
        .toString();
  }
}

class ErrorDetailsBuilder
    implements Builder<ErrorDetails, ErrorDetailsBuilder> {
  _$ErrorDetails? _$v;

  int? _expectedRevision;
  int? get expectedRevision => _$this._expectedRevision;
  set expectedRevision(int? expectedRevision) =>
      _$this._expectedRevision = expectedRevision;

  int? _actualRevision;
  int? get actualRevision => _$this._actualRevision;
  set actualRevision(int? actualRevision) =>
      _$this._actualRevision = actualRevision;

  int? _expectedGeneration;
  int? get expectedGeneration => _$this._expectedGeneration;
  set expectedGeneration(int? expectedGeneration) =>
      _$this._expectedGeneration = expectedGeneration;

  int? _actualGeneration;
  int? get actualGeneration => _$this._actualGeneration;
  set actualGeneration(int? actualGeneration) =>
      _$this._actualGeneration = actualGeneration;

  ObjectKind? _kind;
  ObjectKind? get kind => _$this._kind;
  set kind(ObjectKind? kind) => _$this._kind = kind;

  int? _maxBytes;
  int? get maxBytes => _$this._maxBytes;
  set maxBytes(int? maxBytes) => _$this._maxBytes = maxBytes;

  int? _actualBytes;
  int? get actualBytes => _$this._actualBytes;
  set actualBytes(int? actualBytes) => _$this._actualBytes = actualBytes;

  ErrorDetailsBuilder() {
    ErrorDetails._defaults(this);
  }

  ErrorDetailsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expectedRevision = $v.expectedRevision;
      _actualRevision = $v.actualRevision;
      _expectedGeneration = $v.expectedGeneration;
      _actualGeneration = $v.actualGeneration;
      _kind = $v.kind;
      _maxBytes = $v.maxBytes;
      _actualBytes = $v.actualBytes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ErrorDetails other) {
    _$v = other as _$ErrorDetails;
  }

  @override
  void update(void Function(ErrorDetailsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ErrorDetails build() => _build();

  _$ErrorDetails _build() {
    final _$result = _$v ??
        _$ErrorDetails._(
          expectedRevision: expectedRevision,
          actualRevision: actualRevision,
          expectedGeneration: expectedGeneration,
          actualGeneration: actualGeneration,
          kind: kind,
          maxBytes: maxBytes,
          actualBytes: actualBytes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
