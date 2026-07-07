// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hos_flash_sale_product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SHOFlashSaleProduct _$SHOFlashSaleProductFromJson(Map<String, dynamic> json) {
  return _SHOFlashSaleProduct.fromJson(json);
}

/// @nodoc
mixin _$SHOFlashSaleProduct {
  String get id => throw _privateConstructorUsedError;
  String get sessionId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  int get originalPrice => throw _privateConstructorUsedError;
  int get activityPrice => throw _privateConstructorUsedError;
  List<String> get skuAttributes => throw _privateConstructorUsedError;
  List<SHOFlashSalePromoTag> get promoTags =>
      throw _privateConstructorUsedError;
  String? get primaryPromoType => throw _privateConstructorUsedError;
  String? get primaryPromoLabel => throw _privateConstructorUsedError;
  SHOFlashSaleProductStatus get status => throw _privateConstructorUsedError;
  int get stock => throw _privateConstructorUsedError;
  int get soldCount => throw _privateConstructorUsedError;
  bool get isFollowed => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SHOFlashSaleProduct to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOFlashSaleProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOFlashSaleProductCopyWith<SHOFlashSaleProduct> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOFlashSaleProductCopyWith<$Res> {
  factory $SHOFlashSaleProductCopyWith(
    SHOFlashSaleProduct value,
    $Res Function(SHOFlashSaleProduct) then,
  ) = _$SHOFlashSaleProductCopyWithImpl<$Res, SHOFlashSaleProduct>;
  @useResult
  $Res call({
    String id,
    String sessionId,
    String title,
    String imageUrl,
    int originalPrice,
    int activityPrice,
    List<String> skuAttributes,
    List<SHOFlashSalePromoTag> promoTags,
    String? primaryPromoType,
    String? primaryPromoLabel,
    SHOFlashSaleProductStatus status,
    int stock,
    int soldCount,
    bool isFollowed,
    String? createdAt,
  });
}

/// @nodoc
class _$SHOFlashSaleProductCopyWithImpl<$Res, $Val extends SHOFlashSaleProduct>
    implements $SHOFlashSaleProductCopyWith<$Res> {
  _$SHOFlashSaleProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOFlashSaleProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sessionId = null,
    Object? title = null,
    Object? imageUrl = null,
    Object? originalPrice = null,
    Object? activityPrice = null,
    Object? skuAttributes = null,
    Object? promoTags = null,
    Object? primaryPromoType = freezed,
    Object? primaryPromoLabel = freezed,
    Object? status = null,
    Object? stock = null,
    Object? soldCount = null,
    Object? isFollowed = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            originalPrice: null == originalPrice
                ? _value.originalPrice
                : originalPrice // ignore: cast_nullable_to_non_nullable
                      as int,
            activityPrice: null == activityPrice
                ? _value.activityPrice
                : activityPrice // ignore: cast_nullable_to_non_nullable
                      as int,
            skuAttributes: null == skuAttributes
                ? _value.skuAttributes
                : skuAttributes // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            promoTags: null == promoTags
                ? _value.promoTags
                : promoTags // ignore: cast_nullable_to_non_nullable
                      as List<SHOFlashSalePromoTag>,
            primaryPromoType: freezed == primaryPromoType
                ? _value.primaryPromoType
                : primaryPromoType // ignore: cast_nullable_to_non_nullable
                      as String?,
            primaryPromoLabel: freezed == primaryPromoLabel
                ? _value.primaryPromoLabel
                : primaryPromoLabel // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SHOFlashSaleProductStatus,
            stock: null == stock
                ? _value.stock
                : stock // ignore: cast_nullable_to_non_nullable
                      as int,
            soldCount: null == soldCount
                ? _value.soldCount
                : soldCount // ignore: cast_nullable_to_non_nullable
                      as int,
            isFollowed: null == isFollowed
                ? _value.isFollowed
                : isFollowed // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOFlashSaleProductImplCopyWith<$Res>
    implements $SHOFlashSaleProductCopyWith<$Res> {
  factory _$$SHOFlashSaleProductImplCopyWith(
    _$SHOFlashSaleProductImpl value,
    $Res Function(_$SHOFlashSaleProductImpl) then,
  ) = __$$SHOFlashSaleProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String sessionId,
    String title,
    String imageUrl,
    int originalPrice,
    int activityPrice,
    List<String> skuAttributes,
    List<SHOFlashSalePromoTag> promoTags,
    String? primaryPromoType,
    String? primaryPromoLabel,
    SHOFlashSaleProductStatus status,
    int stock,
    int soldCount,
    bool isFollowed,
    String? createdAt,
  });
}

/// @nodoc
class __$$SHOFlashSaleProductImplCopyWithImpl<$Res>
    extends _$SHOFlashSaleProductCopyWithImpl<$Res, _$SHOFlashSaleProductImpl>
    implements _$$SHOFlashSaleProductImplCopyWith<$Res> {
  __$$SHOFlashSaleProductImplCopyWithImpl(
    _$SHOFlashSaleProductImpl _value,
    $Res Function(_$SHOFlashSaleProductImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOFlashSaleProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sessionId = null,
    Object? title = null,
    Object? imageUrl = null,
    Object? originalPrice = null,
    Object? activityPrice = null,
    Object? skuAttributes = null,
    Object? promoTags = null,
    Object? primaryPromoType = freezed,
    Object? primaryPromoLabel = freezed,
    Object? status = null,
    Object? stock = null,
    Object? soldCount = null,
    Object? isFollowed = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$SHOFlashSaleProductImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        originalPrice: null == originalPrice
            ? _value.originalPrice
            : originalPrice // ignore: cast_nullable_to_non_nullable
                  as int,
        activityPrice: null == activityPrice
            ? _value.activityPrice
            : activityPrice // ignore: cast_nullable_to_non_nullable
                  as int,
        skuAttributes: null == skuAttributes
            ? _value._skuAttributes
            : skuAttributes // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        promoTags: null == promoTags
            ? _value._promoTags
            : promoTags // ignore: cast_nullable_to_non_nullable
                  as List<SHOFlashSalePromoTag>,
        primaryPromoType: freezed == primaryPromoType
            ? _value.primaryPromoType
            : primaryPromoType // ignore: cast_nullable_to_non_nullable
                  as String?,
        primaryPromoLabel: freezed == primaryPromoLabel
            ? _value.primaryPromoLabel
            : primaryPromoLabel // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SHOFlashSaleProductStatus,
        stock: null == stock
            ? _value.stock
            : stock // ignore: cast_nullable_to_non_nullable
                  as int,
        soldCount: null == soldCount
            ? _value.soldCount
            : soldCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isFollowed: null == isFollowed
            ? _value.isFollowed
            : isFollowed // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOFlashSaleProductImpl extends _SHOFlashSaleProduct {
  const _$SHOFlashSaleProductImpl({
    required this.id,
    required this.sessionId,
    required this.title,
    required this.imageUrl,
    required this.originalPrice,
    required this.activityPrice,
    final List<String> skuAttributes = const [],
    final List<SHOFlashSalePromoTag> promoTags = const [],
    this.primaryPromoType,
    this.primaryPromoLabel,
    this.status = SHOFlashSaleProductStatus.notStarted,
    this.stock = 0,
    this.soldCount = 0,
    this.isFollowed = false,
    this.createdAt,
  }) : _skuAttributes = skuAttributes,
       _promoTags = promoTags,
       super._();

  factory _$SHOFlashSaleProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOFlashSaleProductImplFromJson(json);

  @override
  final String id;
  @override
  final String sessionId;
  @override
  final String title;
  @override
  final String imageUrl;
  @override
  final int originalPrice;
  @override
  final int activityPrice;
  final List<String> _skuAttributes;
  @override
  @JsonKey()
  List<String> get skuAttributes {
    if (_skuAttributes is EqualUnmodifiableListView) return _skuAttributes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_skuAttributes);
  }

  final List<SHOFlashSalePromoTag> _promoTags;
  @override
  @JsonKey()
  List<SHOFlashSalePromoTag> get promoTags {
    if (_promoTags is EqualUnmodifiableListView) return _promoTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_promoTags);
  }

  @override
  final String? primaryPromoType;
  @override
  final String? primaryPromoLabel;
  @override
  @JsonKey()
  final SHOFlashSaleProductStatus status;
  @override
  @JsonKey()
  final int stock;
  @override
  @JsonKey()
  final int soldCount;
  @override
  @JsonKey()
  final bool isFollowed;
  @override
  final String? createdAt;

  @override
  String toString() {
    return 'SHOFlashSaleProduct(id: $id, sessionId: $sessionId, title: $title, imageUrl: $imageUrl, originalPrice: $originalPrice, activityPrice: $activityPrice, skuAttributes: $skuAttributes, promoTags: $promoTags, primaryPromoType: $primaryPromoType, primaryPromoLabel: $primaryPromoLabel, status: $status, stock: $stock, soldCount: $soldCount, isFollowed: $isFollowed, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOFlashSaleProductImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.originalPrice, originalPrice) ||
                other.originalPrice == originalPrice) &&
            (identical(other.activityPrice, activityPrice) ||
                other.activityPrice == activityPrice) &&
            const DeepCollectionEquality().equals(
              other._skuAttributes,
              _skuAttributes,
            ) &&
            const DeepCollectionEquality().equals(
              other._promoTags,
              _promoTags,
            ) &&
            (identical(other.primaryPromoType, primaryPromoType) ||
                other.primaryPromoType == primaryPromoType) &&
            (identical(other.primaryPromoLabel, primaryPromoLabel) ||
                other.primaryPromoLabel == primaryPromoLabel) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.stock, stock) || other.stock == stock) &&
            (identical(other.soldCount, soldCount) ||
                other.soldCount == soldCount) &&
            (identical(other.isFollowed, isFollowed) ||
                other.isFollowed == isFollowed) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    sessionId,
    title,
    imageUrl,
    originalPrice,
    activityPrice,
    const DeepCollectionEquality().hash(_skuAttributes),
    const DeepCollectionEquality().hash(_promoTags),
    primaryPromoType,
    primaryPromoLabel,
    status,
    stock,
    soldCount,
    isFollowed,
    createdAt,
  );

  /// Create a copy of SHOFlashSaleProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOFlashSaleProductImplCopyWith<_$SHOFlashSaleProductImpl> get copyWith =>
      __$$SHOFlashSaleProductImplCopyWithImpl<_$SHOFlashSaleProductImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOFlashSaleProductImplToJson(this);
  }
}

abstract class _SHOFlashSaleProduct extends SHOFlashSaleProduct {
  const factory _SHOFlashSaleProduct({
    required final String id,
    required final String sessionId,
    required final String title,
    required final String imageUrl,
    required final int originalPrice,
    required final int activityPrice,
    final List<String> skuAttributes,
    final List<SHOFlashSalePromoTag> promoTags,
    final String? primaryPromoType,
    final String? primaryPromoLabel,
    final SHOFlashSaleProductStatus status,
    final int stock,
    final int soldCount,
    final bool isFollowed,
    final String? createdAt,
  }) = _$SHOFlashSaleProductImpl;
  const _SHOFlashSaleProduct._() : super._();

  factory _SHOFlashSaleProduct.fromJson(Map<String, dynamic> json) =
      _$SHOFlashSaleProductImpl.fromJson;

  @override
  String get id;
  @override
  String get sessionId;
  @override
  String get title;
  @override
  String get imageUrl;
  @override
  int get originalPrice;
  @override
  int get activityPrice;
  @override
  List<String> get skuAttributes;
  @override
  List<SHOFlashSalePromoTag> get promoTags;
  @override
  String? get primaryPromoType;
  @override
  String? get primaryPromoLabel;
  @override
  SHOFlashSaleProductStatus get status;
  @override
  int get stock;
  @override
  int get soldCount;
  @override
  bool get isFollowed;
  @override
  String? get createdAt;

  /// Create a copy of SHOFlashSaleProduct
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOFlashSaleProductImplCopyWith<_$SHOFlashSaleProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SHOFlashSaleProductActivity _$SHOFlashSaleProductActivityFromJson(
  Map<String, dynamic> json,
) {
  return _SHOFlashSaleProductActivity.fromJson(json);
}

/// @nodoc
mixin _$SHOFlashSaleProductActivity {
  String get sessionId => throw _privateConstructorUsedError;
  SHOFlashSaleProductStatus get status => throw _privateConstructorUsedError;
  int get originalPrice => throw _privateConstructorUsedError;
  int get activityPrice => throw _privateConstructorUsedError;
  List<SHOFlashSalePromoTag> get promoTags =>
      throw _privateConstructorUsedError;
  String? get primaryPromoType => throw _privateConstructorUsedError;
  String? get primaryPromoLabel => throw _privateConstructorUsedError;
  String? get sessionStartAt => throw _privateConstructorUsedError;
  String? get sessionEndAt => throw _privateConstructorUsedError;
  String? get overlayLabel => throw _privateConstructorUsedError;
  bool get isFollowed => throw _privateConstructorUsedError;
  int get stock => throw _privateConstructorUsedError;

  /// Serializes this SHOFlashSaleProductActivity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOFlashSaleProductActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOFlashSaleProductActivityCopyWith<SHOFlashSaleProductActivity>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOFlashSaleProductActivityCopyWith<$Res> {
  factory $SHOFlashSaleProductActivityCopyWith(
    SHOFlashSaleProductActivity value,
    $Res Function(SHOFlashSaleProductActivity) then,
  ) =
      _$SHOFlashSaleProductActivityCopyWithImpl<
        $Res,
        SHOFlashSaleProductActivity
      >;
  @useResult
  $Res call({
    String sessionId,
    SHOFlashSaleProductStatus status,
    int originalPrice,
    int activityPrice,
    List<SHOFlashSalePromoTag> promoTags,
    String? primaryPromoType,
    String? primaryPromoLabel,
    String? sessionStartAt,
    String? sessionEndAt,
    String? overlayLabel,
    bool isFollowed,
    int stock,
  });
}

/// @nodoc
class _$SHOFlashSaleProductActivityCopyWithImpl<
  $Res,
  $Val extends SHOFlashSaleProductActivity
>
    implements $SHOFlashSaleProductActivityCopyWith<$Res> {
  _$SHOFlashSaleProductActivityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOFlashSaleProductActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? status = null,
    Object? originalPrice = null,
    Object? activityPrice = null,
    Object? promoTags = null,
    Object? primaryPromoType = freezed,
    Object? primaryPromoLabel = freezed,
    Object? sessionStartAt = freezed,
    Object? sessionEndAt = freezed,
    Object? overlayLabel = freezed,
    Object? isFollowed = null,
    Object? stock = null,
  }) {
    return _then(
      _value.copyWith(
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SHOFlashSaleProductStatus,
            originalPrice: null == originalPrice
                ? _value.originalPrice
                : originalPrice // ignore: cast_nullable_to_non_nullable
                      as int,
            activityPrice: null == activityPrice
                ? _value.activityPrice
                : activityPrice // ignore: cast_nullable_to_non_nullable
                      as int,
            promoTags: null == promoTags
                ? _value.promoTags
                : promoTags // ignore: cast_nullable_to_non_nullable
                      as List<SHOFlashSalePromoTag>,
            primaryPromoType: freezed == primaryPromoType
                ? _value.primaryPromoType
                : primaryPromoType // ignore: cast_nullable_to_non_nullable
                      as String?,
            primaryPromoLabel: freezed == primaryPromoLabel
                ? _value.primaryPromoLabel
                : primaryPromoLabel // ignore: cast_nullable_to_non_nullable
                      as String?,
            sessionStartAt: freezed == sessionStartAt
                ? _value.sessionStartAt
                : sessionStartAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            sessionEndAt: freezed == sessionEndAt
                ? _value.sessionEndAt
                : sessionEndAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            overlayLabel: freezed == overlayLabel
                ? _value.overlayLabel
                : overlayLabel // ignore: cast_nullable_to_non_nullable
                      as String?,
            isFollowed: null == isFollowed
                ? _value.isFollowed
                : isFollowed // ignore: cast_nullable_to_non_nullable
                      as bool,
            stock: null == stock
                ? _value.stock
                : stock // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOFlashSaleProductActivityImplCopyWith<$Res>
    implements $SHOFlashSaleProductActivityCopyWith<$Res> {
  factory _$$SHOFlashSaleProductActivityImplCopyWith(
    _$SHOFlashSaleProductActivityImpl value,
    $Res Function(_$SHOFlashSaleProductActivityImpl) then,
  ) = __$$SHOFlashSaleProductActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String sessionId,
    SHOFlashSaleProductStatus status,
    int originalPrice,
    int activityPrice,
    List<SHOFlashSalePromoTag> promoTags,
    String? primaryPromoType,
    String? primaryPromoLabel,
    String? sessionStartAt,
    String? sessionEndAt,
    String? overlayLabel,
    bool isFollowed,
    int stock,
  });
}

/// @nodoc
class __$$SHOFlashSaleProductActivityImplCopyWithImpl<$Res>
    extends
        _$SHOFlashSaleProductActivityCopyWithImpl<
          $Res,
          _$SHOFlashSaleProductActivityImpl
        >
    implements _$$SHOFlashSaleProductActivityImplCopyWith<$Res> {
  __$$SHOFlashSaleProductActivityImplCopyWithImpl(
    _$SHOFlashSaleProductActivityImpl _value,
    $Res Function(_$SHOFlashSaleProductActivityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOFlashSaleProductActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? status = null,
    Object? originalPrice = null,
    Object? activityPrice = null,
    Object? promoTags = null,
    Object? primaryPromoType = freezed,
    Object? primaryPromoLabel = freezed,
    Object? sessionStartAt = freezed,
    Object? sessionEndAt = freezed,
    Object? overlayLabel = freezed,
    Object? isFollowed = null,
    Object? stock = null,
  }) {
    return _then(
      _$SHOFlashSaleProductActivityImpl(
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SHOFlashSaleProductStatus,
        originalPrice: null == originalPrice
            ? _value.originalPrice
            : originalPrice // ignore: cast_nullable_to_non_nullable
                  as int,
        activityPrice: null == activityPrice
            ? _value.activityPrice
            : activityPrice // ignore: cast_nullable_to_non_nullable
                  as int,
        promoTags: null == promoTags
            ? _value._promoTags
            : promoTags // ignore: cast_nullable_to_non_nullable
                  as List<SHOFlashSalePromoTag>,
        primaryPromoType: freezed == primaryPromoType
            ? _value.primaryPromoType
            : primaryPromoType // ignore: cast_nullable_to_non_nullable
                  as String?,
        primaryPromoLabel: freezed == primaryPromoLabel
            ? _value.primaryPromoLabel
            : primaryPromoLabel // ignore: cast_nullable_to_non_nullable
                  as String?,
        sessionStartAt: freezed == sessionStartAt
            ? _value.sessionStartAt
            : sessionStartAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        sessionEndAt: freezed == sessionEndAt
            ? _value.sessionEndAt
            : sessionEndAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        overlayLabel: freezed == overlayLabel
            ? _value.overlayLabel
            : overlayLabel // ignore: cast_nullable_to_non_nullable
                  as String?,
        isFollowed: null == isFollowed
            ? _value.isFollowed
            : isFollowed // ignore: cast_nullable_to_non_nullable
                  as bool,
        stock: null == stock
            ? _value.stock
            : stock // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOFlashSaleProductActivityImpl extends _SHOFlashSaleProductActivity {
  const _$SHOFlashSaleProductActivityImpl({
    required this.sessionId,
    required this.status,
    required this.originalPrice,
    required this.activityPrice,
    final List<SHOFlashSalePromoTag> promoTags = const [],
    this.primaryPromoType,
    this.primaryPromoLabel,
    this.sessionStartAt,
    this.sessionEndAt,
    this.overlayLabel,
    this.isFollowed = false,
    this.stock = 0,
  }) : _promoTags = promoTags,
       super._();

  factory _$SHOFlashSaleProductActivityImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$SHOFlashSaleProductActivityImplFromJson(json);

  @override
  final String sessionId;
  @override
  final SHOFlashSaleProductStatus status;
  @override
  final int originalPrice;
  @override
  final int activityPrice;
  final List<SHOFlashSalePromoTag> _promoTags;
  @override
  @JsonKey()
  List<SHOFlashSalePromoTag> get promoTags {
    if (_promoTags is EqualUnmodifiableListView) return _promoTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_promoTags);
  }

  @override
  final String? primaryPromoType;
  @override
  final String? primaryPromoLabel;
  @override
  final String? sessionStartAt;
  @override
  final String? sessionEndAt;
  @override
  final String? overlayLabel;
  @override
  @JsonKey()
  final bool isFollowed;
  @override
  @JsonKey()
  final int stock;

  @override
  String toString() {
    return 'SHOFlashSaleProductActivity(sessionId: $sessionId, status: $status, originalPrice: $originalPrice, activityPrice: $activityPrice, promoTags: $promoTags, primaryPromoType: $primaryPromoType, primaryPromoLabel: $primaryPromoLabel, sessionStartAt: $sessionStartAt, sessionEndAt: $sessionEndAt, overlayLabel: $overlayLabel, isFollowed: $isFollowed, stock: $stock)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOFlashSaleProductActivityImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.originalPrice, originalPrice) ||
                other.originalPrice == originalPrice) &&
            (identical(other.activityPrice, activityPrice) ||
                other.activityPrice == activityPrice) &&
            const DeepCollectionEquality().equals(
              other._promoTags,
              _promoTags,
            ) &&
            (identical(other.primaryPromoType, primaryPromoType) ||
                other.primaryPromoType == primaryPromoType) &&
            (identical(other.primaryPromoLabel, primaryPromoLabel) ||
                other.primaryPromoLabel == primaryPromoLabel) &&
            (identical(other.sessionStartAt, sessionStartAt) ||
                other.sessionStartAt == sessionStartAt) &&
            (identical(other.sessionEndAt, sessionEndAt) ||
                other.sessionEndAt == sessionEndAt) &&
            (identical(other.overlayLabel, overlayLabel) ||
                other.overlayLabel == overlayLabel) &&
            (identical(other.isFollowed, isFollowed) ||
                other.isFollowed == isFollowed) &&
            (identical(other.stock, stock) || other.stock == stock));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    sessionId,
    status,
    originalPrice,
    activityPrice,
    const DeepCollectionEquality().hash(_promoTags),
    primaryPromoType,
    primaryPromoLabel,
    sessionStartAt,
    sessionEndAt,
    overlayLabel,
    isFollowed,
    stock,
  );

  /// Create a copy of SHOFlashSaleProductActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOFlashSaleProductActivityImplCopyWith<_$SHOFlashSaleProductActivityImpl>
  get copyWith =>
      __$$SHOFlashSaleProductActivityImplCopyWithImpl<
        _$SHOFlashSaleProductActivityImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOFlashSaleProductActivityImplToJson(this);
  }
}

abstract class _SHOFlashSaleProductActivity
    extends SHOFlashSaleProductActivity {
  const factory _SHOFlashSaleProductActivity({
    required final String sessionId,
    required final SHOFlashSaleProductStatus status,
    required final int originalPrice,
    required final int activityPrice,
    final List<SHOFlashSalePromoTag> promoTags,
    final String? primaryPromoType,
    final String? primaryPromoLabel,
    final String? sessionStartAt,
    final String? sessionEndAt,
    final String? overlayLabel,
    final bool isFollowed,
    final int stock,
  }) = _$SHOFlashSaleProductActivityImpl;
  const _SHOFlashSaleProductActivity._() : super._();

  factory _SHOFlashSaleProductActivity.fromJson(Map<String, dynamic> json) =
      _$SHOFlashSaleProductActivityImpl.fromJson;

  @override
  String get sessionId;
  @override
  SHOFlashSaleProductStatus get status;
  @override
  int get originalPrice;
  @override
  int get activityPrice;
  @override
  List<SHOFlashSalePromoTag> get promoTags;
  @override
  String? get primaryPromoType;
  @override
  String? get primaryPromoLabel;
  @override
  String? get sessionStartAt;
  @override
  String? get sessionEndAt;
  @override
  String? get overlayLabel;
  @override
  bool get isFollowed;
  @override
  int get stock;

  /// Create a copy of SHOFlashSaleProductActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOFlashSaleProductActivityImplCopyWith<_$SHOFlashSaleProductActivityImpl>
  get copyWith => throw _privateConstructorUsedError;
}
