import 'package:flutter_test/flutter_test.dart';
import 'package:shoo/features/checkout/domain/entities/hos_payment_result.dart';

void main() {
  group('SHOPaymentResult.fromResponse', () {
    test('parses mock flat payload', () {
      final result = SHOPaymentResult.fromResponse({
        'orderId': 'o-new',
        'status': 'paid',
        'paidAt': '2026-06-06 12:01',
        'message': 'Mock payment successful',
      });

      expect(result.orderId, 'o-new');
      expect(result.status, 'paid');
      expect(result.paidAt, '2026-06-06 12:01');
      expect(result.message, 'Mock payment successful');
    });

    test('parses legacy nested order payload', () {
      final result = SHOPaymentResult.fromResponse({
        'success': true,
        'order': {
          'id': 'ord-1',
          'orderNo': 'SH123',
          'status': 'paid',
          'createdAt': '2026-08-24 13:00',
          'totalCents': 1299,
          'items': [],
        },
      });

      expect(result.orderId, 'ord-1');
      expect(result.status, 'paid');
      expect(result.paidAt, '2026-08-24 13:00');
    });

    test('parses platform payment payload', () {
      final result = SHOPaymentResult.fromResponse({
        'orderId': 'ord-2',
        'status': 'paid',
        'paidAt': '2026-08-24 21:40',
        'message': 'Payment successful',
      });

      expect(result.orderId, 'ord-2');
      expect(result.message, 'Payment successful');
    });
  });
}
