// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_operation_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminOperationList extends AdminOperationList {
  @override
  final BuiltList<AdminOperation> items;
  @override
  final bool? hasMore;
  @override
  final int? nextOffset;
  @override
  final int? limit;
  @override
  final int? offset;

  factory _$AdminOperationList(
          [void Function(AdminOperationListBuilder)? updates]) =>
      (AdminOperationListBuilder()..update(updates))._build();

  _$AdminOperationList._(
      {required this.items,
      this.hasMore,
      this.nextOffset,
      this.limit,
      this.offset})
      : super._();
  @override
  AdminOperationList rebuild(
          void Function(AdminOperationListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminOperationListBuilder toBuilder() =>
      AdminOperationListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminOperationList &&
        items == other.items &&
        hasMore == other.hasMore &&
        nextOffset == other.nextOffset &&
        limit == other.limit &&
        offset == other.offset;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, hasMore.hashCode);
    _$hash = $jc(_$hash, nextOffset.hashCode);
    _$hash = $jc(_$hash, limit.hashCode);
    _$hash = $jc(_$hash, offset.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminOperationList')
          ..add('items', items)
          ..add('hasMore', hasMore)
          ..add('nextOffset', nextOffset)
          ..add('limit', limit)
          ..add('offset', offset))
        .toString();
  }
}

class AdminOperationListBuilder
    implements Builder<AdminOperationList, AdminOperationListBuilder> {
  _$AdminOperationList? _$v;

  ListBuilder<AdminOperation>? _items;
  ListBuilder<AdminOperation> get items =>
      _$this._items ??= ListBuilder<AdminOperation>();
  set items(ListBuilder<AdminOperation>? items) => _$this._items = items;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  int? _nextOffset;
  int? get nextOffset => _$this._nextOffset;
  set nextOffset(int? nextOffset) => _$this._nextOffset = nextOffset;

  int? _limit;
  int? get limit => _$this._limit;
  set limit(int? limit) => _$this._limit = limit;

  int? _offset;
  int? get offset => _$this._offset;
  set offset(int? offset) => _$this._offset = offset;

  AdminOperationListBuilder() {
    AdminOperationList._defaults(this);
  }

  AdminOperationListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _hasMore = $v.hasMore;
      _nextOffset = $v.nextOffset;
      _limit = $v.limit;
      _offset = $v.offset;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminOperationList other) {
    _$v = other as _$AdminOperationList;
  }

  @override
  void update(void Function(AdminOperationListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminOperationList build() => _build();

  _$AdminOperationList _build() {
    _$AdminOperationList _$result;
    try {
      _$result = _$v ??
          _$AdminOperationList._(
            items: items.build(),
            hasMore: hasMore,
            nextOffset: nextOffset,
            limit: limit,
            offset: offset,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AdminOperationList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
