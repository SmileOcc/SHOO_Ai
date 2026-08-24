import 'package:flutter_test/flutter_test.dart';
import 'package:shoo/core/pricing/hos_full_reduction.dart';
import 'package:shoo/features/cart/domain/entities/hos_cart.dart';
import 'package:shoo/features/checkout/domain/hos_checkout_order_payload.dart';

void main() {
  group('SHOCheckoutOrderPayload', () {
    test('maps cart item to API create-order fields', () {
      const item = SHOCartItem(
        id: 'p1::M',
        productId: 'p1',
        title: 'Demo Tee',
        imageUrl: 'https://example.com/tee.jpg',
        price: 1299,
        quantity: 2,
        variantLabel: 'M',
        listPrice: 1599,
      );

      final payload = SHOCheckoutOrderPayload.itemFromCart(item: item);

      expect(payload['productId'], 'p1');
      expect(payload['title'], 'Demo Tee');
      expect(payload['imageUrl'], 'https://example.com/tee.jpg');
      expect(payload['price'], 1299);
      expect(payload['quantity'], 2);
      expect(payload['variantLabel'], 'M');
      expect(payload.containsKey('sessionId'), isFalse);
      expect(payload.containsKey('unitPriceCents'), isFalse);
    });

    test('uses activity unit price when present', () {
      const item = SHOCartItem(
        id: 'p1',
        productId: 'p1',
        title: 'Flash',
        imageUrl: 'https://example.com/flash.jpg',
        price: 2000,
        quantity: 1,
        sessionId: 's1',
      );
      const line = SHOCheckoutActivityLine(
        productId: 'p1',
        sessionId: 's1',
        unitPriceCents: 999,
        originalUnitPriceCents: 2000,
      );

      final payload = SHOCheckoutOrderPayload.itemFromCart(
        item: item,
        activityLine: line,
      );

      expect(payload['price'], 999);
    });
  });
}
