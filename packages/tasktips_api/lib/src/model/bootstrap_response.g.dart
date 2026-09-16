// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bootstrap_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BootstrapResponse extends BootstrapResponse {
  @override
  final int generation;
  @override
  final BuiltList<SyncChange> items;
  @override
  final bool hasMore;
  @override
  final String? nextPageToken;
  @override
  final String? cursor;

  factory _$BootstrapResponse(
          [void Function(BootstrapResponseBuilder)? updates]) =>
      (BootstrapResponseBuilder()..update(updates))._build();

  _$BootstrapResponse._(
      {required this.generation,
      required this.items,
      required this.hasMore,
      this.nextPageToken,
      this.cursor})
      : super._();
  @override
  BootstrapResponse rebuild(void Function(BootstrapResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BootstrapResponseBuilder toBuilder() =>
      BootstrapResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BootstrapResponse &&
        generation == other.generation &&
        items == other.items &&
        hasMore == other.hasMore &&
        nextPageToken == other.nextPageToken &&
        cursor == other.cursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, generation.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, hasMore.hashCode);
    _$hash = $jc(_$hash, nextPageToken.hashCode);
    _$hash = $jc(_$hash, cursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BootstrapResponse')
          ..add('generation', generation)
          ..add('items', items)
          ..add('hasMore', hasMore)
          ..add('nextPageToken', nextPageToken)
          ..add('cursor', cursor))
        .toString();
  }
}

class BootstrapResponseBuilder
    implements Builder<BootstrapResponse, BootstrapResponseBuilder> {
  _$BootstrapResponse? _$v;

  int? _generation;
  int? get generation => _$this._generation;
  set generation(int? generation) => _$this._generation = generation;

  ListBuilder<SyncChange>? _items;
  ListBuilder<SyncChange> get items =>
      _$this._items ??= ListBuilder<SyncChange>();
  set items(ListBuilder<SyncChange>? items) => _$this._items = items;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  String? _nextPageToken;
  String? get nextPageToken => _$this._nextPageToken;
  set nextPageToken(String? nextPageToken) =>
      _$this._nextPageToken = nextPageToken;

  String? _cursor;
  String? get cursor => _$this._cursor;
  set cursor(String? cursor) => _$this._cursor = cursor;

  BootstrapResponseBuilder() {
    BootstrapResponse._defaults(this);
  }

  BootstrapResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _generation = $v.generation;
      _items = $v.items.toBuilder();
      _hasMore = $v.hasMore;
      _nextPageToken = $v.nextPageToken;
      _cursor = $v.cursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BootstrapResponse other) {
    _$v = other as _$BootstrapResponse;
  }

  @override
  void update(void Function(BootstrapResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BootstrapResponse build() => _build();

  _$BootstrapResponse _build() {
    _$BootstrapResponse _$result;
    try {
      _$result = _$v ??
          _$BootstrapResponse._(
            generation: BuiltValueNullFieldError.checkNotNull(
                generation, r'BootstrapResponse', 'generation'),
            items: items.build(),
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'BootstrapResponse', 'hasMore'),
            nextPageToken: nextPageToken,
            cursor: cursor,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BootstrapResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
