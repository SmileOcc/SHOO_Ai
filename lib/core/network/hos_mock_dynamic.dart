import 'hos_mock_pagination.dart';

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
    return lookupProductDetail(catalogEnvelope, productId);
  }

  if (routePath == '/products/{id}/reviews' && reviewsCatalogEnvelope != null) {
    final productId = mockPathParam(routePath, requestPath, 'id');
    if (productId == null) return _reviewsNotFound('');
    return lookupProductReviews(reviewsCatalogEnvelope, productId);
  }

  final page = mockQueryInt(query, 'page', 0);
  if (page > 0) {
    final pageSize = mockQueryInt(query, 'pageSize', 10);
    return paginateMockEnvelope(envelope, page: page, pageSize: pageSize);
  }

  return envelope;
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
