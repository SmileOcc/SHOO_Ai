import 'package:shoo/core/pricing/hos_full_reduction.dart';
import 'package:shoo/core/pricing/hos_price_calculator.dart';
import 'package:shoo/features/coupon/domain/entities/hos_coupon.dart';

/// 购物袋价格预览（券 + 满减 + 运费）。
abstract final class SHOCartPricing {
  /// 未满包邮时的基础运费（分）。
  static const defaultShippingCents = 800;

  /// 满此金额免运费。
  static const freeShippingThresholdCents = 5000;

  /// 平台通用满减阶梯（Mock）。
  static const defaultFullReductionTiers = <SHOFullReductionTier>[
    SHOFullReductionTier(
      minOrderCents: 3000,
      reductionCents: 300,
      label: '满 \$30 减 \$3',
    ),
    SHOFullReductionTier(
      minOrderCents: 5000,
      reductionCents: 600,
      label: '满 \$50 减 \$6',
    ),
    SHOFullReductionTier(
      minOrderCents: 10000,
      reductionCents: 1500,
      label: '满 \$100 减 \$15',
    ),
  ];

  static int shippingCentsFor(int merchandiseSubtotalCents) {
    if (merchandiseSubtotalCents <= 0) return 0;
    if (merchandiseSubtotalCents >= freeShippingThresholdCents) return 0;
    return defaultShippingCents;
  }

  static int freeShippingGapCents(int merchandiseSubtotalCents) {
    if (merchandiseSubtotalCents >= freeShippingThresholdCents) return 0;
    return freeShippingThresholdCents - merchandiseSubtotalCents;
  }

  /// 在可用券中选「抵扣最多」的一张（预估用）。
  static SHOCoupon? bestCouponFor({
    required int subtotalCents,
    required List<SHOCoupon> coupons,
  }) {
    SHOCoupon? best;
    var bestDiscount = 0;
    for (final coupon in coupons) {
      final discount = SHOPriceCalculator.calculateCouponDiscount(
        subtotalCents: subtotalCents,
        coupon: coupon,
      );
      if (discount > bestDiscount) {
        bestDiscount = discount;
        best = coupon;
      }
    }
    return best;
  }

  static SHOPriceBreakdown preview({
    required int subtotalCents,
    SHOCoupon? selectedCoupon,
    List<SHOCoupon> coupons = const [],
    List<SHOFullReductionTier> tiers = defaultFullReductionTiers,
    int? shippingCents,
    int activitySavedCents = 0,
  }) {
    final coupon =
        selectedCoupon ??
        bestCouponFor(subtotalCents: subtotalCents, coupons: coupons);
    return SHOPriceCalculator.calculateOrderPrice(
      subtotalCents: subtotalCents,
      coupon: coupon,
      fullReductionTiers: tiers,
      shippingCents: shippingCents ?? shippingCentsFor(subtotalCents),
      activitySavedCents: activitySavedCents,
    );
  }

  /// 下一档满减「还差多少」。
  static SHOFullReductionTier? nextTierAfter({
    required int subtotalCents,
    List<SHOFullReductionTier> tiers = defaultFullReductionTiers,
  }) {
    final sorted = [...tiers]
      ..sort((a, b) => a.minOrderCents.compareTo(b.minOrderCents));
    for (final tier in sorted) {
      if (subtotalCents < tier.minOrderCents) return tier;
    }
    return null;
  }
}
