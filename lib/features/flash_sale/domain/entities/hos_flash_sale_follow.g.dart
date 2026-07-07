// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hos_flash_sale_follow.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SHOFlashSaleFollowImpl _$$SHOFlashSaleFollowImplFromJson(
  Map<String, dynamic> json,
) => _$SHOFlashSaleFollowImpl(
  id: json['id'] as String,
  sessionId: json['sessionId'] as String,
  productId: json['productId'] as String,
  title: json['title'] as String,
  imageUrl: json['imageUrl'] as String,
  sessionStartAt: json['sessionStartAt'] as String,
  status:
      $enumDecodeNullable(_$SHOFlashSaleProductStatusEnumMap, json['status']) ??
      SHOFlashSaleProductStatus.notStarted,
);

Map<String, dynamic> _$$SHOFlashSaleFollowImplToJson(
  _$SHOFlashSaleFollowImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'sessionId': instance.sessionId,
  'productId': instance.productId,
  'title': instance.title,
  'imageUrl': instance.imageUrl,
  'sessionStartAt': instance.sessionStartAt,
  'status': _$SHOFlashSaleProductStatusEnumMap[instance.status]!,
};

const _$SHOFlashSaleProductStatusEnumMap = {
  SHOFlashSaleProductStatus.notStarted: 'not_started',
  SHOFlashSaleProductStatus.ongoing: 'ongoing',
  SHOFlashSaleProductStatus.ended: 'ended',
  SHOFlashSaleProductStatus.soldOut: 'sold_out',
};
