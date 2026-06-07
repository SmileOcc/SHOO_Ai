import 'package:flutter_test/flutter_test.dart';
import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/features/address/domain/hos_address.dart';
import 'package:shoo/features/cart/domain/hos_cart.dart';
import 'package:shoo/features/checkout/domain/hos_payment_result.dart';

void main() {
  group('Phase 1 routes', () {
    test('checkout payment and address routes', () {
      expect(SHOAppRoutes.checkout, '/checkout');
      expect(SHOAppRoutes.payment('o-new'), '/payment/o-new');
      expect(SHOAppRoutes.addresses, '/addresses');
    });
  });

  group('Phase 1 cart snapshot', () {
    test('computes selected totals', () {
      const snapshot = SHOCartSnapshot(
        items: [
          SHOCartItem(
            id: '1',
            productId: 'p1',
            title: 'Top',
            imageUrl: 'url',
            price: 1000,
            quantity: 2,
            selected: true,
          ),
          SHOCartItem(
            id: '2',
            productId: 'p2',
            title: 'Pants',
            imageUrl: 'url',
            price: 500,
            quantity: 1,
            selected: false,
          ),
        ],
      );
      expect(snapshot.itemCount, 3);
      expect(snapshot.availableItemCount, 3);
      expect(snapshot.selectedCount, 2);
      expect(snapshot.selectedTotalCents, 2000);
    });

    test('availableItemCount excludes unavailable lines', () {
      const snapshot = SHOCartSnapshot(
        items: [
          SHOCartItem(
            id: '1',
            productId: 'p1',
            title: 'Top',
            imageUrl: 'url',
            price: 1000,
            quantity: 2,
          ),
          SHOCartItem(
            id: '2',
            productId: 'p2',
            title: 'Sold out',
            imageUrl: 'url',
            price: 500,
            quantity: 3,
            unavailable: true,
          ),
        ],
      );
      expect(snapshot.itemCount, 5);
      expect(snapshot.availableItemCount, 2);
    });
  });

  group('Phase 1 models deserialize', () {
    test('SHOAddress from JSON', () {
      final address = SHOAddress.fromJson({
        'id': 'a1',
        'name': 'Test',
        'phone': '13800138000',
        'line1': 'Line 1',
        'city': 'NY',
        'region': 'NY',
        'isDefault': true,
      });
      expect(address.isDefault, isTrue);
      expect(address.fullLine, contains('Line 1'));
    });

    test('SHOPaymentResult from JSON', () {
      final result = SHOPaymentResult.fromJson({
        'orderId': 'o1',
        'status': 'paid',
        'paidAt': '2026-06-06',
      });
      expect(result.status, 'paid');
    });
  });
}
