// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hos_coupon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SHOCouponImpl _$$SHOCouponImplFromJson(Map<String, dynamic> json) =>
    _$SHOCouponImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      type: $enumDecode(_$SHOCouponTypeEnumMap, json['type']),
      discountCents: (json['discountCents'] as num?)?.toInt() ?? 0,
      discountPercent: (json['discountPercent'] as num?)?.toInt() ?? 0,
      minOrderCents: (json['minOrderCents'] as num?)?.toInt() ?? 0,
      expiresAt: json['expiresAt'] as String,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );

Map<String, dynamic> _$$SHOCouponImplToJson(_$SHOCouponImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$SHOCouponTypeEnumMap[instance.type]!,
      'discountCents': instance.discountCents,
      'discountPercent': instance.discountPercent,
      'minOrderCents': instance.minOrderCents,
      'expiresAt': instance.expiresAt,
      'isAvailable': instance.isAvailable,
    };

const _$SHOCouponTypeEnumMap = {
  SHOCouponType.fixed: 'fixed',
  SHOCouponType.percent: 'percent',
};
