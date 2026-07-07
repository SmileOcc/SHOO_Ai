import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoo/core/widgets/hos_promo_badge.dart';

import 'hos_flash_sale_enums.dart';
import 'hos_flash_sale_promo.dart';

part 'hos_flash_sale_product.freezed.dart';
part 'hos_flash_sale_product.g.dart';

@freezed
class SHOFlashSaleProduct with _$SHOFlashSaleProduct {
  const SHOFlashSaleProduct._();

  const factory SHOFlashSaleProduct({
    required String id,
    required String sessionId,
    required String title,
    required String imageUrl,
    required int originalPrice,
    required int activityPrice,
    @Default([]) List<String> skuAttributes,
    @Default([]) List<SHOFlashSalePromoTag> promoTags,
    String? primaryPromoType,
    String? primaryPromoLabel,
    @Default(SHOFlashSaleProductStatus.notStarted)
    SHOFlashSaleProductStatus status,
    @Default(0) int stock,
    @Default(0) int soldCount,
    @Default(false) bool isFollowed,
    String? createdAt,
  }) = _SHOFlashSaleProduct;

  factory SHOFlashSaleProduct.fromJson(Map<String, dynamic> json) =>
      _$SHOFlashSaleProductFromJson(json);

  SHOPromoBadgeType? get primaryBadgeType => primaryPromoType != null
      ? SHOPromoBadgeTypeX.fromApi(primaryPromoType)
      : null;

  List<SHOPromoBadgeTagData> get badgeTags =>
      promoTags.map((t) => t.toBadgeData()).toList();

  int get displayPrice {
    if (status == SHOFlashSaleProductStatus.ongoing && stock > 0) {
      return activityPrice;
    }
    return originalPrice;
  }

  bool get canPurchase =>
      status == SHOFlashSaleProductStatus.ongoing && stock > 0;

  bool get canFollow => status == SHOFlashSaleProductStatus.notStarted;
}

@freezed
class SHOFlashSaleProductActivity with _$SHOFlashSaleProductActivity {
  const SHOFlashSaleProductActivity._();

  const factory SHOFlashSaleProductActivity({
    required String sessionId,
    required SHOFlashSaleProductStatus status,
    required int originalPrice,
    required int activityPrice,
    @Default([]) List<SHOFlashSalePromoTag> promoTags,
    String? primaryPromoType,
    String? primaryPromoLabel,
    String? sessionStartAt,
    String? sessionEndAt,
    String? overlayLabel,
    @Default(false) bool isFollowed,
    @Default(0) int stock,
  }) = _SHOFlashSaleProductActivity;

  factory SHOFlashSaleProductActivity.fromJson(Map<String, dynamic> json) =>
      _$SHOFlashSaleProductActivityFromJson(json);

  SHOPromoBadgeType? get primaryBadgeType => primaryPromoType != null
      ? SHOPromoBadgeTypeX.fromApi(primaryPromoType)
      : null;

  int get displayPrice {
    if (status == SHOFlashSaleProductStatus.ongoing && stock > 0) {
      return activityPrice;
    }
    return originalPrice;
  }

  bool get showActivityPrice =>
      status == SHOFlashSaleProductStatus.ongoing && stock > 0;
}
