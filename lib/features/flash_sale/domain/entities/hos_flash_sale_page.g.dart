// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hos_flash_sale_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SHOFlashSalePageDataImpl _$$SHOFlashSalePageDataImplFromJson(
  Map<String, dynamic> json,
) => _$SHOFlashSalePageDataImpl(
  serverTime: json['serverTime'] as String,
  date: json['date'] as String,
  sessionId: json['sessionId'] as String,
  claimPhase: $enumDecode(_$SHOFlashSaleClaimPhaseEnumMap, json['claimPhase']),
  claimCountdownTarget: json['claimCountdownTarget'] as String?,
  sessions:
      (json['sessions'] as List<dynamic>?)
          ?.map((e) => SHOFlashSaleSession.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  promoEntries:
      (json['promoEntries'] as List<dynamic>?)
          ?.map(
            (e) => SHOFlashSalePromoEntry.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  coupons:
      (json['coupons'] as List<dynamic>?)
          ?.map((e) => SHOFlashSaleCoupon.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  products:
      (json['products'] as List<dynamic>?)
          ?.map((e) => SHOFlashSaleProduct.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  page: (json['page'] as num?)?.toInt() ?? 1,
  pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
  total: (json['total'] as num?)?.toInt() ?? 0,
  hasMore: json['hasMore'] as bool? ?? false,
);

Map<String, dynamic> _$$SHOFlashSalePageDataImplToJson(
  _$SHOFlashSalePageDataImpl instance,
) => <String, dynamic>{
  'serverTime': instance.serverTime,
  'date': instance.date,
  'sessionId': instance.sessionId,
  'claimPhase': _$SHOFlashSaleClaimPhaseEnumMap[instance.claimPhase]!,
  'claimCountdownTarget': instance.claimCountdownTarget,
  'sessions': instance.sessions,
  'promoEntries': instance.promoEntries,
  'coupons': instance.coupons,
  'products': instance.products,
  'page': instance.page,
  'pageSize': instance.pageSize,
  'total': instance.total,
  'hasMore': instance.hasMore,
};

const _$SHOFlashSaleClaimPhaseEnumMap = {
  SHOFlashSaleClaimPhase.beforeClaim: 'before_claim',
  SHOFlashSaleClaimPhase.claiming: 'claiming',
  SHOFlashSaleClaimPhase.afterClaim: 'after_claim',
};
