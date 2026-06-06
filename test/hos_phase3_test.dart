import 'package:flutter_test/flutter_test.dart';
import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/features/after_sale/domain/hos_after_sale.dart';
import 'package:shoo/features/coupon/domain/hos_coupon.dart';

void main() {
  group('Phase 3 routes', () {
    test('coupon and after-sale routes', () {
      expect(SHOAppRoutes.coupons, '/coupons');
      expect(SHOAppRoutes.couponsSelect, '/coupons?select=1');
      expect(SHOAppRoutes.afterSales, '/after-sales');
      expect(SHOAppRoutes.afterSaleApply('o1'), '/after-sales/apply/o1');
    });
  });

  group('Phase 3 models', () {
    test('SHOCoupon from JSON', () {
      final coupon = SHOCoupon.fromJson({
        'id': 'c1',
        'title': 'Test',
        'type': 'percent',
        'discountPercent': 10,
        'minOrderCents': 1000,
        'expiresAt': '2026-12-31',
      });
      expect(coupon.type, SHOCouponType.percent);
    });

    test('SHOAfterSaleRequest from JSON', () {
      final req = SHOAfterSaleRequest.fromJson({
        'id': 'as1',
        'orderId': 'o1',
        'orderNo': 'SH001',
        'type': 'refund',
        'status': 'pending',
        'reason': 'Test',
        'createdAt': '2026-06-06',
      });
      expect(req.type, SHOAfterSaleType.refund);
      expect(req.status, SHOAfterSaleStatus.pending);
    });
  });
}
