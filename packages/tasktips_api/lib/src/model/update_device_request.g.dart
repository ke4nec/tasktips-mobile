// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_device_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateDeviceRequest extends UpdateDeviceRequest {
  @override
  final String displayName;

  factory _$UpdateDeviceRequest(
          [void Function(UpdateDeviceRequestBuilder)? updates]) =>
      (UpdateDeviceRequestBuilder()..update(updates))._build();

  _$UpdateDeviceRequest._({required this.displayName}) : super._();
  @override
  UpdateDeviceRequest rebuild(
          void Function(UpdateDeviceRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateDeviceRequestBuilder toBuilder() =>
      UpdateDeviceRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateDeviceRequest && displayName == other.displayName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateDeviceRequest')
          ..add('displayName', displayName))
        .toString();
  }
}

class UpdateDeviceRequestBuilder
    implements Builder<UpdateDeviceRequest, UpdateDeviceRequestBuilder> {
  _$UpdateDeviceRequest? _$v;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  UpdateDeviceRequestBuilder() {
    UpdateDeviceRequest._defaults(this);
  }

  UpdateDeviceRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _displayName = $v.displayName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateDeviceRequest other) {
    _$v = other as _$UpdateDeviceRequest;
  }

  @override
  void update(void Function(UpdateDeviceRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateDeviceRequest build() => _build();

  _$UpdateDeviceRequest _build() {
    final _$result = _$v ??
        _$UpdateDeviceRequest._(
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName, r'UpdateDeviceRequest', 'displayName'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
