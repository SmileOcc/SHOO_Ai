// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hos_cart.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SHOCartItem _$SHOCartItemFromJson(Map<String, dynamic> json) {
  return _SHOCartItem.fromJson(json);
}

/// @nodoc
mixin _$SHOCartItem {
  String get id => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  int get price => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  String get variantLabel => throw _privateConstructorUsedError;
  bool get selected => throw _privateConstructorUsedError;

  /// Serializes this SHOCartItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOCartItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOCartItemCopyWith<SHOCartItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOCartItemCopyWith<$Res> {
  factory $SHOCartItemCopyWith(
    SHOCartItem value,
    $Res Function(SHOCartItem) then,
  ) = _$SHOCartItemCopyWithImpl<$Res, SHOCartItem>;
  @useResult
  $Res call({
    String id,
    String productId,
    String title,
    String imageUrl,
    int price,
    int quantity,
    String variantLabel,
    bool selected,
  });
}

/// @nodoc
class _$SHOCartItemCopyWithImpl<$Res, $Val extends SHOCartItem>
    implements $SHOCartItemCopyWith<$Res> {
  _$SHOCartItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOCartItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? title = null,
    Object? imageUrl = null,
    Object? price = null,
    Object? quantity = null,
    Object? variantLabel = null,
    Object? selected = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
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
            selected: null == selected
                ? _value.selected
                : selected // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOCartItemImplCopyWith<$Res>
    implements $SHOCartItemCopyWith<$Res> {
  factory _$$SHOCartItemImplCopyWith(
    _$SHOCartItemImpl value,
    $Res Function(_$SHOCartItemImpl) then,
  ) = __$$SHOCartItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String productId,
    String title,
    String imageUrl,
    int price,
    int quantity,
    String variantLabel,
    bool selected,
  });
}

/// @nodoc
class __$$SHOCartItemImplCopyWithImpl<$Res>
    extends _$SHOCartItemCopyWithImpl<$Res, _$SHOCartItemImpl>
    implements _$$SHOCartItemImplCopyWith<$Res> {
  __$$SHOCartItemImplCopyWithImpl(
    _$SHOCartItemImpl _value,
    $Res Function(_$SHOCartItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOCartItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? title = null,
    Object? imageUrl = null,
    Object? price = null,
    Object? quantity = null,
    Object? variantLabel = null,
    Object? selected = null,
  }) {
    return _then(
      _$SHOCartItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
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
        selected: null == selected
            ? _value.selected
            : selected // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOCartItemImpl implements _SHOCartItem {
  const _$SHOCartItemImpl({
    required this.id,
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.quantity = 1,
    this.variantLabel = '',
    this.selected = true,
  });

  factory _$SHOCartItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOCartItemImplFromJson(json);

  @override
  final String id;
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
  @JsonKey()
  final bool selected;

  @override
  String toString() {
    return 'SHOCartItem(id: $id, productId: $productId, title: $title, imageUrl: $imageUrl, price: $price, quantity: $quantity, variantLabel: $variantLabel, selected: $selected)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOCartItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.variantLabel, variantLabel) ||
                other.variantLabel == variantLabel) &&
            (identical(other.selected, selected) ||
                other.selected == selected));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    productId,
    title,
    imageUrl,
    price,
    quantity,
    variantLabel,
    selected,
  );

  /// Create a copy of SHOCartItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOCartItemImplCopyWith<_$SHOCartItemImpl> get copyWith =>
      __$$SHOCartItemImplCopyWithImpl<_$SHOCartItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOCartItemImplToJson(this);
  }
}

abstract class _SHOCartItem implements SHOCartItem {
  const factory _SHOCartItem({
    required final String id,
    required final String productId,
    required final String title,
    required final String imageUrl,
    required final int price,
    final int quantity,
    final String variantLabel,
    final bool selected,
  }) = _$SHOCartItemImpl;

  factory _SHOCartItem.fromJson(Map<String, dynamic> json) =
      _$SHOCartItemImpl.fromJson;

  @override
  String get id;
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
  @override
  bool get selected;

  /// Create a copy of SHOCartItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOCartItemImplCopyWith<_$SHOCartItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SHOCartSnapshot _$SHOCartSnapshotFromJson(Map<String, dynamic> json) {
  return _SHOCartSnapshot.fromJson(json);
}

/// @nodoc
mixin _$SHOCartSnapshot {
  List<SHOCartItem> get items => throw _privateConstructorUsedError;

  /// Serializes this SHOCartSnapshot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOCartSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOCartSnapshotCopyWith<SHOCartSnapshot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOCartSnapshotCopyWith<$Res> {
  factory $SHOCartSnapshotCopyWith(
    SHOCartSnapshot value,
    $Res Function(SHOCartSnapshot) then,
  ) = _$SHOCartSnapshotCopyWithImpl<$Res, SHOCartSnapshot>;
  @useResult
  $Res call({List<SHOCartItem> items});
}

/// @nodoc
class _$SHOCartSnapshotCopyWithImpl<$Res, $Val extends SHOCartSnapshot>
    implements $SHOCartSnapshotCopyWith<$Res> {
  _$SHOCartSnapshotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOCartSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? items = null}) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<SHOCartItem>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOCartSnapshotImplCopyWith<$Res>
    implements $SHOCartSnapshotCopyWith<$Res> {
  factory _$$SHOCartSnapshotImplCopyWith(
    _$SHOCartSnapshotImpl value,
    $Res Function(_$SHOCartSnapshotImpl) then,
  ) = __$$SHOCartSnapshotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<SHOCartItem> items});
}

/// @nodoc
class __$$SHOCartSnapshotImplCopyWithImpl<$Res>
    extends _$SHOCartSnapshotCopyWithImpl<$Res, _$SHOCartSnapshotImpl>
    implements _$$SHOCartSnapshotImplCopyWith<$Res> {
  __$$SHOCartSnapshotImplCopyWithImpl(
    _$SHOCartSnapshotImpl _value,
    $Res Function(_$SHOCartSnapshotImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOCartSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? items = null}) {
    return _then(
      _$SHOCartSnapshotImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<SHOCartItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOCartSnapshotImpl extends _SHOCartSnapshot {
  const _$SHOCartSnapshotImpl({
    final List<SHOCartItem> items = const <SHOCartItem>[],
  }) : _items = items,
       super._();

  factory _$SHOCartSnapshotImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOCartSnapshotImplFromJson(json);

  final List<SHOCartItem> _items;
  @override
  @JsonKey()
  List<SHOCartItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'SHOCartSnapshot(items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOCartSnapshotImpl &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_items));

  /// Create a copy of SHOCartSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOCartSnapshotImplCopyWith<_$SHOCartSnapshotImpl> get copyWith =>
      __$$SHOCartSnapshotImplCopyWithImpl<_$SHOCartSnapshotImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOCartSnapshotImplToJson(this);
  }
}

abstract class _SHOCartSnapshot extends SHOCartSnapshot {
  const factory _SHOCartSnapshot({final List<SHOCartItem> items}) =
      _$SHOCartSnapshotImpl;
  const _SHOCartSnapshot._() : super._();

  factory _SHOCartSnapshot.fromJson(Map<String, dynamic> json) =
      _$SHOCartSnapshotImpl.fromJson;

  @override
  List<SHOCartItem> get items;

  /// Create a copy of SHOCartSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOCartSnapshotImplCopyWith<_$SHOCartSnapshotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
