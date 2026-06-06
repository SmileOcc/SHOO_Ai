// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hos_banner.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SHOBannerItem _$SHOBannerItemFromJson(Map<String, dynamic> json) {
  return _SHOBannerItem.fromJson(json);
}

/// @nodoc
mixin _$SHOBannerItem {
  String get id => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  String get link => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;

  /// Serializes this SHOBannerItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOBannerItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOBannerItemCopyWith<SHOBannerItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOBannerItemCopyWith<$Res> {
  factory $SHOBannerItemCopyWith(
    SHOBannerItem value,
    $Res Function(SHOBannerItem) then,
  ) = _$SHOBannerItemCopyWithImpl<$Res, SHOBannerItem>;
  @useResult
  $Res call({String id, String imageUrl, String link, String title});
}

/// @nodoc
class _$SHOBannerItemCopyWithImpl<$Res, $Val extends SHOBannerItem>
    implements $SHOBannerItemCopyWith<$Res> {
  _$SHOBannerItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOBannerItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? imageUrl = null,
    Object? link = null,
    Object? title = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            link: null == link
                ? _value.link
                : link // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOBannerItemImplCopyWith<$Res>
    implements $SHOBannerItemCopyWith<$Res> {
  factory _$$SHOBannerItemImplCopyWith(
    _$SHOBannerItemImpl value,
    $Res Function(_$SHOBannerItemImpl) then,
  ) = __$$SHOBannerItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String imageUrl, String link, String title});
}

/// @nodoc
class __$$SHOBannerItemImplCopyWithImpl<$Res>
    extends _$SHOBannerItemCopyWithImpl<$Res, _$SHOBannerItemImpl>
    implements _$$SHOBannerItemImplCopyWith<$Res> {
  __$$SHOBannerItemImplCopyWithImpl(
    _$SHOBannerItemImpl _value,
    $Res Function(_$SHOBannerItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOBannerItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? imageUrl = null,
    Object? link = null,
    Object? title = null,
  }) {
    return _then(
      _$SHOBannerItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        link: null == link
            ? _value.link
            : link // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOBannerItemImpl implements _SHOBannerItem {
  const _$SHOBannerItemImpl({
    required this.id,
    required this.imageUrl,
    required this.link,
    required this.title,
  });

  factory _$SHOBannerItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOBannerItemImplFromJson(json);

  @override
  final String id;
  @override
  final String imageUrl;
  @override
  final String link;
  @override
  final String title;

  @override
  String toString() {
    return 'SHOBannerItem(id: $id, imageUrl: $imageUrl, link: $link, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOBannerItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.link, link) || other.link == link) &&
            (identical(other.title, title) || other.title == title));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, imageUrl, link, title);

  /// Create a copy of SHOBannerItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOBannerItemImplCopyWith<_$SHOBannerItemImpl> get copyWith =>
      __$$SHOBannerItemImplCopyWithImpl<_$SHOBannerItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOBannerItemImplToJson(this);
  }
}

abstract class _SHOBannerItem implements SHOBannerItem {
  const factory _SHOBannerItem({
    required final String id,
    required final String imageUrl,
    required final String link,
    required final String title,
  }) = _$SHOBannerItemImpl;

  factory _SHOBannerItem.fromJson(Map<String, dynamic> json) =
      _$SHOBannerItemImpl.fromJson;

  @override
  String get id;
  @override
  String get imageUrl;
  @override
  String get link;
  @override
  String get title;

  /// Create a copy of SHOBannerItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOBannerItemImplCopyWith<_$SHOBannerItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
