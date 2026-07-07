import 'package:freezed_annotation/freezed_annotation.dart';

import 'hos_flash_sale_calendar.dart';
import 'hos_flash_sale_coupon.dart';
import 'hos_flash_sale_enums.dart';
import 'hos_flash_sale_product.dart';
import 'hos_flash_sale_promo.dart';

part 'hos_flash_sale_page.freezed.dart';
part 'hos_flash_sale_page.g.dart';

@freezed
class SHOFlashSalePageData with _$SHOFlashSalePageData {
  const factory SHOFlashSalePageData({
    required String serverTime,
    required String date,
    required String sessionId,
    required SHOFlashSaleClaimPhase claimPhase,
    String? claimCountdownTarget,
    @Default([]) List<SHOFlashSaleSession> sessions,
    @Default([]) List<SHOFlashSalePromoEntry> promoEntries,
    @Default([]) List<SHOFlashSaleCoupon> coupons,
    @Default([]) List<SHOFlashSaleProduct> products,
    @Default(1) int page,
    @Default(10) int pageSize,
    @Default(0) int total,
    @Default(false) bool hasMore,
  }) = _SHOFlashSalePageData;

  factory SHOFlashSalePageData.fromJson(Map<String, dynamic> json) =>
      _$SHOFlashSalePageDataFromJson(json);
}