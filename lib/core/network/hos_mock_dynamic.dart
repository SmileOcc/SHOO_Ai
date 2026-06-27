import 'package:shoo/core/network/hos_mock_flash_sale_follow_store.dart';
import 'package:shoo/core/network/hos_flash_sale_mock_dynamic.dart';
import 'package:shoo/core/network/hos_mock_pagination.dart';

/// 从路由 pattern 提取路径参数，如 `/products/{id}` + `/products/c1-p1` → `c1-p1`。
String? mockPathParam(String pattern, String path, String name) {
  final patternParts = pattern.split('/');
  final pathParts = path.split('/');
  if (patternParts.length != pathParts.length) return null;

  for (var i = 0; i < patternParts.length; i++) {
    final segment = patternParts[i];
    if (segment == '{$name}') {
      return pathParts[i];
    }
  }
  return null;
}

Map<String, dynamic> filterProductsByCategory(
  Map<String, dynamic> envelope, {
  required String categoryId,
}) {
  final data = envelope['data'];
  if (data is! Map<String, dynamic>) return envelope;

  final items = data['items'];
  if (items is! List) return envelope;

  final filtered = items
      .whereType<Map<String, dynamic>>()
      .where((item) => item['categoryId'] == categoryId)
      .toList();

  return {
    ...envelope,
    'data': {
      ...data,
      'items': filtered,
      'page': 1,
      'pageSize': filtered.length,
      'total': filtered.length,
      'hasMore': false,
    },
  };
}

Map<String, dynamic> lookupProductDetail(
  Map<String, dynamic> catalogEnvelope,
  String productId,
) {
  final data = catalogEnvelope['data'];
  if (data is! Map<String, dynamic>) {
    return _productNotFound(productId);
  }

  final items = data['items'];
  if (items is! List) return _productNotFound(productId);

  for (final raw in items) {
    if (raw is Map<String, dynamic> && raw['id'] == productId) {
      return {
        'code': catalogEnvelope['code'] ?? 0,
        'message': catalogEnvelope['message'] ?? 'ok',
        'data': raw,
      };
    }
  }
  return _productNotFound(productId);
}

Map<String, dynamic> lookupProductReviews(
  Map<String, dynamic> catalogEnvelope,
  String productId,
) {
  final data = catalogEnvelope['data'];
  if (data is! Map<String, dynamic>) {
    return _reviewsNotFound(productId);
  }

  final byProduct = data['byProduct'];
  if (byProduct is! Map<String, dynamic>) return _reviewsNotFound(productId);

  final reviews = byProduct[productId];
  if (reviews is! Map<String, dynamic>) return _reviewsNotFound(productId);

  return {
    'code': catalogEnvelope['code'] ?? 0,
    'message': catalogEnvelope['message'] ?? 'ok',
    'data': reviews,
  };
}

Map<String, dynamic> applyMockDynamic(
  Map<String, dynamic> envelope, {
  required String routePath,
  required String requestPath,
  required Map<String, dynamic> query,
  Map<String, dynamic>? catalogEnvelope,
  Map<String, dynamic>? reviewsCatalogEnvelope,
  Map<String, dynamic>? flashSaleCatalogEnvelope,
}) {
  if (routePath == '/products') {
    final categoryId = query['categoryId']?.toString();
    if (categoryId != null && categoryId.isNotEmpty) {
      envelope = filterProductsByCategory(envelope, categoryId: categoryId);
    }
    final page = mockQueryInt(query, 'page', 0);
    if (page > 0) {
      final pageSize = mockQueryInt(query, 'pageSize', 10);
      envelope = paginateMockEnvelope(envelope, page: page, pageSize: pageSize);
    }
    return envelope;
  }

  if (routePath == '/products/{id}' && catalogEnvelope != null) {
    final productId = mockPathParam(routePath, requestPath, 'id');
    if (productId == null) return _productNotFound('');
    final result = lookupProductDetail(catalogEnvelope, productId);
    if ((result['code'] as int?) == 404 && flashSaleCatalogEnvelope != null) {
      return lookupFlashSaleProductDetail(
        flashSaleCatalogEnvelope,
        productId,
        sessionId: query['sessionId']?.toString(),
      );
    }
    return result;
  }

  if (routePath == '/products/{id}/reviews' && reviewsCatalogEnvelope != null) {
    final productId = mockPathParam(routePath, requestPath, 'id');
    if (productId == null) return _reviewsNotFound('');
    final result = lookupProductReviews(reviewsCatalogEnvelope, productId);
    if ((result['code'] as int?) == 404 &&
        flashSaleCatalogEnvelope != null &&
        _isFlashSaleProductId(productId, flashSaleCatalogEnvelope)) {
      return emptyFlashSaleProductReviews();
    }
    return result;
  }

  if (routePath == '/community/feed') {
    return sortCommunityFeedEnvelope(envelope, query: query);
  }

  if (routePath == '/flash-sale/calendar') {
    return resolveFlashSaleCalendar(envelope, query: query);
  }

  if (routePath == '/flash-sale/page') {
    return resolveFlashSalePage(envelope, query: query);
  }

  if (routePath == '/flash-sale/follows') {
    return {
      'code': envelope['code'] ?? 0,
      'message': envelope['message'] ?? 'ok',
      'data': SHOMockFlashSaleFollowStore.list(),
    };
  }

  if (routePath == '/flash-sale/product-activity') {
    final productId = query['productId']?.toString() ?? '';
    final sessionId = query['sessionId']?.toString() ?? '';
    return resolveFlashSaleProductActivity(
      envelope,
      productId: productId,
      sessionId: sessionId,
    );
  }

  final page = mockQueryInt(query, 'page', 0);
  if (page > 0) {
    final pageSize = mockQueryInt(query, 'pageSize', 10);
    return paginateMockEnvelope(envelope, page: page, pageSize: pageSize);
  }

  return envelope;
}

Map<String, dynamic> sortCommunityFeedEnvelope(
  Map<String, dynamic> envelope, {
  required Map<String, dynamic> query,
}) {
  final data = envelope['data'];
  if (data is! Map<String, dynamic>) return envelope;

  final items = (data['items'] as List<dynamic>?)
      ?.whereType<Map<String, dynamic>>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
  if (items == null) return envelope;

  final sort = query['sort']?.toString() ?? 'all';
  items.sort((a, b) {
    if (sort == 'latest') {
      final at = a['publishedAt']?.toString() ?? '';
      final bt = b['publishedAt']?.toString() ?? '';
      return bt.compareTo(at);
    }
    if (sort == 'hot') {
      final ah = a['hotScore'] as int? ?? 0;
      final bh = b['hotScore'] as int? ?? 0;
      return bh.compareTo(ah);
    }
    return 0;
  });

  final page = mockQueryInt(query, 'page', 0);
  var result = {
    ...envelope,
    'data': {
      ...data,
      'items': items,
    },
  };
  if (page > 0) {
    final pageSize = mockQueryInt(query, 'pageSize', 20);
    result = paginateMockEnvelope(result, page: page, pageSize: pageSize);
  }
  return result;
}

Map<String, dynamic> _productNotFound(String productId) {
  return {
    'code': 404,
    'message': 'Product not found: $productId',
    'data': null,
  };
}

Map<String, dynamic> _reviewsNotFound(String productId) {
  return {
    'code': 404,
    'message': 'Reviews not found: $productId',
    'data': null,
  };
}

bool _isFlashSaleProductId(
  String productId,
  Map<String, dynamic> flashSaleCatalogEnvelope,
) {
  final data = flashSaleCatalogEnvelope['data'];
  if (data is! Map<String, dynamic>) return productId.startsWith('fs-');
  final products = data['products'] as List<dynamic>?;
  if (products == null) return productId.startsWith('fs-');
  return products.any(
    (p) => p is Map<String, dynamic> && p['id'] == productId,
  );
}
