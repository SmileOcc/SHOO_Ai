// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hos_product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SHOProduct _$SHOProductFromJson(Map<String, dynamic> json) {
  return _SHOProduct.fromJson(json);
}

/// @nodoc
mixin _$SHOProduct {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  int get price => throw _privateConstructorUsedError;
  int get originalPrice => throw _privateConstructorUsedError;
  String get discountLabel => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  int get soldCount => throw _privateConstructorUsedError;

  /// Serializes this SHOProduct to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOProductCopyWith<SHOProduct> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOProductCopyWith<$Res> {
  factory $SHOProductCopyWith(
    SHOProduct value,
    $Res Function(SHOProduct) then,
  ) = _$SHOProductCopyWithImpl<$Res, SHOProduct>;
  @useResult
  $Res call({
    String id,
    String title,
    String imageUrl,
    int price,
    int originalPrice,
    String discountLabel,
    double rating,
    int soldCount,
  });
}

/// @nodoc
class _$SHOProductCopyWithImpl<$Res, $Val extends SHOProduct>
    implements $SHOProductCopyWith<$Res> {
  _$SHOProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? imageUrl = null,
    Object? price = null,
    Object? originalPrice = null,
    Object? discountLabel = null,
    Object? rating = null,
    Object? soldCount = null,
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
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as int,
            originalPrice: null == originalPrice
                ? _value.originalPrice
                : originalPrice // ignore: cast_nullable_to_non_nullable
                      as int,
            discountLabel: null == discountLabel
                ? _value.discountLabel
                : discountLabel // ignore: cast_nullable_to_non_nullable
                      as String,
            rating: null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as double,
            soldCount: null == soldCount
                ? _value.soldCount
                : soldCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOProductImplCopyWith<$Res>
    implements $SHOProductCopyWith<$Res> {
  factory _$$SHOProductImplCopyWith(
    _$SHOProductImpl value,
    $Res Function(_$SHOProductImpl) then,
  ) = __$$SHOProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String imageUrl,
    int price,
    int originalPrice,
    String discountLabel,
    double rating,
    int soldCount,
  });
}

/// @nodoc
class __$$SHOProductImplCopyWithImpl<$Res>
    extends _$SHOProductCopyWithImpl<$Res, _$SHOProductImpl>
    implements _$$SHOProductImplCopyWith<$Res> {
  __$$SHOProductImplCopyWithImpl(
    _$SHOProductImpl _value,
    $Res Function(_$SHOProductImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? imageUrl = null,
    Object? price = null,
    Object? originalPrice = null,
    Object? discountLabel = null,
    Object? rating = null,
    Object? soldCount = null,
  }) {
    return _then(
      _$SHOProductImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as int,
        originalPrice: null == originalPrice
            ? _value.originalPrice
            : originalPrice // ignore: cast_nullable_to_non_nullable
                  as int,
        discountLabel: null == discountLabel
            ? _value.discountLabel
            : discountLabel // ignore: cast_nullable_to_non_nullable
                  as String,
        rating: null == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as double,
        soldCount: null == soldCount
            ? _value.soldCount
            : soldCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOProductImpl implements _SHOProduct {
  const _$SHOProductImpl({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.originalPrice,
    this.discountLabel = '',
    required this.rating,
    this.soldCount = 0,
  });

  factory _$SHOProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOProductImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String imageUrl;
  @override
  final int price;
  @override
  final int originalPrice;
  @override
  @JsonKey()
  final String discountLabel;
  @override
  final double rating;
  @override
  @JsonKey()
  final int soldCount;

  @override
  String toString() {
    return 'SHOProduct(id: $id, title: $title, imageUrl: $imageUrl, price: $price, originalPrice: $originalPrice, discountLabel: $discountLabel, rating: $rating, soldCount: $soldCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOProductImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.originalPrice, originalPrice) ||
                other.originalPrice == originalPrice) &&
            (identical(other.discountLabel, discountLabel) ||
                other.discountLabel == discountLabel) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.soldCount, soldCount) ||
                other.soldCount == soldCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    imageUrl,
    price,
    originalPrice,
    discountLabel,
    rating,
    soldCount,
  );

  /// Create a copy of SHOProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOProductImplCopyWith<_$SHOProductImpl> get copyWith =>
      __$$SHOProductImplCopyWithImpl<_$SHOProductImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOProductImplToJson(this);
  }
}

abstract class _SHOProduct implements SHOProduct {
  const factory _SHOProduct({
    required final String id,
    required final String title,
    required final String imageUrl,
    required final int price,
    required final int originalPrice,
    final String discountLabel,
    required final double rating,
    final int soldCount,
  }) = _$SHOProductImpl;

  factory _SHOProduct.fromJson(Map<String, dynamic> json) =
      _$SHOProductImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get imageUrl;
  @override
  int get price;
  @override
  int get originalPrice;
  @override
  String get discountLabel;
  @override
  double get rating;
  @override
  int get soldCount;

  /// Create a copy of SHOProduct
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOProductImplCopyWith<_$SHOProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
