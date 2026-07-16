/// 批量对账返回的单个 SKU 库存状态。
class SHOProductSkuStatus {
  const SHOProductSkuStatus({
    required this.skuId,
    required this.variantLabel,
    required this.stock,
    required this.available,
  });

  final String skuId;
  final String variantLabel;
  final int stock;
  final bool available;

  factory SHOProductSkuStatus.fromJson(Map<String, dynamic> json) {
    return SHOProductSkuStatus(
      skuId: json['skuId'] as String? ?? '',
      variantLabel: json['variantLabel'] as String? ?? '',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      available: json['available'] as bool? ?? false,
    );
  }
}

/// 批量对账返回的商品快照（价格 + 库存 + SKU）。
class SHOProductBatchItem {
  const SHOProductBatchItem({
    required this.productId,
    required this.price,
    required this.originalPrice,
    required this.stock,
    required this.available,
    this.title = '',
    this.imageUrl = '',
    this.skus = const [],
  });

  final String productId;
  final int price;
  final int originalPrice;
  final int stock;
  final bool available;
  final String title;
  final String imageUrl;
  final List<SHOProductSkuStatus> skus;

  factory SHOProductBatchItem.fromJson(Map<String, dynamic> json) {
    final rawSkus = json['skus'];
    return SHOProductBatchItem(
      productId: json['productId'] as String? ?? json['id'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      originalPrice: (json['originalPrice'] as num?)?.toInt() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      available: json['available'] as bool? ?? true,
      title: json['title'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      skus: rawSkus is List
          ? rawSkus
                .whereType<Map<String, dynamic>>()
                .map(SHOProductSkuStatus.fromJson)
                .toList()
          : const [],
    );
  }

  /// 按购物车行 skuId（`productId::variantLabel`）取库存；无匹配则退回商品级库存。
  SHOProductSkuStatus? skuFor(String skuId) {
    if (skuId.isEmpty) return null;
    for (final sku in skus) {
      if (sku.skuId == skuId) return sku;
    }
    return null;
  }
}

class SHOProductBatchResult {
  const SHOProductBatchResult({
    required this.items,
    this.missingIds = const [],
  });

  final List<SHOProductBatchItem> items;
  final List<String> missingIds;

  factory SHOProductBatchResult.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final rawMissing = json['missingIds'];
    return SHOProductBatchResult(
      items: rawItems is List
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(SHOProductBatchItem.fromJson)
                .toList()
          : const [],
      missingIds: rawMissing is List
          ? rawMissing.map((e) => e.toString()).toList()
          : const [],
    );
  }

  Map<String, SHOProductBatchItem> get byProductId => {
    for (final item in items) item.productId: item,
  };
}
