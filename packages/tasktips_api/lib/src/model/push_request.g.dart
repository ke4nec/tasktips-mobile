// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PushRequest extends PushRequest {
  @override
  final String requestId;
  @override
  final int generation;
  @override
  final BuiltList<PushObject> objects;
  @override
  final BuiltList<PushTombstone> tombstones;

  factory _$PushRequest([void Function(PushRequestBuilder)? updates]) =>
      (PushRequestBuilder()..update(updates))._build();

  _$PushRequest._(
      {required this.requestId,
      required this.generation,
      required this.objects,
      required this.tombstones})
      : super._();
  @override
  PushRequest rebuild(void Function(PushRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PushRequestBuilder toBuilder() => PushRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PushRequest &&
        requestId == other.requestId &&
        generation == other.generation &&
        objects == other.objects &&
        tombstones == other.tombstones;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jc(_$hash, generation.hashCode);
    _$hash = $jc(_$hash, objects.hashCode);
    _$hash = $jc(_$hash, tombstones.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PushRequest')
          ..add('requestId', requestId)
          ..add('generation', generation)
          ..add('objects', objects)
          ..add('tombstones', tombstones))
        .toString();
  }
}

class PushRequestBuilder implements Builder<PushRequest, PushRequestBuilder> {
  _$PushRequest? _$v;

  String? _requestId;
  String? get requestId => _$this._requestId;
  set requestId(String? requestId) => _$this._requestId = requestId;

  int? _generation;
  int? get generation => _$this._generation;
  set generation(int? generation) => _$this._generation = generation;

  ListBuilder<PushObject>? _objects;
  ListBuilder<PushObject> get objects =>
      _$this._objects ??= ListBuilder<PushObject>();
  set objects(ListBuilder<PushObject>? objects) => _$this._objects = objects;

  ListBuilder<PushTombstone>? _tombstones;
  ListBuilder<PushTombstone> get tombstones =>
      _$this._tombstones ??= ListBuilder<PushTombstone>();
  set tombstones(ListBuilder<PushTombstone>? tombstones) =>
      _$this._tombstones = tombstones;

  PushRequestBuilder() {
    PushRequest._defaults(this);
  }

  PushRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _requestId = $v.requestId;
      _generation = $v.generation;
      _objects = $v.objects.toBuilder();
      _tombstones = $v.tombstones.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PushRequest other) {
    _$v = other as _$PushRequest;
  }

  @override
  void update(void Function(PushRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PushRequest build() => _build();

  _$PushRequest _build() {
    _$PushRequest _$result;
    try {
      _$result = _$v ??
          _$PushRequest._(
            requestId: BuiltValueNullFieldError.checkNotNull(
                requestId, r'PushRequest', 'requestId'),
            generation: BuiltValueNullFieldError.checkNotNull(
                generation, r'PushRequest', 'generation'),
            objects: objects.build(),
            tombstones: tombstones.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'objects';
        objects.build();
        _$failedField = 'tombstones';
        tombstones.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PushRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
