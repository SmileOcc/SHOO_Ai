// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hos_order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SHOOrderItem _$SHOOrderItemFromJson(Map<String, dynamic> json) {
  return _SHOOrderItem.fromJson(json);
}

/// @nodoc
mixin _$SHOOrderItem {
  String get productId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  int get price => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  String get variantLabel => throw _privateConstructorUsedError;

  /// Serializes this SHOOrderItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOOrderItemCopyWith<SHOOrderItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOOrderItemCopyWith<$Res> {
  factory $SHOOrderItemCopyWith(
    SHOOrderItem value,
    $Res Function(SHOOrderItem) then,
  ) = _$SHOOrderItemCopyWithImpl<$Res, SHOOrderItem>;
  @useResult
  $Res call({
    String productId,
    String title,
    String imageUrl,
    int price,
    int quantity,
    String variantLabel,
  });
}

/// @nodoc
class _$SHOOrderItemCopyWithImpl<$Res, $Val extends SHOOrderItem>
    implements $SHOOrderItemCopyWith<$Res> {
  _$SHOOrderItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? title = null,
    Object? imageUrl = null,
    Object? price = null,
    Object? quantity = null,
    Object? variantLabel = null,
  }) {
    return _then(
      _value.copyWith(
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
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
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
            variantLabel: null == variantLabel
                ? _value.variantLabel
                : variantLabel // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOOrderItemImplCopyWith<$Res>
    implements $SHOOrderItemCopyWith<$Res> {
  factory _$$SHOOrderItemImplCopyWith(
    _$SHOOrderItemImpl value,
    $Res Function(_$SHOOrderItemImpl) then,
  ) = __$$SHOOrderItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String productId,
    String title,
    String imageUrl,
    int price,
    int quantity,
    String variantLabel,
  });
}

/// @nodoc
class __$$SHOOrderItemImplCopyWithImpl<$Res>
    extends _$SHOOrderItemCopyWithImpl<$Res, _$SHOOrderItemImpl>
    implements _$$SHOOrderItemImplCopyWith<$Res> {
  __$$SHOOrderItemImplCopyWithImpl(
    _$SHOOrderItemImpl _value,
    $Res Function(_$SHOOrderItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? title = null,
    Object? imageUrl = null,
    Object? price = null,
    Object? quantity = null,
    Object? variantLabel = null,
  }) {
    return _then(
      _$SHOOrderItemImpl(
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
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
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
        variantLabel: null == variantLabel
            ? _value.variantLabel
            : variantLabel // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOOrderItemImpl implements _SHOOrderItem {
  const _$SHOOrderItemImpl({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.quantity = 1,
    this.variantLabel = '',
  });

  factory _$SHOOrderItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOOrderItemImplFromJson(json);

  @override
  final String productId;
  @override
  final String title;
  @override
  final String imageUrl;
  @override
  final int price;
  @override
  @JsonKey()
  final int quantity;
  @override
  @JsonKey()
  final String variantLabel;

  @override
  String toString() {
    return 'SHOOrderItem(productId: $productId, title: $title, imageUrl: $imageUrl, price: $price, quantity: $quantity, variantLabel: $variantLabel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOOrderItemImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.variantLabel, variantLabel) ||
                other.variantLabel == variantLabel));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    productId,
    title,
    imageUrl,
    price,
    quantity,
    variantLabel,
  );

  /// Create a copy of SHOOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOOrderItemImplCopyWith<_$SHOOrderItemImpl> get copyWith =>
      __$$SHOOrderItemImplCopyWithImpl<_$SHOOrderItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOOrderItemImplToJson(this);
  }
}

abstract class _SHOOrderItem implements SHOOrderItem {
  const factory _SHOOrderItem({
    required final String productId,
    required final String title,
    required final String imageUrl,
    required final int price,
    final int quantity,
    final String variantLabel,
  }) = _$SHOOrderItemImpl;

  factory _SHOOrderItem.fromJson(Map<String, dynamic> json) =
      _$SHOOrderItemImpl.fromJson;

  @override
  String get productId;
  @override
  String get title;
  @override
  String get imageUrl;
  @override
  int get price;
  @override
  int get quantity;
  @override
  String get variantLabel;

  /// Create a copy of SHOOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOOrderItemImplCopyWith<_$SHOOrderItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SHOOrderSummary _$SHOOrderSummaryFromJson(Map<String, dynamic> json) {
  return _SHOOrderSummary.fromJson(json);
}

/// @nodoc
mixin _$SHOOrderSummary {
  String get id => throw _privateConstructorUsedError;
  String get orderNo => throw _privateConstructorUsedError;
  SHOOrderStatus get status => throw _privateConstructorUsedError;
  int get totalCents => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  List<SHOOrderItem> get items => throw _privateConstructorUsedError;

  /// Serializes this SHOOrderSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOOrderSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOOrderSummaryCopyWith<SHOOrderSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOOrderSummaryCopyWith<$Res> {
  factory $SHOOrderSummaryCopyWith(
    SHOOrderSummary value,
    $Res Function(SHOOrderSummary) then,
  ) = _$SHOOrderSummaryCopyWithImpl<$Res, SHOOrderSummary>;
  @useResult
  $Res call({
    String id,
    String orderNo,
    SHOOrderStatus status,
    int totalCents,
    String createdAt,
    List<SHOOrderItem> items,
  });
}

/// @nodoc
class _$SHOOrderSummaryCopyWithImpl<$Res, $Val extends SHOOrderSummary>
    implements $SHOOrderSummaryCopyWith<$Res> {
  _$SHOOrderSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOOrderSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderNo = null,
    Object? status = null,
    Object? totalCents = null,
    Object? createdAt = null,
    Object? items = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            orderNo: null == orderNo
                ? _value.orderNo
                : orderNo // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SHOOrderStatus,
            totalCents: null == totalCents
                ? _value.totalCents
                : totalCents // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<SHOOrderItem>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOOrderSummaryImplCopyWith<$Res>
    implements $SHOOrderSummaryCopyWith<$Res> {
  factory _$$SHOOrderSummaryImplCopyWith(
    _$SHOOrderSummaryImpl value,
    $Res Function(_$SHOOrderSummaryImpl) then,
  ) = __$$SHOOrderSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderNo,
    SHOOrderStatus status,
    int totalCents,
    String createdAt,
    List<SHOOrderItem> items,
  });
}

/// @nodoc
class __$$SHOOrderSummaryImplCopyWithImpl<$Res>
    extends _$SHOOrderSummaryCopyWithImpl<$Res, _$SHOOrderSummaryImpl>
    implements _$$SHOOrderSummaryImplCopyWith<$Res> {
  __$$SHOOrderSummaryImplCopyWithImpl(
    _$SHOOrderSummaryImpl _value,
    $Res Function(_$SHOOrderSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOOrderSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderNo = null,
    Object? status = null,
    Object? totalCents = null,
    Object? createdAt = null,
    Object? items = null,
  }) {
    return _then(
      _$SHOOrderSummaryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderNo: null == orderNo
            ? _value.orderNo
            : orderNo // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SHOOrderStatus,
        totalCents: null == totalCents
            ? _value.totalCents
            : totalCents // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<SHOOrderItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOOrderSummaryImpl implements _SHOOrderSummary {
  const _$SHOOrderSummaryImpl({
    required this.id,
    required this.orderNo,
    required this.status,
    required this.totalCents,
    required this.createdAt,
    final List<SHOOrderItem> items = const <SHOOrderItem>[],
  }) : _items = items;

  factory _$SHOOrderSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOOrderSummaryImplFromJson(json);

  @override
  final String id;
  @override
  final String orderNo;
  @override
  final SHOOrderStatus status;
  @override
  final int totalCents;
  @override
  final String createdAt;
  final List<SHOOrderItem> _items;
  @override
  @JsonKey()
  List<SHOOrderItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'SHOOrderSummary(id: $id, orderNo: $orderNo, status: $status, totalCents: $totalCents, createdAt: $createdAt, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOOrderSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderNo, orderNo) || other.orderNo == orderNo) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.totalCents, totalCents) ||
                other.totalCents == totalCents) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orderNo,
    status,
    totalCents,
    createdAt,
    const DeepCollectionEquality().hash(_items),
  );

  /// Create a copy of SHOOrderSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOOrderSummaryImplCopyWith<_$SHOOrderSummaryImpl> get copyWith =>
      __$$SHOOrderSummaryImplCopyWithImpl<_$SHOOrderSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOOrderSummaryImplToJson(this);
  }
}

abstract class _SHOOrderSummary implements SHOOrderSummary {
  const factory _SHOOrderSummary({
    required final String id,
    required final String orderNo,
    required final SHOOrderStatus status,
    required final int totalCents,
    required final String createdAt,
    final List<SHOOrderItem> items,
  }) = _$SHOOrderSummaryImpl;

  factory _SHOOrderSummary.fromJson(Map<String, dynamic> json) =
      _$SHOOrderSummaryImpl.fromJson;

  @override
  String get id;
  @override
  String get orderNo;
  @override
  SHOOrderStatus get status;
  @override
  int get totalCents;
  @override
  String get createdAt;
  @override
  List<SHOOrderItem> get items;

  /// Create a copy of SHOOrderSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOOrderSummaryImplCopyWith<_$SHOOrderSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SHOOrderDetail _$SHOOrderDetailFromJson(Map<String, dynamic> json) {
  return _SHOOrderDetail.fromJson(json);
}

/// @nodoc
mixin _$SHOOrderDetail {
  String get id => throw _privateConstructorUsedError;
  String get orderNo => throw _privateConstructorUsedError;
  SHOOrderStatus get status => throw _privateConstructorUsedError;
  int get totalCents => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get shippingAddress => throw _privateConstructorUsedError;
  List<SHOOrderItem> get items => throw _privateConstructorUsedError;
  bool get hasLogistics => throw _privateConstructorUsedError;

  /// Serializes this SHOOrderDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOOrderDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOOrderDetailCopyWith<SHOOrderDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOOrderDetailCopyWith<$Res> {
  factory $SHOOrderDetailCopyWith(
    SHOOrderDetail value,
    $Res Function(SHOOrderDetail) then,
  ) = _$SHOOrderDetailCopyWithImpl<$Res, SHOOrderDetail>;
  @useResult
  $Res call({
    String id,
    String orderNo,
    SHOOrderStatus status,
    int totalCents,
    String createdAt,
    String shippingAddress,
    List<SHOOrderItem> items,
    bool hasLogistics,
  });
}

/// @nodoc
class _$SHOOrderDetailCopyWithImpl<$Res, $Val extends SHOOrderDetail>
    implements $SHOOrderDetailCopyWith<$Res> {
  _$SHOOrderDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOOrderDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderNo = null,
    Object? status = null,
    Object? totalCents = null,
    Object? createdAt = null,
    Object? shippingAddress = null,
    Object? items = null,
    Object? hasLogistics = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            orderNo: null == orderNo
                ? _value.orderNo
                : orderNo // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SHOOrderStatus,
            totalCents: null == totalCents
                ? _value.totalCents
                : totalCents // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            shippingAddress: null == shippingAddress
                ? _value.shippingAddress
                : shippingAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<SHOOrderItem>,
            hasLogistics: null == hasLogistics
                ? _value.hasLogistics
                : hasLogistics // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOOrderDetailImplCopyWith<$Res>
    implements $SHOOrderDetailCopyWith<$Res> {
  factory _$$SHOOrderDetailImplCopyWith(
    _$SHOOrderDetailImpl value,
    $Res Function(_$SHOOrderDetailImpl) then,
  ) = __$$SHOOrderDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderNo,
    SHOOrderStatus status,
    int totalCents,
    String createdAt,
    String shippingAddress,
    List<SHOOrderItem> items,
    bool hasLogistics,
  });
}

/// @nodoc
class __$$SHOOrderDetailImplCopyWithImpl<$Res>
    extends _$SHOOrderDetailCopyWithImpl<$Res, _$SHOOrderDetailImpl>
    implements _$$SHOOrderDetailImplCopyWith<$Res> {
  __$$SHOOrderDetailImplCopyWithImpl(
    _$SHOOrderDetailImpl _value,
    $Res Function(_$SHOOrderDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOOrderDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderNo = null,
    Object? status = null,
    Object? totalCents = null,
    Object? createdAt = null,
    Object? shippingAddress = null,
    Object? items = null,
    Object? hasLogistics = null,
  }) {
    return _then(
      _$SHOOrderDetailImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderNo: null == orderNo
            ? _value.orderNo
            : orderNo // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SHOOrderStatus,
        totalCents: null == totalCents
            ? _value.totalCents
            : totalCents // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        shippingAddress: null == shippingAddress
            ? _value.shippingAddress
            : shippingAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<SHOOrderItem>,
        hasLogistics: null == hasLogistics
            ? _value.hasLogistics
            : hasLogistics // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOOrderDetailImpl implements _SHOOrderDetail {
  const _$SHOOrderDetailImpl({
    required this.id,
    required this.orderNo,
    required this.status,
    required this.totalCents,
    required this.createdAt,
    this.shippingAddress = '',
    final List<SHOOrderItem> items = const <SHOOrderItem>[],
    this.hasLogistics = false,
  }) : _items = items;

  factory _$SHOOrderDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOOrderDetailImplFromJson(json);

  @override
  final String id;
  @override
  final String orderNo;
  @override
  final SHOOrderStatus status;
  @override
  final int totalCents;
  @override
  final String createdAt;
  @override
  @JsonKey()
  final String shippingAddress;
  final List<SHOOrderItem> _items;
  @override
  @JsonKey()
  List<SHOOrderItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final bool hasLogistics;

  @override
  String toString() {
    return 'SHOOrderDetail(id: $id, orderNo: $orderNo, status: $status, totalCents: $totalCents, createdAt: $createdAt, shippingAddress: $shippingAddress, items: $items, hasLogistics: $hasLogistics)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOOrderDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderNo, orderNo) || other.orderNo == orderNo) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.totalCents, totalCents) ||
                other.totalCents == totalCents) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.shippingAddress, shippingAddress) ||
                other.shippingAddress == shippingAddress) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.hasLogistics, hasLogistics) ||
                other.hasLogistics == hasLogistics));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orderNo,
    status,
    totalCents,
    createdAt,
    shippingAddress,
    const DeepCollectionEquality().hash(_items),
    hasLogistics,
  );

  /// Create a copy of SHOOrderDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOOrderDetailImplCopyWith<_$SHOOrderDetailImpl> get copyWith =>
      __$$SHOOrderDetailImplCopyWithImpl<_$SHOOrderDetailImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOOrderDetailImplToJson(this);
  }
}

abstract class _SHOOrderDetail implements SHOOrderDetail {
  const factory _SHOOrderDetail({
    required final String id,
    required final String orderNo,
    required final SHOOrderStatus status,
    required final int totalCents,
    required final String createdAt,
    final String shippingAddress,
    final List<SHOOrderItem> items,
    final bool hasLogistics,
  }) = _$SHOOrderDetailImpl;

  factory _SHOOrderDetail.fromJson(Map<String, dynamic> json) =
      _$SHOOrderDetailImpl.fromJson;

  @override
  String get id;
  @override
  String get orderNo;
  @override
  SHOOrderStatus get status;
  @override
  int get totalCents;
  @override
  String get createdAt;
  @override
  String get shippingAddress;
  @override
  List<SHOOrderItem> get items;
  @override
  bool get hasLogistics;

  /// Create a copy of SHOOrderDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOOrderDetailImplCopyWith<_$SHOOrderDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SHOLogisticsEvent _$SHOLogisticsEventFromJson(Map<String, dynamic> json) {
  return _SHOLogisticsEvent.fromJson(json);
}

/// @nodoc
mixin _$SHOLogisticsEvent {
  String get time => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this SHOLogisticsEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOLogisticsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOLogisticsEventCopyWith<SHOLogisticsEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOLogisticsEventCopyWith<$Res> {
  factory $SHOLogisticsEventCopyWith(
    SHOLogisticsEvent value,
    $Res Function(SHOLogisticsEvent) then,
  ) = _$SHOLogisticsEventCopyWithImpl<$Res, SHOLogisticsEvent>;
  @useResult
  $Res call({String time, String status, String description, bool isActive});
}

/// @nodoc
class _$SHOLogisticsEventCopyWithImpl<$Res, $Val extends SHOLogisticsEvent>
    implements $SHOLogisticsEventCopyWith<$Res> {
  _$SHOLogisticsEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOLogisticsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? time = null,
    Object? status = null,
    Object? description = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            time: null == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOLogisticsEventImplCopyWith<$Res>
    implements $SHOLogisticsEventCopyWith<$Res> {
  factory _$$SHOLogisticsEventImplCopyWith(
    _$SHOLogisticsEventImpl value,
    $Res Function(_$SHOLogisticsEventImpl) then,
  ) = __$$SHOLogisticsEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String time, String status, String description, bool isActive});
}

/// @nodoc
class __$$SHOLogisticsEventImplCopyWithImpl<$Res>
    extends _$SHOLogisticsEventCopyWithImpl<$Res, _$SHOLogisticsEventImpl>
    implements _$$SHOLogisticsEventImplCopyWith<$Res> {
  __$$SHOLogisticsEventImplCopyWithImpl(
    _$SHOLogisticsEventImpl _value,
    $Res Function(_$SHOLogisticsEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOLogisticsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? time = null,
    Object? status = null,
    Object? description = null,
    Object? isActive = null,
  }) {
    return _then(
      _$SHOLogisticsEventImpl(
        time: null == time
            ? _value.time
            : time // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOLogisticsEventImpl implements _SHOLogisticsEvent {
  const _$SHOLogisticsEventImpl({
    required this.time,
    required this.status,
    required this.description,
    this.isActive = false,
  });

  factory _$SHOLogisticsEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOLogisticsEventImplFromJson(json);

  @override
  final String time;
  @override
  final String status;
  @override
  final String description;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'SHOLogisticsEvent(time: $time, status: $status, description: $description, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOLogisticsEventImpl &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, time, status, description, isActive);

  /// Create a copy of SHOLogisticsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOLogisticsEventImplCopyWith<_$SHOLogisticsEventImpl> get copyWith =>
      __$$SHOLogisticsEventImplCopyWithImpl<_$SHOLogisticsEventImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOLogisticsEventImplToJson(this);
  }
}

abstract class _SHOLogisticsEvent implements SHOLogisticsEvent {
  const factory _SHOLogisticsEvent({
    required final String time,
    required final String status,
    required final String description,
    final bool isActive,
  }) = _$SHOLogisticsEventImpl;

  factory _SHOLogisticsEvent.fromJson(Map<String, dynamic> json) =
      _$SHOLogisticsEventImpl.fromJson;

  @override
  String get time;
  @override
  String get status;
  @override
  String get description;
  @override
  bool get isActive;

  /// Create a copy of SHOLogisticsEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOLogisticsEventImplCopyWith<_$SHOLogisticsEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SHOLogisticsTrack _$SHOLogisticsTrackFromJson(Map<String, dynamic> json) {
  return _SHOLogisticsTrack.fromJson(json);
}

/// @nodoc
mixin _$SHOLogisticsTrack {
  String get orderId => throw _privateConstructorUsedError;
  String get carrier => throw _privateConstructorUsedError;
  String get trackingNumber => throw _privateConstructorUsedError;
  List<SHOLogisticsEvent> get events => throw _privateConstructorUsedError;

  /// Serializes this SHOLogisticsTrack to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOLogisticsTrack
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOLogisticsTrackCopyWith<SHOLogisticsTrack> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOLogisticsTrackCopyWith<$Res> {
  factory $SHOLogisticsTrackCopyWith(
    SHOLogisticsTrack value,
    $Res Function(SHOLogisticsTrack) then,
  ) = _$SHOLogisticsTrackCopyWithImpl<$Res, SHOLogisticsTrack>;
  @useResult
  $Res call({
    String orderId,
    String carrier,
    String trackingNumber,
    List<SHOLogisticsEvent> events,
  });
}

/// @nodoc
class _$SHOLogisticsTrackCopyWithImpl<$Res, $Val extends SHOLogisticsTrack>
    implements $SHOLogisticsTrackCopyWith<$Res> {
  _$SHOLogisticsTrackCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOLogisticsTrack
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? carrier = null,
    Object? trackingNumber = null,
    Object? events = null,
  }) {
    return _then(
      _value.copyWith(
            orderId: null == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                      as String,
            carrier: null == carrier
                ? _value.carrier
                : carrier // ignore: cast_nullable_to_non_nullable
                      as String,
            trackingNumber: null == trackingNumber
                ? _value.trackingNumber
                : trackingNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            events: null == events
                ? _value.events
                : events // ignore: cast_nullable_to_non_nullable
                      as List<SHOLogisticsEvent>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOLogisticsTrackImplCopyWith<$Res>
    implements $SHOLogisticsTrackCopyWith<$Res> {
  factory _$$SHOLogisticsTrackImplCopyWith(
    _$SHOLogisticsTrackImpl value,
    $Res Function(_$SHOLogisticsTrackImpl) then,
  ) = __$$SHOLogisticsTrackImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String orderId,
    String carrier,
    String trackingNumber,
    List<SHOLogisticsEvent> events,
  });
}

/// @nodoc
class __$$SHOLogisticsTrackImplCopyWithImpl<$Res>
    extends _$SHOLogisticsTrackCopyWithImpl<$Res, _$SHOLogisticsTrackImpl>
    implements _$$SHOLogisticsTrackImplCopyWith<$Res> {
  __$$SHOLogisticsTrackImplCopyWithImpl(
    _$SHOLogisticsTrackImpl _value,
    $Res Function(_$SHOLogisticsTrackImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOLogisticsTrack
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? carrier = null,
    Object? trackingNumber = null,
    Object? events = null,
  }) {
    return _then(
      _$SHOLogisticsTrackImpl(
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        carrier: null == carrier
            ? _value.carrier
            : carrier // ignore: cast_nullable_to_non_nullable
                  as String,
        trackingNumber: null == trackingNumber
            ? _value.trackingNumber
            : trackingNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        events: null == events
            ? _value._events
            : events // ignore: cast_nullable_to_non_nullable
                  as List<SHOLogisticsEvent>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOLogisticsTrackImpl implements _SHOLogisticsTrack {
  const _$SHOLogisticsTrackImpl({
    required this.orderId,
    required this.carrier,
    required this.trackingNumber,
    final List<SHOLogisticsEvent> events = const <SHOLogisticsEvent>[],
  }) : _events = events;

  factory _$SHOLogisticsTrackImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOLogisticsTrackImplFromJson(json);

  @override
  final String orderId;
  @override
  final String carrier;
  @override
  final String trackingNumber;
  final List<SHOLogisticsEvent> _events;
  @override
  @JsonKey()
  List<SHOLogisticsEvent> get events {
    if (_events is EqualUnmodifiableListView) return _events;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_events);
  }

  @override
  String toString() {
    return 'SHOLogisticsTrack(orderId: $orderId, carrier: $carrier, trackingNumber: $trackingNumber, events: $events)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOLogisticsTrackImpl &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.carrier, carrier) || other.carrier == carrier) &&
            (identical(other.trackingNumber, trackingNumber) ||
                other.trackingNumber == trackingNumber) &&
            const DeepCollectionEquality().equals(other._events, _events));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    orderId,
    carrier,
    trackingNumber,
    const DeepCollectionEquality().hash(_events),
  );

  /// Create a copy of SHOLogisticsTrack
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOLogisticsTrackImplCopyWith<_$SHOLogisticsTrackImpl> get copyWith =>
      __$$SHOLogisticsTrackImplCopyWithImpl<_$SHOLogisticsTrackImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOLogisticsTrackImplToJson(this);
  }
}

abstract class _SHOLogisticsTrack implements SHOLogisticsTrack {
  const factory _SHOLogisticsTrack({
    required final String orderId,
    required final String carrier,
    required final String trackingNumber,
    final List<SHOLogisticsEvent> events,
  }) = _$SHOLogisticsTrackImpl;

  factory _SHOLogisticsTrack.fromJson(Map<String, dynamic> json) =
      _$SHOLogisticsTrackImpl.fromJson;

  @override
  String get orderId;
  @override
  String get carrier;
  @override
  String get trackingNumber;
  @override
  List<SHOLogisticsEvent> get events;

  /// Create a copy of SHOLogisticsTrack
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOLogisticsTrackImplCopyWith<_$SHOLogisticsTrackImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
