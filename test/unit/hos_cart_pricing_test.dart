import 'package:flutter_test/flutter_test.dart';
import 'package:shoo/core/pricing/hos_full_reduction.dart';
import 'package:shoo/features/cart/domain/entities/hos_cart.dart';
import 'package:shoo/features/cart/domain/hos_cart_pricing.dart';
import 'package:shoo/features/coupon/domain/entities/hos_coupon.dart';

void main() {
  const items = [
    SHOCartItem(
      id: 'p1',
      productId: 'p1',
      title: 'Demo',
      imageUrl: 'https://example.com/p.jpg',
      price: 4200,
      quantity: 2,
      listPrice: 5000,
    ),
    SHOCartItem(
      id: 'p2',
      productId: 'p2',
      title: 'Demo 2',
      imageUrl: 'https://example.com/p2.jpg',
      price: 2500,
      quantity: 1,
    ),
  ];

  group('SHOCartPricing.previewForSelectedItems', () {
    test('cart footer and checkout preview match after sync', () {
      const coupon = SHOCoupon(
        id: 'c1',
        title: 'Spring',
        type: SHOCouponType.fixed,
        discountCents: 1000,
        minOrderCents: 5000,
        expiresAt: '2026-12-31',
      );

      final cartPreview = SHOCartPricing.previewForSelectedItems(
        items: items,
        coupon: coupon,
      );

      final activityLines = {
        'p1': const SHOCheckoutActivityLine(
          productId: 'p1',
          sessionId: 's1',
          unitPriceCents: 4200,
          originalUnitPriceCents: 5000,
        ),
      };

      final checkoutPreview = SHOCartPricing.previewForSelectedItems(
        items: items,
        activityLines: activityLines,
        coupon: coupon,
      );

      expect(checkoutPreview.subtotalCents, cartPreview.subtotalCents);
      expect(checkoutPreview.discountCents, cartPreview.discountCents);
      expect(checkoutPreview.fullReductionCents, cartPreview.fullReductionCents);
      expect(checkoutPreview.shippingCents, cartPreview.shippingCents);
      expect(checkoutPreview.totalCents, cartPreview.totalCents);
    });

    test('includes platform full reduction and free shipping at threshold', () {
      final preview = SHOCartPricing.previewForSelectedItems(items: items);

      expect(preview.subtotalCents, 10900);
      expect(preview.fullReductionCents, 1500);
      expect(preview.shippingCents, 0);
      expect(preview.totalCents, 9400);
    });

    test('adds shipping when subtotal below free shipping threshold', () {
      const smallItems = [
        SHOCartItem(
          id: 'p3',
          productId: 'p3',
          title: 'Small',
          imageUrl: 'https://example.com/p3.jpg',
          price: 2000,
          quantity: 1,
        ),
      ];

      final preview = SHOCartPricing.previewForSelectedItems(items: smallItems);

      expect(preview.shippingCents, SHOCartPricing.defaultShippingCents);
      expect(
        preview.totalCents,
        preview.subtotalCents - preview.fullReductionCents + preview.shippingCents,
      );
    });
  });
}
