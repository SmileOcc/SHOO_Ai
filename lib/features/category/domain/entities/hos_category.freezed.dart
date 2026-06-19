// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hos_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SHOCategoryLeaf _$SHOCategoryLeafFromJson(Map<String, dynamic> json) {
  return _SHOCategoryLeaf.fromJson(json);
}

/// @nodoc
mixin _$SHOCategoryLeaf {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;

  /// Serializes this SHOCategoryLeaf to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOCategoryLeaf
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOCategoryLeafCopyWith<SHOCategoryLeaf> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOCategoryLeafCopyWith<$Res> {
  factory $SHOCategoryLeafCopyWith(
    SHOCategoryLeaf value,
    $Res Function(SHOCategoryLeaf) then,
  ) = _$SHOCategoryLeafCopyWithImpl<$Res, SHOCategoryLeaf>;
  @useResult
  $Res call({String id, String name, String icon});
}

/// @nodoc
class _$SHOCategoryLeafCopyWithImpl<$Res, $Val extends SHOCategoryLeaf>
    implements $SHOCategoryLeafCopyWith<$Res> {
  _$SHOCategoryLeafCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOCategoryLeaf
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null, Object? icon = null}) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOCategoryLeafImplCopyWith<$Res>
    implements $SHOCategoryLeafCopyWith<$Res> {
  factory _$$SHOCategoryLeafImplCopyWith(
    _$SHOCategoryLeafImpl value,
    $Res Function(_$SHOCategoryLeafImpl) then,
  ) = __$$SHOCategoryLeafImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String icon});
}

/// @nodoc
class __$$SHOCategoryLeafImplCopyWithImpl<$Res>
    extends _$SHOCategoryLeafCopyWithImpl<$Res, _$SHOCategoryLeafImpl>
    implements _$$SHOCategoryLeafImplCopyWith<$Res> {
  __$$SHOCategoryLeafImplCopyWithImpl(
    _$SHOCategoryLeafImpl _value,
    $Res Function(_$SHOCategoryLeafImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOCategoryLeaf
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null, Object? icon = null}) {
    return _then(
      _$SHOCategoryLeafImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOCategoryLeafImpl implements _SHOCategoryLeaf {
  const _$SHOCategoryLeafImpl({
    required this.id,
    required this.name,
    this.icon = '',
  });

  factory _$SHOCategoryLeafImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOCategoryLeafImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final String icon;

  @override
  String toString() {
    return 'SHOCategoryLeaf(id: $id, name: $name, icon: $icon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOCategoryLeafImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.icon, icon) || other.icon == icon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, icon);

  /// Create a copy of SHOCategoryLeaf
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOCategoryLeafImplCopyWith<_$SHOCategoryLeafImpl> get copyWith =>
      __$$SHOCategoryLeafImplCopyWithImpl<_$SHOCategoryLeafImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOCategoryLeafImplToJson(this);
  }
}

abstract class _SHOCategoryLeaf implements SHOCategoryLeaf {
  const factory _SHOCategoryLeaf({
    required final String id,
    required final String name,
    final String icon,
  }) = _$SHOCategoryLeafImpl;

  factory _SHOCategoryLeaf.fromJson(Map<String, dynamic> json) =
      _$SHOCategoryLeafImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get icon;

  /// Create a copy of SHOCategoryLeaf
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOCategoryLeafImplCopyWith<_$SHOCategoryLeafImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SHOCategoryGroup _$SHOCategoryGroupFromJson(Map<String, dynamic> json) {
  return _SHOCategoryGroup.fromJson(json);
}

/// @nodoc
mixin _$SHOCategoryGroup {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(fromJson: categoryLeavesFromJson)
  List<SHOCategoryLeaf> get children => throw _privateConstructorUsedError;

  /// Serializes this SHOCategoryGroup to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOCategoryGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOCategoryGroupCopyWith<SHOCategoryGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOCategoryGroupCopyWith<$Res> {
  factory $SHOCategoryGroupCopyWith(
    SHOCategoryGroup value,
    $Res Function(SHOCategoryGroup) then,
  ) = _$SHOCategoryGroupCopyWithImpl<$Res, SHOCategoryGroup>;
  @useResult
  $Res call({
    String id,
    String name,
    @JsonKey(fromJson: categoryLeavesFromJson) List<SHOCategoryLeaf> children,
  });
}

/// @nodoc
class _$SHOCategoryGroupCopyWithImpl<$Res, $Val extends SHOCategoryGroup>
    implements $SHOCategoryGroupCopyWith<$Res> {
  _$SHOCategoryGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOCategoryGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null, Object? children = null}) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            children: null == children
                ? _value.children
                : children // ignore: cast_nullable_to_non_nullable
                      as List<SHOCategoryLeaf>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOCategoryGroupImplCopyWith<$Res>
    implements $SHOCategoryGroupCopyWith<$Res> {
  factory _$$SHOCategoryGroupImplCopyWith(
    _$SHOCategoryGroupImpl value,
    $Res Function(_$SHOCategoryGroupImpl) then,
  ) = __$$SHOCategoryGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    @JsonKey(fromJson: categoryLeavesFromJson) List<SHOCategoryLeaf> children,
  });
}

/// @nodoc
class __$$SHOCategoryGroupImplCopyWithImpl<$Res>
    extends _$SHOCategoryGroupCopyWithImpl<$Res, _$SHOCategoryGroupImpl>
    implements _$$SHOCategoryGroupImplCopyWith<$Res> {
  __$$SHOCategoryGroupImplCopyWithImpl(
    _$SHOCategoryGroupImpl _value,
    $Res Function(_$SHOCategoryGroupImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOCategoryGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null, Object? children = null}) {
    return _then(
      _$SHOCategoryGroupImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        children: null == children
            ? _value._children
            : children // ignore: cast_nullable_to_non_nullable
                  as List<SHOCategoryLeaf>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOCategoryGroupImpl implements _SHOCategoryGroup {
  const _$SHOCategoryGroupImpl({
    required this.id,
    required this.name,
    @JsonKey(fromJson: categoryLeavesFromJson)
    final List<SHOCategoryLeaf> children = const [],
  }) : _children = children;

  factory _$SHOCategoryGroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOCategoryGroupImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  final List<SHOCategoryLeaf> _children;
  @override
  @JsonKey(fromJson: categoryLeavesFromJson)
  List<SHOCategoryLeaf> get children {
    if (_children is EqualUnmodifiableListView) return _children;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_children);
  }

  @override
  String toString() {
    return 'SHOCategoryGroup(id: $id, name: $name, children: $children)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOCategoryGroupImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._children, _children));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    const DeepCollectionEquality().hash(_children),
  );

  /// Create a copy of SHOCategoryGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOCategoryGroupImplCopyWith<_$SHOCategoryGroupImpl> get copyWith =>
      __$$SHOCategoryGroupImplCopyWithImpl<_$SHOCategoryGroupImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOCategoryGroupImplToJson(this);
  }
}

abstract class _SHOCategoryGroup implements SHOCategoryGroup {
  const factory _SHOCategoryGroup({
    required final String id,
    required final String name,
    @JsonKey(fromJson: categoryLeavesFromJson)
    final List<SHOCategoryLeaf> children,
  }) = _$SHOCategoryGroupImpl;

  factory _SHOCategoryGroup.fromJson(Map<String, dynamic> json) =
      _$SHOCategoryGroupImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(fromJson: categoryLeavesFromJson)
  List<SHOCategoryLeaf> get children;

  /// Create a copy of SHOCategoryGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOCategoryGroupImplCopyWith<_$SHOCategoryGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SHOCategoryItem _$SHOCategoryItemFromJson(Map<String, dynamic> json) {
  return _SHOCategoryItem.fromJson(json);
}

/// @nodoc
mixin _$SHOCategoryItem {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  @JsonKey(fromJson: categoryGroupsFromJson)
  List<SHOCategoryGroup> get groups => throw _privateConstructorUsedError;

  /// Serializes this SHOCategoryItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOCategoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOCategoryItemCopyWith<SHOCategoryItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOCategoryItemCopyWith<$Res> {
  factory $SHOCategoryItemCopyWith(
    SHOCategoryItem value,
    $Res Function(SHOCategoryItem) then,
  ) = _$SHOCategoryItemCopyWithImpl<$Res, SHOCategoryItem>;
  @useResult
  $Res call({
    String id,
    String name,
    String icon,
    @JsonKey(fromJson: categoryGroupsFromJson) List<SHOCategoryGroup> groups,
  });
}

/// @nodoc
class _$SHOCategoryItemCopyWithImpl<$Res, $Val extends SHOCategoryItem>
    implements $SHOCategoryItemCopyWith<$Res> {
  _$SHOCategoryItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOCategoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = null,
    Object? groups = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String,
            groups: null == groups
                ? _value.groups
                : groups // ignore: cast_nullable_to_non_nullable
                      as List<SHOCategoryGroup>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOCategoryItemImplCopyWith<$Res>
    implements $SHOCategoryItemCopyWith<$Res> {
  factory _$$SHOCategoryItemImplCopyWith(
    _$SHOCategoryItemImpl value,
    $Res Function(_$SHOCategoryItemImpl) then,
  ) = __$$SHOCategoryItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String icon,
    @JsonKey(fromJson: categoryGroupsFromJson) List<SHOCategoryGroup> groups,
  });
}

/// @nodoc
class __$$SHOCategoryItemImplCopyWithImpl<$Res>
    extends _$SHOCategoryItemCopyWithImpl<$Res, _$SHOCategoryItemImpl>
    implements _$$SHOCategoryItemImplCopyWith<$Res> {
  __$$SHOCategoryItemImplCopyWithImpl(
    _$SHOCategoryItemImpl _value,
    $Res Function(_$SHOCategoryItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOCategoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = null,
    Object? groups = null,
  }) {
    return _then(
      _$SHOCategoryItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String,
        groups: null == groups
            ? _value._groups
            : groups // ignore: cast_nullable_to_non_nullable
                  as List<SHOCategoryGroup>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOCategoryItemImpl implements _SHOCategoryItem {
  const _$SHOCategoryItemImpl({
    required this.id,
    required this.name,
    this.icon = '🏷️',
    @JsonKey(fromJson: categoryGroupsFromJson)
    final List<SHOCategoryGroup> groups = const [],
  }) : _groups = groups;

  factory _$SHOCategoryItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOCategoryItemImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final String icon;
  final List<SHOCategoryGroup> _groups;
  @override
  @JsonKey(fromJson: categoryGroupsFromJson)
  List<SHOCategoryGroup> get groups {
    if (_groups is EqualUnmodifiableListView) return _groups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_groups);
  }

  @override
  String toString() {
    return 'SHOCategoryItem(id: $id, name: $name, icon: $icon, groups: $groups)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOCategoryItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            const DeepCollectionEquality().equals(other._groups, _groups));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    icon,
    const DeepCollectionEquality().hash(_groups),
  );

  /// Create a copy of SHOCategoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOCategoryItemImplCopyWith<_$SHOCategoryItemImpl> get copyWith =>
      __$$SHOCategoryItemImplCopyWithImpl<_$SHOCategoryItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOCategoryItemImplToJson(this);
  }
}

abstract class _SHOCategoryItem implements SHOCategoryItem {
  const factory _SHOCategoryItem({
    required final String id,
    required final String name,
    final String icon,
    @JsonKey(fromJson: categoryGroupsFromJson)
    final List<SHOCategoryGroup> groups,
  }) = _$SHOCategoryItemImpl;

  factory _SHOCategoryItem.fromJson(Map<String, dynamic> json) =
      _$SHOCategoryItemImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get icon;
  @override
  @JsonKey(fromJson: categoryGroupsFromJson)
  List<SHOCategoryGroup> get groups;

  /// Create a copy of SHOCategoryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOCategoryItemImplCopyWith<_$SHOCategoryItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
