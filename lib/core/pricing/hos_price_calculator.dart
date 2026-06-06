import '../../features/coupon/domain/hos_coupon.dart';

/// 订单价格明细（纯数据，无副作用）。
class SHOPriceBreakdown {
  const SHOPriceBreakdown({
    required this.subtotalCents,
    required this.discountCents,
    required this.shippingCents,
    required this.totalCents,
    this.couponApplied = false,
    this.couponIneligibleReason,
  });

  final int subtotalCents;
  final int discountCents;
  final int shippingCents;
  final int totalCents;
  final bool couponApplied;
  final String? couponIneligibleReason;
}

/// 价格计算纯函数 — 结算页 / 优惠券校验共用。
abstract final class SHOPriceCalculator {
  static const int defaultShippingCents = 0;

  /// 判断优惠券是否可用于当前小计。
  static String? couponIneligibleReason({
    required int subtotalCents,
    required SHOCoupon coupon,
  }) {
    if (!coupon.isAvailable) return 'unavailable';
    if (subtotalCents < coupon.minOrderCents) return 'min_order';
    return null;
  }

  /// 计算优惠券抵扣金额（分），不超过小计。
  static int calculateCouponDiscount({
    required int subtotalCents,
    required SHOCoupon coupon,
  }) {
    if (couponIneligibleReason(subtotalCents: subtotalCents, coupon: coupon) !=
        null) {
      return 0;
    }

    final discount = switch (coupon.type) {
      SHOCouponType.fixed => coupon.discountCents,
      SHOCouponType.percent => (subtotalCents * coupon.discountPercent / 100).round(),
    };

    return discount.clamp(0, subtotalCents);
  }

  /// 计算完整订单价格明细。
  static SHOPriceBreakdown calculateOrderPrice({
    required int subtotalCents,
    SHOCoupon? coupon,
    int shippingCents = defaultShippingCents,
  }) {
    var discountCents = 0;
    String? ineligible;
    var applied = false;

    if (coupon != null) {
      ineligible = couponIneligibleReason(
        subtotalCents: subtotalCents,
        coupon: coupon,
      );
      if (ineligible == null) {
        discountCents = calculateCouponDiscount(
          subtotalCents: subtotalCents,
          coupon: coupon,
        );
        applied = discountCents > 0;
      }
    }

    final total = (subtotalCents - discountCents + shippingCents).clamp(0, 1 << 31);

    return SHOPriceBreakdown(
      subtotalCents: subtotalCents,
      discountCents: discountCents,
      shippingCents: shippingCents,
      totalCents: total,
      couponApplied: applied,
      couponIneligibleReason: ineligible,
    );
  }
}
