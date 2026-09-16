// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProjectRequest extends ProjectRequest {
  @override
  final String name;

  factory _$ProjectRequest([void Function(ProjectRequestBuilder)? updates]) =>
      (ProjectRequestBuilder()..update(updates))._build();

  _$ProjectRequest._({required this.name}) : super._();
  @override
  ProjectRequest rebuild(void Function(ProjectRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProjectRequestBuilder toBuilder() => ProjectRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProjectRequest && name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProjectRequest')..add('name', name))
        .toString();
  }
}

class ProjectRequestBuilder
    implements Builder<ProjectRequest, ProjectRequestBuilder> {
  _$ProjectRequest? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  ProjectRequestBuilder() {
    ProjectRequest._defaults(this);
  }

  ProjectRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProjectRequest other) {
    _$v = other as _$ProjectRequest;
  }

  @override
  void update(void Function(ProjectRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProjectRequest build() => _build();

  _$ProjectRequest _build() {
    final _$result = _$v ??
        _$ProjectRequest._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'ProjectRequest', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
