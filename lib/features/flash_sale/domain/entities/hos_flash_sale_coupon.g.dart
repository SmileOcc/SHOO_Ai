// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hos_flash_sale_coupon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SHOFlashSaleCouponImpl _$$SHOFlashSaleCouponImplFromJson(
  Map<String, dynamic> json,
) => _$SHOFlashSaleCouponImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  status:
      $enumDecodeNullable(_$SHOFlashSaleCouponStatusEnumMap, json['status']) ??
      SHOFlashSaleCouponStatus.notStarted,
);

Map<String, dynamic> _$$SHOFlashSaleCouponImplToJson(
  _$SHOFlashSaleCouponImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'status': _$SHOFlashSaleCouponStatusEnumMap[instance.status]!,
};

const _$SHOFlashSaleCouponStatusEnumMap = {
  SHOFlashSaleCouponStatus.notStarted: 'not_started',
  SHOFlashSaleCouponStatus.claimable: 'claimable',
  SHOFlashSaleCouponStatus.claimed: 'claimed',
  SHOFlashSaleCouponStatus.soldOut: 'sold_out',
  SHOFlashSaleCouponStatus.expired: 'expired',
};
