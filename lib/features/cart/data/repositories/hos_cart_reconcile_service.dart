import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoo/features/cart/domain/entities/hos_cart.dart';
import 'package:shoo/features/product/data/datasources/remote/hos_product_remote_ds.dart';
import 'package:shoo/features/product/domain/entities/hos_product_batch.dart';

/// 购物车对账服务的 Provider。
///
/// 用于获取 [SHOCartReconcileService] 实例，该服务负责同步购物车商品的实时状态。
final cartReconcileServiceProvider = Provider<SHOCartReconcileService>((ref) {
  return SHOCartReconcileService(ref.watch(productApiProvider));
});

/// 购物车对账报告，汇总对账过程中发现的各类问题。
class SHOCartReconcileReport {
  const SHOCartReconcileReport({
    required this.unavailableCount,
    required this.priceChangedCount,
    required this.stockClampedCount,
    required this.activityExpiredCount,
    required this.updatedItems,
  });

  /// 不可用商品数量（商品已下架、规格失效、库存为0）。
  final int unavailableCount;

  /// 价格变动商品数量。
  final int priceChangedCount;

  /// 库存不足被限制数量的商品数量。
  final int stockClampedCount;

  /// 活动过期商品数量。
  final int activityExpiredCount;

  /// 更新后的购物车商品列表。
  final List<SHOCartItem> updatedItems;

  /// 是否存在任何对账问题。
  bool get hasIssues =>
      unavailableCount > 0 ||
      priceChangedCount > 0 ||
      stockClampedCount > 0 ||
      activityExpiredCount > 0;
}

/// 购物车对账服务，负责同步购物车商品的实时状态（价格、库存、活动等）。
class SHOCartReconcileService {
  SHOCartReconcileService(this._productApi);

  /// 商品 API 数据源，用于批量查询商品信息。
  final SHOProductApi _productApi;

  /// 稳定 Mock 库存：与 batch mock 算法对齐，加购未对账前也能用。
  ///
  /// 根据商品 ID 的哈希值生成 5-24 之间的库存数量。
  static int mockStockFor(String productId) {
    final hash = productId.hashCode.abs();
    return 5 + (hash % 20); // 5–24
  }

  /// 对账购物车，同步商品的实时状态。
  ///
  /// 批量查询商品信息，检查并更新以下状态：
  /// - 商品是否下架或不可用
  /// - SKU 规格是否失效
  /// - 库存是否充足
  /// - 价格是否变动
  /// - 活动是否过期
  Future<SHOCartReconcileReport> reconcile(SHOCartSnapshot snapshot) async {
    if (snapshot.items.isEmpty) {
      return const SHOCartReconcileReport(
        unavailableCount: 0,
        priceChangedCount: 0,
        stockClampedCount: 0,
        activityExpiredCount: 0,
        updatedItems: [],
      );
    }

    // 提取所有产品 ID 和带规格的 SKU ID（ID 包含 '::' 表示带规格，格式为 productId::skuId）
    final productIds = snapshot.items.map((i) => i.productId).toSet().toList();
    final skuIds = snapshot.items
        .where((i) => i.variantLabel.trim().isNotEmpty || _hasSkuLineId(i.id))
        .map((i) => i.id)
        .toSet()
        .toList();

    // 批量查询商品信息
    final batch = await _productApi.fetchProductBatch(
      productIds: productIds,
      skuIds: skuIds,
    );
    final byId = batch.byProductId;
    final missing = batch.missingIds.toSet();

    // 统计各类问题数量
    var unavailable = 0;
    var priceChanged = 0;
    var stockClamped = 0;
    var activityExpired = 0;
    final updated = <SHOCartItem>[];

    for (final item in snapshot.items) {
      final remote = byId[item.productId];
      final productMissing =
          remote == null ||
          missing.contains(item.productId) ||
          !remote.available;

      // 商品不存在或不可用
      if (productMissing) {
        unavailable++;
        updated.add(
          item.copyWith(
            unavailable: true,
            priceChanged: false,
            selected: false,
            stock: 0,
          ),
        );
        continue;
      }

      // 解析 SKU 规格
      final sku = _resolveSku(remote, item);
      if (sku != null && !sku.available) {
        // SKU 规格不可用
        unavailable++;
        updated.add(
          item.copyWith(
            unavailable: true,
            priceChanged: false,
            selected: false,
            stock: 0,
          ),
        );
        continue;
      }

      // 获取价格和库存
      final catalogPrice = remote.price;
      final listFromRemote = remote.originalPrice > 0
          ? remote.originalPrice
          : catalogPrice;
      final productStock = remote.stock > 0
          ? remote.stock
          : mockStockFor(item.productId);
      final stock = (sku?.stock ?? productStock).clamp(0, 1 << 31);

      // 库存为0
      if (stock <= 0) {
        unavailable++;
        updated.add(
          item.copyWith(
            unavailable: true,
            priceChanged: false,
            selected: false,
            stock: 0,
          ),
        );
        continue;
      }

      // 限制数量不超过库存
      final clampedQty = item.quantity.clamp(1, stock);
      if (clampedQty != item.quantity) stockClamped++;

      // 更新价格和活动状态
      final listPrice = item.listPrice > 0 ? item.listPrice : listFromRemote;
      var price = item.price;
      var sessionId = item.sessionId;
      var sessionEndAt = item.sessionEndAt;
      var changed = false;

      // 活动过期处理
      if (item.hasActivity && item.isActivityExpired) {
        activityExpired++;
        price = listFromRemote > 0 ? listFromRemote : catalogPrice;
        sessionId = '';
        sessionEndAt = '';
        changed = true;
      } else if (!item.hasActivity) {
        // 非活动商品价格变动处理
        if (catalogPrice != item.price) {
          priceChanged++;
          price = catalogPrice;
          changed = true;
        }
      }

      // 添加更新后的商品
      updated.add(
        item.copyWith(
          unavailable: false,
          priceChanged: changed && !item.hasActivity,
          price: price,
          listPrice: listFromRemote > 0 ? listFromRemote : listPrice,
          stock: stock,
          quantity: clampedQty,
          sessionId: sessionId,
          sessionEndAt: sessionEndAt,
          title: remote.title.isNotEmpty ? remote.title : item.title,
          imageUrl: remote.imageUrl.isNotEmpty
              ? remote.imageUrl
              : item.imageUrl,
        ),
      );
    }

    return SHOCartReconcileReport(
      unavailableCount: unavailable,
      priceChangedCount: priceChanged,
      stockClampedCount: stockClamped,
      activityExpiredCount: activityExpired,
      updatedItems: updated,
    );
  }

  /// 根据购物车项解析对应的 SKU 规格信息。
  ///
  /// 优先按完整 ID（包含 '::'）查找，其次按规格标签查找。
  /// 如果有规格但服务端未返回匹配 SKU，视为规格失效。
  SHOProductSkuStatus? _resolveSku(
    SHOProductBatchItem remote,
    SHOCartItem item,
  ) {
    final variant = item.variantLabel.trim();
    final hasSkuSuffix = _hasSkuLineId(item.id);

    // 无规格行：按商品级库存对账。
    if (variant.isEmpty && !hasSkuSuffix) {
      return null;
    }

    // 服务端未下发 SKU 维度时，仍按商品级库存处理（避免误标失效）。
    if (remote.skus.isEmpty) {
      return null;
    }

    // 优先按完整 skuId 查找。
    final byId = remote.skuFor(item.id);
    if (byId != null) return byId;

    // 按规格文案查找。
    for (final sku in remote.skus) {
      if (sku.variantLabel == variant) return sku;
    }

    // 有规格但服务端无匹配 SKU → 规格失效。
    return SHOProductSkuStatus(
      skuId: item.id,
      variantLabel: variant,
      stock: 0,
      available: false,
    );
  }

  bool _hasSkuLineId(String lineId) {
    final index = lineId.indexOf('::');
    if (index < 0) return false;
    return lineId.substring(index + 2).trim().isNotEmpty;
  }
}
