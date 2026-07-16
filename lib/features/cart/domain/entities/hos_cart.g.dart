// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hos_cart.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SHOCartItemImpl _$$SHOCartItemImplFromJson(Map<String, dynamic> json) =>
    _$SHOCartItemImpl(
      id: json['id'] as String,
      productId: json['productId'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      price: (json['price'] as num).toInt(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      variantLabel: json['variantLabel'] as String? ?? '',
      selected: json['selected'] as bool? ?? true,
      unavailable: json['unavailable'] as bool? ?? false,
      priceChanged: json['priceChanged'] as bool? ?? false,
      stock: (json['stock'] as num?)?.toInt() ?? kSHOCartDefaultStock,
      listPrice: (json['listPrice'] as num?)?.toInt() ?? 0,
      sessionId: json['sessionId'] as String? ?? '',
      sessionEndAt: json['sessionEndAt'] as String? ?? '',
    );

Map<String, dynamic> _$$SHOCartItemImplToJson(_$SHOCartItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'title': instance.title,
      'imageUrl': instance.imageUrl,
      'price': instance.price,
      'quantity': instance.quantity,
      'variantLabel': instance.variantLabel,
      'selected': instance.selected,
      'unavailable': instance.unavailable,
      'priceChanged': instance.priceChanged,
      'stock': instance.stock,
      'listPrice': instance.listPrice,
      'sessionId': instance.sessionId,
      'sessionEndAt': instance.sessionEndAt,
    };

_$SHOCartSnapshotImpl _$$SHOCartSnapshotImplFromJson(
  Map<String, dynamic> json,
) => _$SHOCartSnapshotImpl(
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => SHOCartItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SHOCartItem>[],
);

Map<String, dynamic> _$$SHOCartSnapshotImplToJson(
  _$SHOCartSnapshotImpl instance,
) => <String, dynamic>{'items': instance.items};
