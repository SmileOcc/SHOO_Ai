// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hos_flash_sale_coupon.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SHOFlashSaleCoupon _$SHOFlashSaleCouponFromJson(Map<String, dynamic> json) {
  return _SHOFlashSaleCoupon.fromJson(json);
}

/// @nodoc
mixin _$SHOFlashSaleCoupon {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  SHOFlashSaleCouponStatus get status => throw _privateConstructorUsedError;

  /// Serializes this SHOFlashSaleCoupon to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOFlashSaleCoupon
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOFlashSaleCouponCopyWith<SHOFlashSaleCoupon> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOFlashSaleCouponCopyWith<$Res> {
  factory $SHOFlashSaleCouponCopyWith(
    SHOFlashSaleCoupon value,
    $Res Function(SHOFlashSaleCoupon) then,
  ) = _$SHOFlashSaleCouponCopyWithImpl<$Res, SHOFlashSaleCoupon>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    SHOFlashSaleCouponStatus status,
  });
}

/// @nodoc
class _$SHOFlashSaleCouponCopyWithImpl<$Res, $Val extends SHOFlashSaleCoupon>
    implements $SHOFlashSaleCouponCopyWith<$Res> {
  _$SHOFlashSaleCouponCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOFlashSaleCoupon
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? status = null,
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
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SHOFlashSaleCouponStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOFlashSaleCouponImplCopyWith<$Res>
    implements $SHOFlashSaleCouponCopyWith<$Res> {
  factory _$$SHOFlashSaleCouponImplCopyWith(
    _$SHOFlashSaleCouponImpl value,
    $Res Function(_$SHOFlashSaleCouponImpl) then,
  ) = __$$SHOFlashSaleCouponImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    SHOFlashSaleCouponStatus status,
  });
}

/// @nodoc
class __$$SHOFlashSaleCouponImplCopyWithImpl<$Res>
    extends _$SHOFlashSaleCouponCopyWithImpl<$Res, _$SHOFlashSaleCouponImpl>
    implements _$$SHOFlashSaleCouponImplCopyWith<$Res> {
  __$$SHOFlashSaleCouponImplCopyWithImpl(
    _$SHOFlashSaleCouponImpl _value,
    $Res Function(_$SHOFlashSaleCouponImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOFlashSaleCoupon
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? status = null,
  }) {
    return _then(
      _$SHOFlashSaleCouponImpl(
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
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SHOFlashSaleCouponStatus,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOFlashSaleCouponImpl implements _SHOFlashSaleCoupon {
  const _$SHOFlashSaleCouponImpl({
    required this.id,
    required this.title,
    required this.description,
    this.status = SHOFlashSaleCouponStatus.notStarted,
  });

  factory _$SHOFlashSaleCouponImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOFlashSaleCouponImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  @JsonKey()
  final SHOFlashSaleCouponStatus status;

  @override
  String toString() {
    return 'SHOFlashSaleCoupon(id: $id, title: $title, description: $description, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOFlashSaleCouponImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, description, status);

  /// Create a copy of SHOFlashSaleCoupon
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOFlashSaleCouponImplCopyWith<_$SHOFlashSaleCouponImpl> get copyWith =>
      __$$SHOFlashSaleCouponImplCopyWithImpl<_$SHOFlashSaleCouponImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOFlashSaleCouponImplToJson(this);
  }
}

abstract class _SHOFlashSaleCoupon implements SHOFlashSaleCoupon {
  const factory _SHOFlashSaleCoupon({
    required final String id,
    required final String title,
    required final String description,
    final SHOFlashSaleCouponStatus status,
  }) = _$SHOFlashSaleCouponImpl;

  factory _SHOFlashSaleCoupon.fromJson(Map<String, dynamic> json) =
      _$SHOFlashSaleCouponImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  SHOFlashSaleCouponStatus get status;

  /// Create a copy of SHOFlashSaleCoupon
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOFlashSaleCouponImplCopyWith<_$SHOFlashSaleCouponImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
