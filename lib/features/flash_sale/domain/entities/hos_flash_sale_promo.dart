import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoo/core/widgets/hos_promo_badge.dart';

part 'hos_flash_sale_promo.freezed.dart';
part 'hos_flash_sale_promo.g.dart';

@freezed
class SHOFlashSalePromoTag with _$SHOFlashSalePromoTag {
  const SHOFlashSalePromoTag._();

  const factory SHOFlashSalePromoTag({
    required String type,
    required String label,
    @Default(true) bool enabled,
  }) = _SHOFlashSalePromoTag;

  factory SHOFlashSalePromoTag.fromJson(Map<String, dynamic> json) =>
      _$SHOFlashSalePromoTagFromJson(json);

  SHOPromoBadgeTagData toBadgeData() => SHOPromoBadgeTagData(
    type: SHOPromoBadgeTypeX.fromApi(type),
    label: label,
    enabled: enabled,
  );
}

@freezed
class SHOFlashSalePromoEntry with _$SHOFlashSalePromoEntry {
  const factory SHOFlashSalePromoEntry({
    required String id,
    required String title,
    required String iconUrl,
    required String deeplink,
  }) = _SHOFlashSalePromoEntry;

  factory SHOFlashSalePromoEntry.fromJson(Map<String, dynamic> json) =>
      _$SHOFlashSalePromoEntryFromJson(json);
}
