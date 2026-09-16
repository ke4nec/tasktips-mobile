// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PushResponse extends PushResponse {
  @override
  final int generation;
  @override
  final BuiltList<PushItemResult> results;

  factory _$PushResponse([void Function(PushResponseBuilder)? updates]) =>
      (PushResponseBuilder()..update(updates))._build();

  _$PushResponse._({required this.generation, required this.results})
      : super._();
  @override
  PushResponse rebuild(void Function(PushResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PushResponseBuilder toBuilder() => PushResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PushResponse &&
        generation == other.generation &&
        results == other.results;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, generation.hashCode);
    _$hash = $jc(_$hash, results.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PushResponse')
          ..add('generation', generation)
          ..add('results', results))
        .toString();
  }
}

class PushResponseBuilder
    implements Builder<PushResponse, PushResponseBuilder> {
  _$PushResponse? _$v;

  int? _generation;
  int? get generation => _$this._generation;
  set generation(int? generation) => _$this._generation = generation;

  ListBuilder<PushItemResult>? _results;
  ListBuilder<PushItemResult> get results =>
      _$this._results ??= ListBuilder<PushItemResult>();
  set results(ListBuilder<PushItemResult>? results) =>
      _$this._results = results;

  PushResponseBuilder() {
    PushResponse._defaults(this);
  }

  PushResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _generation = $v.generation;
      _results = $v.results.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PushResponse other) {
    _$v = other as _$PushResponse;
  }

  @override
  void update(void Function(PushResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PushResponse build() => _build();

  _$PushResponse _build() {
    _$PushResponse _$result;
    try {
      _$result = _$v ??
          _$PushResponse._(
            generation: BuiltValueNullFieldError.checkNotNull(
                generation, r'PushResponse', 'generation'),
            results: results.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'results';
        results.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PushResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
