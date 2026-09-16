// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_history_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminHistoryResponse extends AdminHistoryResponse {
  @override
  final BuiltList<AdminHistoryItem> items;
  @override
  final bool hasMore;
  @override
  final int? nextSequence;

  factory _$AdminHistoryResponse(
          [void Function(AdminHistoryResponseBuilder)? updates]) =>
      (AdminHistoryResponseBuilder()..update(updates))._build();

  _$AdminHistoryResponse._(
      {required this.items, required this.hasMore, this.nextSequence})
      : super._();
  @override
  AdminHistoryResponse rebuild(
          void Function(AdminHistoryResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminHistoryResponseBuilder toBuilder() =>
      AdminHistoryResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminHistoryResponse &&
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
    return (newBuiltValueToStringHelper(r'AdminHistoryResponse')
          ..add('items', items)
          ..add('hasMore', hasMore)
          ..add('nextSequence', nextSequence))
        .toString();
  }
}

class AdminHistoryResponseBuilder
    implements Builder<AdminHistoryResponse, AdminHistoryResponseBuilder> {
  _$AdminHistoryResponse? _$v;

  ListBuilder<AdminHistoryItem>? _items;
  ListBuilder<AdminHistoryItem> get items =>
      _$this._items ??= ListBuilder<AdminHistoryItem>();
  set items(ListBuilder<AdminHistoryItem>? items) => _$this._items = items;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  int? _nextSequence;
  int? get nextSequence => _$this._nextSequence;
  set nextSequence(int? nextSequence) => _$this._nextSequence = nextSequence;

  AdminHistoryResponseBuilder() {
    AdminHistoryResponse._defaults(this);
  }

  AdminHistoryResponseBuilder get _$this {
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
  void replace(AdminHistoryResponse other) {
    _$v = other as _$AdminHistoryResponse;
  }

  @override
  void update(void Function(AdminHistoryResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminHistoryResponse build() => _build();

  _$AdminHistoryResponse _build() {
    _$AdminHistoryResponse _$result;
    try {
      _$result = _$v ??
          _$AdminHistoryResponse._(
            items: items.build(),
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'AdminHistoryResponse', 'hasMore'),
            nextSequence: nextSequence,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AdminHistoryResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
