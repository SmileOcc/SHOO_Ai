import 'package:freezed_annotation/freezed_annotation.dart';

import 'hos_flash_sale_enums.dart';

part 'hos_flash_sale_coupon.freezed.dart';
part 'hos_flash_sale_coupon.g.dart';

@freezed
class SHOFlashSaleCoupon with _$SHOFlashSaleCoupon {
  const factory SHOFlashSaleCoupon({
    required String id,
    required String title,
    required String description,
    @Default(SHOFlashSaleCouponStatus.notStarted)
    SHOFlashSaleCouponStatus status,
  }) = _SHOFlashSaleCoupon;

  factory SHOFlashSaleCoupon.fromJson(Map<String, dynamic> json) =>
      _$SHOFlashSaleCouponFromJson(json);
}
