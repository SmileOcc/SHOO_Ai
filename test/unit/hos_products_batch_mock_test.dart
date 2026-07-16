import 'package:flutter_test/flutter_test.dart';

import 'package:shoo/core/network/hos_mock_dynamic.dart';
import 'package:shoo/core/network/hos_mock_route_registry.dart';

void main() {
  group('products batch mock', () {
    test('route /products/batch is not captured by /products/{id}', () {
      final entry = SHOMockRouteRegistry.match('GET', '/products/batch');
      expect(entry, isNotNull);
      expect(entry!.path, '/products/batch');
    });

    test('lookupProductsBatch returns only requested ids', () {
      final catalog = {
        'code': 0,
        'message': 'ok',
        'data': {
          'items': [
            {
              'id': 'p-a',
              'title': 'A',
              'imageUrl': '',
              'price': 1000,
              'originalPrice': 1200,
            },
            {
              'id': 'p-b',
              'title': 'B',
              'imageUrl': '',
              'price': 2000,
              'originalPrice': 2500,
            },
          ],
        },
      };

      final result = lookupProductsBatch(
        catalog,
        query: {
          'ids': 'p-a,p-missing',
          'skuIds': 'p-a::Size M,p-a::Weird',
        },
      );

      expect(result['code'], 0);
      final data = result['data'] as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>;
      final missing = data['missingIds'] as List<dynamic>;

      expect(missing, ['p-missing']);
      expect(items, hasLength(1));
      final item = items.first as Map<String, dynamic>;
      expect(item['productId'], 'p-a');
      expect(item['price'], 1000);
      expect(item['available'], isTrue);

      final skus = item['skus'] as List<dynamic>;
      final weird = skus.cast<Map<String, dynamic>>().firstWhere(
        (s) => s['skuId'] == 'p-a::Weird',
      );
      expect(weird['available'], isFalse);
      expect(weird['stock'], 0);

      final sizeM = skus.cast<Map<String, dynamic>>().firstWhere(
        (s) => s['skuId'] == 'p-a::Size M',
      );
      expect(sizeM['available'], isTrue);
    });
  });
}
