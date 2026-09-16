// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$HistoryResponse extends HistoryResponse {
  @override
  final BuiltList<SyncChange> items;
  @override
  final bool hasMore;
  @override
  final int? nextSequence;

  factory _$HistoryResponse([void Function(HistoryResponseBuilder)? updates]) =>
      (HistoryResponseBuilder()..update(updates))._build();

  _$HistoryResponse._(
      {required this.items, required this.hasMore, this.nextSequence})
      : super._();
  @override
  HistoryResponse rebuild(void Function(HistoryResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  HistoryResponseBuilder toBuilder() => HistoryResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HistoryResponse &&
        items == other.items &&
        hasMore == other.hasMore &&
        nextSequence == other.nextSequence;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, hasMore.hashCode);
    _$hash = $jc(_$hash, nextSequence.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'HistoryResponse')
          ..add('items', items)
          ..add('hasMore', hasMore)
          ..add('nextSequence', nextSequence))
        .toString();
  }
}

class HistoryResponseBuilder
    implements Builder<HistoryResponse, HistoryResponseBuilder> {
  _$HistoryResponse? _$v;

  ListBuilder<SyncChange>? _items;
  ListBuilder<SyncChange> get items =>
      _$this._items ??= ListBuilder<SyncChange>();
  set items(ListBuilder<SyncChange>? items) => _$this._items = items;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  int? _nextSequence;
  int? get nextSequence => _$this._nextSequence;
  set nextSequence(int? nextSequence) => _$this._nextSequence = nextSequence;

  HistoryResponseBuilder() {
    HistoryResponse._defaults(this);
  }

  HistoryResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _hasMore = $v.hasMore;
      _nextSequence = $v.nextSequence;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HistoryResponse other) {
    _$v = other as _$HistoryResponse;
  }

  @override
  void update(void Function(HistoryResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HistoryResponse build() => _build();

  _$HistoryResponse _build() {
    _$HistoryResponse _$result;
    try {
      _$result = _$v ??
          _$HistoryResponse._(
            items: items.build(),
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'HistoryResponse', 'hasMore'),
            nextSequence: nextSequence,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'HistoryResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
