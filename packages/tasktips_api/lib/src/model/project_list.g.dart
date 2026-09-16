// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProjectList extends ProjectList {
  @override
  final BuiltList<Project> items;
  @override
  final bool? hasMore;
  @override
  final int? nextOffset;
  @override
  final int? limit;
  @override
  final int? offset;

  factory _$ProjectList([void Function(ProjectListBuilder)? updates]) =>
      (ProjectListBuilder()..update(updates))._build();

  _$ProjectList._(
      {required this.items,
      this.hasMore,
      this.nextOffset,
      this.limit,
      this.offset})
      : super._();
  @override
  ProjectList rebuild(void Function(ProjectListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProjectListBuilder toBuilder() => ProjectListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProjectList &&
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
    return (newBuiltValueToStringHelper(r'ProjectList')
          ..add('items', items)
          ..add('hasMore', hasMore)
          ..add('nextOffset', nextOffset)
          ..add('limit', limit)
          ..add('offset', offset))
        .toString();
  }
}

class ProjectListBuilder implements Builder<ProjectList, ProjectListBuilder> {
  _$ProjectList? _$v;

  ListBuilder<Project>? _items;
  ListBuilder<Project> get items => _$this._items ??= ListBuilder<Project>();
  set items(ListBuilder<Project>? items) => _$this._items = items;

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

  ProjectListBuilder() {
    ProjectList._defaults(this);
  }

  ProjectListBuilder get _$this {
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
  void replace(ProjectList other) {
    _$v = other as _$ProjectList;
  }

  @override
  void update(void Function(ProjectListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProjectList build() => _build();

  _$ProjectList _build() {
    _$ProjectList _$result;
    try {
      _$result = _$v ??
          _$ProjectList._(
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
            r'ProjectList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
