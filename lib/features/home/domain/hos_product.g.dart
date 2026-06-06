// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hos_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SHOProductImpl _$$SHOProductImplFromJson(Map<String, dynamic> json) =>
    _$SHOProductImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      price: (json['price'] as num).toInt(),
      originalPrice: (json['originalPrice'] as num).toInt(),
      discountLabel: json['discountLabel'] as String? ?? '',
      rating: (json['rating'] as num).toDouble(),
      soldCount: (json['soldCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$SHOProductImplToJson(_$SHOProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'imageUrl': instance.imageUrl,
      'price': instance.price,
      'originalPrice': instance.originalPrice,
      'discountLabel': instance.discountLabel,
      'rating': instance.rating,
      'soldCount': instance.soldCount,
    };
