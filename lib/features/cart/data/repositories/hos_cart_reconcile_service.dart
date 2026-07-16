import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/cart/domain/entities/hos_cart.dart';
import 'package:shoo/features/product/data/datasources/remote/hos_product_remote_ds.dart';
import 'package:shoo/features/product/domain/entities/hos_product_batch.dart';

final cartReconcileServiceProvider = Provider<SHOCartReconcileService>((ref) {
  return SHOCartReconcileService(ref.watch(productApiProvider));
});

class SHOCartReconcileReport {
  const SHOCartReconcileReport({
    required this.unavailableCount,
    required this.priceChangedCount,
    required this.stockClampedCount,
    required this.activityExpiredCount,
    required this.updatedItems,
  });

  final int unavailableCount;
  final int priceChangedCount;
  final int stockClampedCount;
  final int activityExpiredCount;
  final List<SHOCartItem> updatedItems;

  bool get hasIssues =>
      unavailableCount > 0 ||
      priceChangedCount > 0 ||
      stockClampedCount > 0 ||
      activityExpiredCount > 0;
}

class SHOCartReconcileService {
  SHOCartReconcileService(this._productApi);

  final SHOProductApi _productApi;

  /// 稳定 Mock 库存：与 batch mock 算法对齐，加购未对账前也能用。
  static int mockStockFor(String productId) {
    final hash = productId.hashCode.abs();
    return 5 + (hash % 20); // 5–24
  }

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

    final productIds = snapshot.items.map((i) => i.productId).toSet().toList();
    final skuIds = snapshot.items
        .map((i) => i.id)
        .where((id) => id.contains('::'))
        .toSet()
        .toList();

    final batch = await _productApi.fetchProductBatch(
      productIds: productIds,
      skuIds: skuIds,
    );
    final byId = batch.byProductId;
    final missing = batch.missingIds.toSet();

    var unavailable = 0;
    var priceChanged = 0;
    var stockClamped = 0;
    var activityExpired = 0;
    final updated = <SHOCartItem>[];

    for (final item in snapshot.items) {
      final remote = byId[item.productId];
      final productMissing =
          remote == null || missing.contains(item.productId) || !remote.available;

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

      final sku = _resolveSku(remote, item);
      if (sku != null && !sku.available) {
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

      final catalogPrice = remote.price;
      final listFromRemote =
          remote.originalPrice > 0 ? remote.originalPrice : catalogPrice;
      final stock = (sku?.stock ?? remote.stock).clamp(0, 1 << 31);
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

      final clampedQty = item.quantity.clamp(1, stock);
      if (clampedQty != item.quantity) stockClamped++;

      final listPrice = item.listPrice > 0 ? item.listPrice : listFromRemote;
      var price = item.price;
      var sessionId = item.sessionId;
      var sessionEndAt = item.sessionEndAt;
      var changed = false;

      if (item.hasActivity && item.isActivityExpired) {
        activityExpired++;
        price = listFromRemote > 0 ? listFromRemote : catalogPrice;
        sessionId = '';
        sessionEndAt = '';
        changed = true;
      } else if (!item.hasActivity) {
        if (catalogPrice != item.price) {
          priceChanged++;
          price = catalogPrice;
          changed = true;
        }
      }

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
          imageUrl: remote.imageUrl.isNotEmpty ? remote.imageUrl : item.imageUrl,
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

  SHOProductSkuStatus? _resolveSku(
    SHOProductBatchItem remote,
    SHOCartItem item,
  ) {
    if (item.variantLabel.isEmpty && !item.id.contains('::')) {
      return null;
    }
    final byId = remote.skuFor(item.id);
    if (byId != null) return byId;

    for (final sku in remote.skus) {
      if (sku.variantLabel == item.variantLabel) return sku;
    }
    // 有规格但服务端未返回匹配 SKU → 视为规格失效。
    if (item.variantLabel.isNotEmpty || item.id.contains('::')) {
      return SHOProductSkuStatus(
        skuId: item.id,
        variantLabel: item.variantLabel,
        stock: 0,
        available: false,
      );
    }
    return null;
  }
}
