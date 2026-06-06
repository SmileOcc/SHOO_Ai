// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hos_coupon.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SHOCoupon _$SHOCouponFromJson(Map<String, dynamic> json) {
  return _SHOCoupon.fromJson(json);
}

/// @nodoc
mixin _$SHOCoupon {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  SHOCouponType get type => throw _privateConstructorUsedError;
  int get discountCents => throw _privateConstructorUsedError;
  int get discountPercent => throw _privateConstructorUsedError;
  int get minOrderCents => throw _privateConstructorUsedError;
  String get expiresAt => throw _privateConstructorUsedError;
  bool get isAvailable => throw _privateConstructorUsedError;

  /// Serializes this SHOCoupon to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOCoupon
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOCouponCopyWith<SHOCoupon> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOCouponCopyWith<$Res> {
  factory $SHOCouponCopyWith(SHOCoupon value, $Res Function(SHOCoupon) then) =
      _$SHOCouponCopyWithImpl<$Res, SHOCoupon>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    SHOCouponType type,
    int discountCents,
    int discountPercent,
    int minOrderCents,
    String expiresAt,
    bool isAvailable,
  });
}

/// @nodoc
class _$SHOCouponCopyWithImpl<$Res, $Val extends SHOCoupon>
    implements $SHOCouponCopyWith<$Res> {
  _$SHOCouponCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOCoupon
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? discountCents = null,
    Object? discountPercent = null,
    Object? minOrderCents = null,
    Object? expiresAt = null,
    Object? isAvailable = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as SHOCouponType,
            discountCents: null == discountCents
                ? _value.discountCents
                : discountCents // ignore: cast_nullable_to_non_nullable
                      as int,
            discountPercent: null == discountPercent
                ? _value.discountPercent
                : discountPercent // ignore: cast_nullable_to_non_nullable
                      as int,
            minOrderCents: null == minOrderCents
                ? _value.minOrderCents
                : minOrderCents // ignore: cast_nullable_to_non_nullable
                      as int,
            expiresAt: null == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as String,
            isAvailable: null == isAvailable
                ? _value.isAvailable
                : isAvailable // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOCouponImplCopyWith<$Res>
    implements $SHOCouponCopyWith<$Res> {
  factory _$$SHOCouponImplCopyWith(
    _$SHOCouponImpl value,
    $Res Function(_$SHOCouponImpl) then,
  ) = __$$SHOCouponImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    SHOCouponType type,
    int discountCents,
    int discountPercent,
    int minOrderCents,
    String expiresAt,
    bool isAvailable,
  });
}

/// @nodoc
class __$$SHOCouponImplCopyWithImpl<$Res>
    extends _$SHOCouponCopyWithImpl<$Res, _$SHOCouponImpl>
    implements _$$SHOCouponImplCopyWith<$Res> {
  __$$SHOCouponImplCopyWithImpl(
    _$SHOCouponImpl _value,
    $Res Function(_$SHOCouponImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOCoupon
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? discountCents = null,
    Object? discountPercent = null,
    Object? minOrderCents = null,
    Object? expiresAt = null,
    Object? isAvailable = null,
  }) {
    return _then(
      _$SHOCouponImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as SHOCouponType,
        discountCents: null == discountCents
            ? _value.discountCents
            : discountCents // ignore: cast_nullable_to_non_nullable
                  as int,
        discountPercent: null == discountPercent
            ? _value.discountPercent
            : discountPercent // ignore: cast_nullable_to_non_nullable
                  as int,
        minOrderCents: null == minOrderCents
            ? _value.minOrderCents
            : minOrderCents // ignore: cast_nullable_to_non_nullable
                  as int,
        expiresAt: null == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as String,
        isAvailable: null == isAvailable
            ? _value.isAvailable
            : isAvailable // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOCouponImpl implements _SHOCoupon {
  const _$SHOCouponImpl({
    required this.id,
    required this.title,
    this.description = '',
    required this.type,
    this.discountCents = 0,
    this.discountPercent = 0,
    this.minOrderCents = 0,
    required this.expiresAt,
    this.isAvailable = true,
  });

  factory _$SHOCouponImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOCouponImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  @JsonKey()
  final String description;
  @override
  final SHOCouponType type;
  @override
  @JsonKey()
  final int discountCents;
  @override
  @JsonKey()
  final int discountPercent;
  @override
  @JsonKey()
  final int minOrderCents;
  @override
  final String expiresAt;
  @override
  @JsonKey()
  final bool isAvailable;

  @override
  String toString() {
    return 'SHOCoupon(id: $id, title: $title, description: $description, type: $type, discountCents: $discountCents, discountPercent: $discountPercent, minOrderCents: $minOrderCents, expiresAt: $expiresAt, isAvailable: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOCouponImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.discountCents, discountCents) ||
                other.discountCents == discountCents) &&
            (identical(other.discountPercent, discountPercent) ||
                other.discountPercent == discountPercent) &&
            (identical(other.minOrderCents, minOrderCents) ||
                other.minOrderCents == minOrderCents) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    type,
    discountCents,
    discountPercent,
    minOrderCents,
    expiresAt,
    isAvailable,
  );

  /// Create a copy of SHOCoupon
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOCouponImplCopyWith<_$SHOCouponImpl> get copyWith =>
      __$$SHOCouponImplCopyWithImpl<_$SHOCouponImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOCouponImplToJson(this);
  }
}

abstract class _SHOCoupon implements SHOCoupon {
  const factory _SHOCoupon({
    required final String id,
    required final String title,
    final String description,
    required final SHOCouponType type,
    final int discountCents,
    final int discountPercent,
    final int minOrderCents,
    required final String expiresAt,
    final bool isAvailable,
  }) = _$SHOCouponImpl;

  factory _SHOCoupon.fromJson(Map<String, dynamic> json) =
      _$SHOCouponImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  SHOCouponType get type;
  @override
  int get discountCents;
  @override
  int get discountPercent;
  @override
  int get minOrderCents;
  @override
  String get expiresAt;
  @override
  bool get isAvailable;

  /// Create a copy of SHOCoupon
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOCouponImplCopyWith<_$SHOCouponImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
