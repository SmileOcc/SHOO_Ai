// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hos_flash_sale_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SHOFlashSalePromoTagImpl _$$SHOFlashSalePromoTagImplFromJson(
  Map<String, dynamic> json,
) => _$SHOFlashSalePromoTagImpl(
  type: json['type'] as String,
  label: json['label'] as String,
  enabled: json['enabled'] as bool? ?? true,
);

Map<String, dynamic> _$$SHOFlashSalePromoTagImplToJson(
  _$SHOFlashSalePromoTagImpl instance,
) => <String, dynamic>{
  'type': instance.type,
  'label': instance.label,
  'enabled': instance.enabled,
};

_$SHOFlashSaleCalendarImpl _$$SHOFlashSaleCalendarImplFromJson(
  Map<String, dynamic> json,
) => _$SHOFlashSaleCalendarImpl(
  serverTime: json['serverTime'] as String,
  days: (json['days'] as List<dynamic>)
      .map((e) => SHOFlashSaleDay.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$SHOFlashSaleCalendarImplToJson(
  _$SHOFlashSaleCalendarImpl instance,
) => <String, dynamic>{
  'serverTime': instance.serverTime,
  'days': instance.days,
};

_$SHOFlashSaleDayImpl _$$SHOFlashSaleDayImplFromJson(
  Map<String, dynamic> json,
) => _$SHOFlashSaleDayImpl(
  date: json['date'] as String,
  label: json['label'] as String,
  weekday: json['weekday'] as String,
  status:
      $enumDecodeNullable(_$SHOFlashSaleDayStatusEnumMap, json['status']) ??
      SHOFlashSaleDayStatus.notStarted,
  sessionCount: (json['sessionCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$SHOFlashSaleDayImplToJson(
  _$SHOFlashSaleDayImpl instance,
) => <String, dynamic>{
  'date': instance.date,
  'label': instance.label,
  'weekday': instance.weekday,
  'status': _$SHOFlashSaleDayStatusEnumMap[instance.status]!,
  'sessionCount': instance.sessionCount,
};

const _$SHOFlashSaleDayStatusEnumMap = {
  SHOFlashSaleDayStatus.notStarted: 'not_started',
  SHOFlashSaleDayStatus.ongoing: 'ongoing',
  SHOFlashSaleDayStatus.ending: 'ending',
  SHOFlashSaleDayStatus.ended: 'ended',
};

_$SHOFlashSaleSessionImpl _$$SHOFlashSaleSessionImplFromJson(
  Map<String, dynamic> json,
) => _$SHOFlashSaleSessionImpl(
  id: json['id'] as String,
  label: json['label'] as String,
  startAt: json['startAt'] as String,
  endAt: json['endAt'] as String,
  claimStartAt: json['claimStartAt'] as String,
  claimEndAt: json['claimEndAt'] as String,
  status:
      $enumDecodeNullable(_$SHOFlashSaleDayStatusEnumMap, json['status']) ??
      SHOFlashSaleDayStatus.notStarted,
);

Map<String, dynamic> _$$SHOFlashSaleSessionImplToJson(
  _$SHOFlashSaleSessionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'startAt': instance.startAt,
  'endAt': instance.endAt,
  'claimStartAt': instance.claimStartAt,
  'claimEndAt': instance.claimEndAt,
  'status': _$SHOFlashSaleDayStatusEnumMap[instance.status]!,
};

_$SHOFlashSalePromoEntryImpl _$$SHOFlashSalePromoEntryImplFromJson(
  Map<String, dynamic> json,
) => _$SHOFlashSalePromoEntryImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  iconUrl: json['iconUrl'] as String,
  deeplink: json['deeplink'] as String,
);

Map<String, dynamic> _$$SHOFlashSalePromoEntryImplToJson(
  _$SHOFlashSalePromoEntryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'iconUrl': instance.iconUrl,
  'deeplink': instance.deeplink,
};

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
