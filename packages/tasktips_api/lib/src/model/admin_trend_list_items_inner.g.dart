// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_trend_list_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminTrendListItemsInner extends AdminTrendListItemsInner {
  @override
  final DateTime day;
  @override
  final int attempts;
  @override
  final int succeeded;
  @override
  final int conflicts;
  @override
  final num? p50LatencyMs;
  @override
  final num? p99LatencyMs;

  factory _$AdminTrendListItemsInner(
          [void Function(AdminTrendListItemsInnerBuilder)? updates]) =>
      (AdminTrendListItemsInnerBuilder()..update(updates))._build();

  _$AdminTrendListItemsInner._(
      {required this.day,
      required this.attempts,
      required this.succeeded,
      required this.conflicts,
      this.p50LatencyMs,
      this.p99LatencyMs})
      : super._();
  @override
  AdminTrendListItemsInner rebuild(
          void Function(AdminTrendListItemsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminTrendListItemsInnerBuilder toBuilder() =>
      AdminTrendListItemsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminTrendListItemsInner &&
        day == other.day &&
        attempts == other.attempts &&
        succeeded == other.succeeded &&
        conflicts == other.conflicts &&
        p50LatencyMs == other.p50LatencyMs &&
        p99LatencyMs == other.p99LatencyMs;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, day.hashCode);
    _$hash = $jc(_$hash, attempts.hashCode);
    _$hash = $jc(_$hash, succeeded.hashCode);
    _$hash = $jc(_$hash, conflicts.hashCode);
    _$hash = $jc(_$hash, p50LatencyMs.hashCode);
    _$hash = $jc(_$hash, p99LatencyMs.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminTrendListItemsInner')
          ..add('day', day)
          ..add('attempts', attempts)
          ..add('succeeded', succeeded)
          ..add('conflicts', conflicts)
          ..add('p50LatencyMs', p50LatencyMs)
          ..add('p99LatencyMs', p99LatencyMs))
        .toString();
  }
}

class AdminTrendListItemsInnerBuilder
    implements
        Builder<AdminTrendListItemsInner, AdminTrendListItemsInnerBuilder> {
  _$AdminTrendListItemsInner? _$v;

  DateTime? _day;
  DateTime? get day => _$this._day;
  set day(DateTime? day) => _$this._day = day;

  int? _attempts;
  int? get attempts => _$this._attempts;
  set attempts(int? attempts) => _$this._attempts = attempts;

  int? _succeeded;
  int? get succeeded => _$this._succeeded;
  set succeeded(int? succeeded) => _$this._succeeded = succeeded;

  int? _conflicts;
  int? get conflicts => _$this._conflicts;
  set conflicts(int? conflicts) => _$this._conflicts = conflicts;

  num? _p50LatencyMs;
  num? get p50LatencyMs => _$this._p50LatencyMs;
  set p50LatencyMs(num? p50LatencyMs) => _$this._p50LatencyMs = p50LatencyMs;

  num? _p99LatencyMs;
  num? get p99LatencyMs => _$this._p99LatencyMs;
  set p99LatencyMs(num? p99LatencyMs) => _$this._p99LatencyMs = p99LatencyMs;

  AdminTrendListItemsInnerBuilder() {
    AdminTrendListItemsInner._defaults(this);
  }

  AdminTrendListItemsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _day = $v.day;
      _attempts = $v.attempts;
      _succeeded = $v.succeeded;
      _conflicts = $v.conflicts;
      _p50LatencyMs = $v.p50LatencyMs;
      _p99LatencyMs = $v.p99LatencyMs;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminTrendListItemsInner other) {
    _$v = other as _$AdminTrendListItemsInner;
  }

  @override
  void update(void Function(AdminTrendListItemsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminTrendListItemsInner build() => _build();

  _$AdminTrendListItemsInner _build() {
    final _$result = _$v ??
        _$AdminTrendListItemsInner._(
          day: BuiltValueNullFieldError.checkNotNull(
              day, r'AdminTrendListItemsInner', 'day'),
          attempts: BuiltValueNullFieldError.checkNotNull(
              attempts, r'AdminTrendListItemsInner', 'attempts'),
          succeeded: BuiltValueNullFieldError.checkNotNull(
              succeeded, r'AdminTrendListItemsInner', 'succeeded'),
          conflicts: BuiltValueNullFieldError.checkNotNull(
              conflicts, r'AdminTrendListItemsInner', 'conflicts'),
          p50LatencyMs: p50LatencyMs,
          p99LatencyMs: p99LatencyMs,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
