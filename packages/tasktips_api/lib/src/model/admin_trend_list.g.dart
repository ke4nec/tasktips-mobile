// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_trend_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminTrendList extends AdminTrendList {
  @override
  final int days;
  @override
  final BuiltList<AdminTrendListItemsInner> items;

  factory _$AdminTrendList([void Function(AdminTrendListBuilder)? updates]) =>
      (AdminTrendListBuilder()..update(updates))._build();

  _$AdminTrendList._({required this.days, required this.items}) : super._();
  @override
  AdminTrendList rebuild(void Function(AdminTrendListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminTrendListBuilder toBuilder() => AdminTrendListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminTrendList &&
        days == other.days &&
        items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, days.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminTrendList')
          ..add('days', days)
          ..add('items', items))
        .toString();
  }
}

class AdminTrendListBuilder
    implements Builder<AdminTrendList, AdminTrendListBuilder> {
  _$AdminTrendList? _$v;

  int? _days;
  int? get days => _$this._days;
  set days(int? days) => _$this._days = days;

  ListBuilder<AdminTrendListItemsInner>? _items;
  ListBuilder<AdminTrendListItemsInner> get items =>
      _$this._items ??= ListBuilder<AdminTrendListItemsInner>();
  set items(ListBuilder<AdminTrendListItemsInner>? items) =>
      _$this._items = items;

  AdminTrendListBuilder() {
    AdminTrendList._defaults(this);
  }

  AdminTrendListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _days = $v.days;
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminTrendList other) {
    _$v = other as _$AdminTrendList;
  }

  @override
  void update(void Function(AdminTrendListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminTrendList build() => _build();

  _$AdminTrendList _build() {
    _$AdminTrendList _$result;
    try {
      _$result = _$v ??
          _$AdminTrendList._(
            days: BuiltValueNullFieldError.checkNotNull(
                days, r'AdminTrendList', 'days'),
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AdminTrendList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
