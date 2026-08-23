import 'package:shoo/core/network/hos_mock_dynamic.dart';
import 'package:shoo/core/network/hos_mock_pagination.dart';

String themeActivityMockAsset(String activityId) {
  switch (activityId) {
    case 'demo_coupon_rush':
      return 'assets/mock/theme_activity_demo_coupon_rush.json';
    case 'demo_nine_waterfall':
      return 'assets/mock/theme_activity_demo_nine_waterfall.json';
    case 'demo_all_modules':
      return 'assets/mock/theme_activity_demo_all_modules.json';
    case 'demo_long_banner':
    default:
      return 'assets/mock/theme_activity_demo_long_banner.json';
  }
}

Map<String, dynamic> resolveThemeActivityProducts(
  Map<String, dynamic> productsEnvelope, {
  required Map<String, dynamic> query,
}) {
  final data = productsEnvelope['data'];
  if (data is! Map<String, dynamic>) return productsEnvelope;

  final items = data['items'];
  if (items is! List) return productsEnvelope;

  final list = items.whereType<Map<String, dynamic>>().map((item) {
    final id = item['id']?.toString() ?? '';
    return {
      'productId': id,
      'image': item['imageUrl'] ?? '',
      'title': item['title'] ?? '',
      'subtitle': item['discountLabel'] ?? '',
      'price': item['price'] ?? 0,
      'originPrice': item['originalPrice'] ?? 0,
      'currency': 'USD',
      'tags': item['discountLabel'] != null ? [item['discountLabel']] : [],
      'salesText': item['soldCount'] != null ? '${item['soldCount']} sold' : '',
      'badge': item['discountLabel'] ?? '',
      'link': 'https://shoo.app/product/$id',
      'cartAction': 'addToCart',
    };
  }).toList();

  final page = mockQueryInt(query, 'page', 1);
  final pageSize = mockQueryInt(query, 'pageSize', 10);
  final start = (page - 1) * pageSize;
  final slice = start >= list.length
      ? <Map<String, dynamic>>[]
      : list
          .sublist(start, (start + pageSize).clamp(0, list.length))
          .cast<Map<String, dynamic>>();

  return {
    'code': productsEnvelope['code'] ?? 0,
    'message': productsEnvelope['message'] ?? 'ok',
    'data': {
      'list': slice,
      'page': page,
      'pageSize': pageSize,
      'total': list.length,
      'hasMore': start + pageSize < list.length,
    },
  };
}

String? themeActivityIdFromPath(String pattern, String path) {
  return mockPathParam(pattern, path, 'activityId');
}
