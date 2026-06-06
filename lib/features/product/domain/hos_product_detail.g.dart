// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hos_product_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SHOProductDetailImpl _$$SHOProductDetailImplFromJson(
  Map<String, dynamic> json,
) => _$SHOProductDetailImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  imageUrl: json['imageUrl'] as String,
  images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
  price: (json['price'] as num).toInt(),
  originalPrice: (json['originalPrice'] as num).toInt(),
  discountLabel: json['discountLabel'] as String? ?? '',
  rating: (json['rating'] as num).toDouble(),
  soldCount: (json['soldCount'] as num?)?.toInt() ?? 0,
  description: json['description'] as String? ?? '',
  reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$SHOProductDetailImplToJson(
  _$SHOProductDetailImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'imageUrl': instance.imageUrl,
  'images': instance.images,
  'price': instance.price,
  'originalPrice': instance.originalPrice,
  'discountLabel': instance.discountLabel,
  'rating': instance.rating,
  'soldCount': instance.soldCount,
  'description': instance.description,
  'reviewCount': instance.reviewCount,
};
