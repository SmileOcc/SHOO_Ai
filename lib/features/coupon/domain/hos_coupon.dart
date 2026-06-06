import 'package:freezed_annotation/freezed_annotation.dart';

part 'hos_coupon.freezed.dart';
part 'hos_coupon.g.dart';

enum SHOCouponType {
  @JsonValue('fixed')
  fixed,
  @JsonValue('percent')
  percent,
}

@freezed
class SHOCoupon with _$SHOCoupon {
  const factory SHOCoupon({
    required String id,
    required String title,
    @Default('') String description,
    required SHOCouponType type,
    @Default(0) int discountCents,
    @Default(0) int discountPercent,
    @Default(0) int minOrderCents,
    required String expiresAt,
    @Default(true) bool isAvailable,
  }) = _SHOCoupon;

  factory SHOCoupon.fromJson(Map<String, dynamic> json) =>
      _$SHOCouponFromJson(json);
}
