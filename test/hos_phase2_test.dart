import 'package:flutter_test/flutter_test.dart';
import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/features/order/domain/hos_order.dart';
import 'package:shoo/features/review/domain/hos_review.dart';

void main() {
  group('Phase 2 routes', () {
    test('product and nested review routes', () {
      expect(SHOAppRoutes.product('p1'), '/product/p1');
      expect(SHOAppRoutes.productReviews('p1'), '/product/p1/reviews');
    });

    test('order and logistics routes', () {
      expect(SHOAppRoutes.order('o1'), '/orders/o1');
      expect(SHOAppRoutes.orderLogistics('o1'), '/orders/o1/logistics');
      expect(
        SHOAppRoutes.ordersFiltered('shipped'),
        '/orders?status=shipped',
      );
    });

    test('search route constant', () {
      expect(SHOAppRoutes.search, '/search');
    });
  });

  group('Phase 2 models deserialize', () {
    test('SHOProductReviewSummary from JSON', () {
      final summary = SHOProductReviewSummary.fromJson({
        'averageRating': 4.8,
        'totalCount': 2,
        'items': [
          {
            'id': 'r1',
            'userName': 'Test',
            'rating': 5.0,
            'content': 'Great',
            'createdAt': '2026-05-01',
          },
        ],
      });
      expect(summary.averageRating, 4.8);
      expect(summary.items, hasLength(1));
    });

    test('SHOOrderSummary from JSON', () {
      final order = SHOOrderSummary.fromJson({
        'id': 'o1',
        'orderNo': 'SH001',
        'status': 'shipped',
        'totalCents': 1000,
        'createdAt': '2026-05-01',
        'items': [],
      });
      expect(order.status, SHOOrderStatus.shipped);
    });

    test('SHOLogisticsTrack from JSON', () {
      final track = SHOLogisticsTrack.fromJson({
        'orderId': 'o1',
        'carrier': 'SHOO Express',
        'trackingNumber': 'SX001',
        'events': [
          {
            'time': '2026-06-01',
            'status': 'Shipped',
            'description': 'Left warehouse',
            'isActive': true,
          },
        ],
      });
      expect(track.events, hasLength(1));
      expect(track.events.first.isActive, isTrue);
    });
  });
}
