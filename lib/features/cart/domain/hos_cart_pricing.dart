import 'package:shoo/core/pricing/hos_full_reduction.dart';
import 'package:shoo/core/pricing/hos_price_calculator.dart';
import 'package:shoo/features/cart/domain/entities/hos_cart.dart';
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

  /// 勾选商品小计（分）。
  static int subtotalCentsFor({
    required List<SHOCartItem> items,
    Map<String, SHOCheckoutActivityLine> activityLines = const {},
  }) {
    var total = 0;
    for (final item in items) {
      final line = activityLines[item.productId];
      final unit = line?.unitPriceCents ?? item.effectiveUnitCents;
      total += unit * item.quantity;
    }
    return total;
  }

  /// 活动已省金额（展示用，不参与 total 扣减）。
  static int activitySavedCentsFor({
    required List<SHOCartItem> items,
    Map<String, SHOCheckoutActivityLine> activityLines = const {},
  }) {
    var saved = 0;
    for (final item in items) {
      final line = activityLines[item.productId];
      if (line != null) {
        if (line.originalUnitPriceCents <= line.unitPriceCents) continue;
        saved +=
            (line.originalUnitPriceCents - line.unitPriceCents) * item.quantity;
        continue;
      }
      if (item.showStrikeListPrice) {
        saved += (item.listPrice - item.effectiveUnitCents) * item.quantity;
      }
    }
    return saved;
  }

  /// 平台满减 + 活动附带的满减阶梯。
  static List<SHOFullReductionTier> fullReductionTiersFor({
    Map<String, SHOCheckoutActivityLine> activityLines = const {},
  }) {
    return [
      ...defaultFullReductionTiers,
      ...collectActivityFullReductionTiers(activityLines),
    ];
  }

  /// 购物车 / 结算页共用的价格预览（券仅在实际选中时生效）。
  static SHOPriceBreakdown previewForSelectedItems({
    required List<SHOCartItem> items,
    Map<String, SHOCheckoutActivityLine> activityLines = const {},
    SHOCoupon? coupon,
  }) {
    final subtotal = subtotalCentsFor(
      items: items,
      activityLines: activityLines,
    );
    return SHOPriceCalculator.calculateOrderPrice(
      subtotalCents: subtotal,
      coupon: coupon,
      fullReductionTiers: fullReductionTiersFor(activityLines: activityLines),
      shippingCents: shippingCentsFor(subtotal),
      activitySavedCents: activitySavedCentsFor(
        items: items,
        activityLines: activityLines,
      ),
    );
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

  /// 当前订单金额下可用的优惠券（抵扣 > 0）。
  static List<SHOCoupon> eligibleCouponsFor({
    required int subtotalCents,
    required List<SHOCoupon> coupons,
  }) {
    return coupons
        .where(
          (coupon) =>
              SHOPriceCalculator.calculateCouponDiscount(
                subtotalCents: subtotalCents,
                coupon: coupon,
              ) >
              0,
        )
        .toList(growable: false);
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
