// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hos_flash_sale_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SHOFlashSaleProductImpl _$$SHOFlashSaleProductImplFromJson(
  Map<String, dynamic> json,
) => _$SHOFlashSaleProductImpl(
  id: json['id'] as String,
  sessionId: json['sessionId'] as String,
  title: json['title'] as String,
  imageUrl: json['imageUrl'] as String,
  originalPrice: (json['originalPrice'] as num).toInt(),
  activityPrice: (json['activityPrice'] as num).toInt(),
  skuAttributes:
      (json['skuAttributes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  promoTags:
      (json['promoTags'] as List<dynamic>?)
          ?.map((e) => SHOFlashSalePromoTag.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  primaryPromoType: json['primaryPromoType'] as String?,
  primaryPromoLabel: json['primaryPromoLabel'] as String?,
  status:
      $enumDecodeNullable(_$SHOFlashSaleProductStatusEnumMap, json['status']) ??
      SHOFlashSaleProductStatus.notStarted,
  stock: (json['stock'] as num?)?.toInt() ?? 0,
  soldCount: (json['soldCount'] as num?)?.toInt() ?? 0,
  isFollowed: json['isFollowed'] as bool? ?? false,
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$$SHOFlashSaleProductImplToJson(
  _$SHOFlashSaleProductImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'sessionId': instance.sessionId,
  'title': instance.title,
  'imageUrl': instance.imageUrl,
  'originalPrice': instance.originalPrice,
  'activityPrice': instance.activityPrice,
  'skuAttributes': instance.skuAttributes,
  'promoTags': instance.promoTags,
  'primaryPromoType': instance.primaryPromoType,
  'primaryPromoLabel': instance.primaryPromoLabel,
  'status': _$SHOFlashSaleProductStatusEnumMap[instance.status]!,
  'stock': instance.stock,
  'soldCount': instance.soldCount,
  'isFollowed': instance.isFollowed,
  'createdAt': instance.createdAt,
};

const _$SHOFlashSaleProductStatusEnumMap = {
  SHOFlashSaleProductStatus.notStarted: 'not_started',
  SHOFlashSaleProductStatus.ongoing: 'ongoing',
  SHOFlashSaleProductStatus.ended: 'ended',
  SHOFlashSaleProductStatus.soldOut: 'sold_out',
};

_$SHOFlashSaleProductActivityImpl _$$SHOFlashSaleProductActivityImplFromJson(
  Map<String, dynamic> json,
) => _$SHOFlashSaleProductActivityImpl(
  sessionId: json['sessionId'] as String,
  status: $enumDecode(_$SHOFlashSaleProductStatusEnumMap, json['status']),
  originalPrice: (json['originalPrice'] as num).toInt(),
  activityPrice: (json['activityPrice'] as num).toInt(),
  promoTags:
      (json['promoTags'] as List<dynamic>?)
          ?.map((e) => SHOFlashSalePromoTag.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  primaryPromoType: json['primaryPromoType'] as String?,
  primaryPromoLabel: json['primaryPromoLabel'] as String?,
  sessionStartAt: json['sessionStartAt'] as String?,
  sessionEndAt: json['sessionEndAt'] as String?,
  overlayLabel: json['overlayLabel'] as String?,
  isFollowed: json['isFollowed'] as bool? ?? false,
  stock: (json['stock'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$SHOFlashSaleProductActivityImplToJson(
  _$SHOFlashSaleProductActivityImpl instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'status': _$SHOFlashSaleProductStatusEnumMap[instance.status]!,
  'originalPrice': instance.originalPrice,
  'activityPrice': instance.activityPrice,
  'promoTags': instance.promoTags,
  'primaryPromoType': instance.primaryPromoType,
  'primaryPromoLabel': instance.primaryPromoLabel,
  'sessionStartAt': instance.sessionStartAt,
  'sessionEndAt': instance.sessionEndAt,
  'overlayLabel': instance.overlayLabel,
  'isFollowed': instance.isFollowed,
  'stock': instance.stock,
};
