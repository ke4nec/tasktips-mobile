// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pull_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PullRequest extends PullRequest {
  @override
  final String cursor;
  @override
  final int? limit;

  factory _$PullRequest([void Function(PullRequestBuilder)? updates]) =>
      (PullRequestBuilder()..update(updates))._build();

  _$PullRequest._({required this.cursor, this.limit}) : super._();
  @override
  PullRequest rebuild(void Function(PullRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PullRequestBuilder toBuilder() => PullRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PullRequest &&
        cursor == other.cursor &&
        limit == other.limit;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cursor.hashCode);
    _$hash = $jc(_$hash, limit.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PullRequest')
          ..add('cursor', cursor)
          ..add('limit', limit))
        .toString();
  }
}

class PullRequestBuilder implements Builder<PullRequest, PullRequestBuilder> {
  _$PullRequest? _$v;

  String? _cursor;
  String? get cursor => _$this._cursor;
  set cursor(String? cursor) => _$this._cursor = cursor;

  int? _limit;
  int? get limit => _$this._limit;
  set limit(int? limit) => _$this._limit = limit;

  PullRequestBuilder() {
    PullRequest._defaults(this);
  }

  PullRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _cursor = $v.cursor;
      _limit = $v.limit;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PullRequest other) {
    _$v = other as _$PullRequest;
  }

  @override
  void update(void Function(PullRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PullRequest build() => _build();

  _$PullRequest _build() {
    final _$result = _$v ??
        _$PullRequest._(
          cursor: BuiltValueNullFieldError.checkNotNull(
              cursor, r'PullRequest', 'cursor'),
          limit: limit,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
