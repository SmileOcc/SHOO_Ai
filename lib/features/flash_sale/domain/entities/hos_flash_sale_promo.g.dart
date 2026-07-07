// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hos_flash_sale_promo.dart';

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
