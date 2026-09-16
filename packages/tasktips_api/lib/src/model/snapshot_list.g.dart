// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snapshot_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SnapshotList extends SnapshotList {
  @override
  final BuiltList<Snapshot> items;

  factory _$SnapshotList([void Function(SnapshotListBuilder)? updates]) =>
      (SnapshotListBuilder()..update(updates))._build();

  _$SnapshotList._({required this.items}) : super._();
  @override
  SnapshotList rebuild(void Function(SnapshotListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SnapshotListBuilder toBuilder() => SnapshotListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SnapshotList && items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SnapshotList')..add('items', items))
        .toString();
  }
}

class SnapshotListBuilder
    implements Builder<SnapshotList, SnapshotListBuilder> {
  _$SnapshotList? _$v;

  ListBuilder<Snapshot>? _items;
  ListBuilder<Snapshot> get items => _$this._items ??= ListBuilder<Snapshot>();
  set items(ListBuilder<Snapshot>? items) => _$this._items = items;

  SnapshotListBuilder() {
    SnapshotList._defaults(this);
  }

  SnapshotListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SnapshotList other) {
    _$v = other as _$SnapshotList;
  }

  @override
  void update(void Function(SnapshotListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SnapshotList build() => _build();

  _$SnapshotList _build() {
    _$SnapshotList _$result;
    try {
      _$result = _$v ??
          _$SnapshotList._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SnapshotList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
