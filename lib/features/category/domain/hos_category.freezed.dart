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

SHOCategoryItem _$SHOCategoryItemFromJson(Map<String, dynamic> json) {
  return _SHOCategoryItem.fromJson(json);
}

/// @nodoc
mixin _$SHOCategoryItem {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;

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
  $Res call({String id, String name, String icon});
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
abstract class _$$SHOCategoryItemImplCopyWith<$Res>
    implements $SHOCategoryItemCopyWith<$Res> {
  factory _$$SHOCategoryItemImplCopyWith(
    _$SHOCategoryItemImpl value,
    $Res Function(_$SHOCategoryItemImpl) then,
  ) = __$$SHOCategoryItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String icon});
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
  $Res call({Object? id = null, Object? name = null, Object? icon = null}) {
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
  });

  factory _$SHOCategoryItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOCategoryItemImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final String icon;

  @override
  String toString() {
    return 'SHOCategoryItem(id: $id, name: $name, icon: $icon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOCategoryItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.icon, icon) || other.icon == icon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, icon);

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
  }) = _$SHOCategoryItemImpl;

  factory _SHOCategoryItem.fromJson(Map<String, dynamic> json) =
      _$SHOCategoryItemImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get icon;

  /// Create a copy of SHOCategoryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOCategoryItemImplCopyWith<_$SHOCategoryItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
