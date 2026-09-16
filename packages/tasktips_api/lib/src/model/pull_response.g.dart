// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pull_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PullResponse extends PullResponse {
  @override
  final int generation;
  @override
  final BuiltList<SyncChange> changes;
  @override
  final String nextCursor;
  @override
  final bool hasMore;

  factory _$PullResponse([void Function(PullResponseBuilder)? updates]) =>
      (PullResponseBuilder()..update(updates))._build();

  _$PullResponse._(
      {required this.generation,
      required this.changes,
      required this.nextCursor,
      required this.hasMore})
      : super._();
  @override
  PullResponse rebuild(void Function(PullResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PullResponseBuilder toBuilder() => PullResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PullResponse &&
        generation == other.generation &&
        changes == other.changes &&
        nextCursor == other.nextCursor &&
        hasMore == other.hasMore;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, generation.hashCode);
    _$hash = $jc(_$hash, changes.hashCode);
    _$hash = $jc(_$hash, nextCursor.hashCode);
    _$hash = $jc(_$hash, hasMore.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PullResponse')
          ..add('generation', generation)
          ..add('changes', changes)
          ..add('nextCursor', nextCursor)
          ..add('hasMore', hasMore))
        .toString();
  }
}

class PullResponseBuilder
    implements Builder<PullResponse, PullResponseBuilder> {
  _$PullResponse? _$v;

  int? _generation;
  int? get generation => _$this._generation;
  set generation(int? generation) => _$this._generation = generation;

  ListBuilder<SyncChange>? _changes;
  ListBuilder<SyncChange> get changes =>
      _$this._changes ??= ListBuilder<SyncChange>();
  set changes(ListBuilder<SyncChange>? changes) => _$this._changes = changes;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  PullResponseBuilder() {
    PullResponse._defaults(this);
  }

  PullResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _generation = $v.generation;
      _changes = $v.changes.toBuilder();
      _nextCursor = $v.nextCursor;
      _hasMore = $v.hasMore;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PullResponse other) {
    _$v = other as _$PullResponse;
  }

  @override
  void update(void Function(PullResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PullResponse build() => _build();

  _$PullResponse _build() {
    _$PullResponse _$result;
    try {
      _$result = _$v ??
          _$PullResponse._(
            generation: BuiltValueNullFieldError.checkNotNull(
                generation, r'PullResponse', 'generation'),
            changes: changes.build(),
            nextCursor: BuiltValueNullFieldError.checkNotNull(
                nextCursor, r'PullResponse', 'nextCursor'),
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'PullResponse', 'hasMore'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'changes';
        changes.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PullResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
