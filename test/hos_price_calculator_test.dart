import 'package:flutter_test/flutter_test.dart';
import 'package:shoo/core/pricing/hos_price_calculator.dart';
import 'package:shoo/features/coupon/domain/hos_coupon.dart';

void main() {
  const fixedCoupon = SHOCoupon(
    id: 'c1',
    title: 'Fixed',
    type: SHOCouponType.fixed,
    discountCents: 500,
    minOrderCents: 2000,
    expiresAt: '2026-12-31',
  );

  const percentCoupon = SHOCoupon(
    id: 'c2',
    title: 'Percent',
    type: SHOCouponType.percent,
    discountPercent: 15,
    minOrderCents: 3000,
    expiresAt: '2026-12-31',
  );

  test('fixed coupon discount applies when eligible', () {
    expect(
      SHOPriceCalculator.calculateCouponDiscount(
        subtotalCents: 2500,
        coupon: fixedCoupon,
      ),
      500,
    );
  });

  test('fixed coupon rejected below minimum', () {
    expect(
      SHOPriceCalculator.couponIneligibleReason(
        subtotalCents: 1500,
        coupon: fixedCoupon,
      ),
      'min_order',
    );
    expect(
      SHOPriceCalculator.calculateCouponDiscount(
        subtotalCents: 1500,
        coupon: fixedCoupon,
      ),
      0,
    );
  });

  test('percent coupon calculates correctly', () {
    expect(
      SHOPriceCalculator.calculateCouponDiscount(
        subtotalCents: 4000,
        coupon: percentCoupon,
      ),
      600,
    );
  });

  test('order price breakdown with coupon', () {
    final breakdown = SHOPriceCalculator.calculateOrderPrice(
      subtotalCents: 4000,
      coupon: percentCoupon,
    );
    expect(breakdown.subtotalCents, 4000);
    expect(breakdown.discountCents, 600);
    expect(breakdown.totalCents, 3400);
    expect(breakdown.couponApplied, isTrue);
  });

  test('discount never exceeds subtotal', () {
    const bigFixed = SHOCoupon(
      id: 'c3',
      title: 'Big',
      type: SHOCouponType.fixed,
      discountCents: 9999,
      expiresAt: '2026-12-31',
    );
    expect(
      SHOPriceCalculator.calculateCouponDiscount(
        subtotalCents: 1000,
        coupon: bigFixed,
      ),
      1000,
    );
  });
}
