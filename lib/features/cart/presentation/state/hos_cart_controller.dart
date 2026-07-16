import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/analytics/hos_analytics.dart';
import 'package:shoo/core/pricing/hos_full_reduction.dart';
import 'package:shoo/features/product/domain/entities/hos_product_detail.dart';
import 'package:shoo/features/cart/data/datasources/local/hos_cart_storage.dart';
import 'package:shoo/features/cart/data/repositories/hos_cart_reconcile_service.dart';
import 'package:shoo/features/cart/domain/entities/hos_cart.dart';
import 'package:shoo/features/flash_sale/presentation/state/hos_checkout_activity_provider.dart';

final cartProvider = NotifierProvider<SHOCartNotifier, SHOCartSnapshot>(
  SHOCartNotifier.new,
);

class SHOCartNotifier extends Notifier<SHOCartSnapshot> {
  late final SHOCartStorage _storage;
  int _writeEpoch = 0;

  @override
  SHOCartSnapshot build() {
    _storage = ref.read(cartStorageProvider);
    Future.microtask(restore);
    return const SHOCartSnapshot();
  }

  Future<void> restore() async {
    final epoch = _writeEpoch;
    final loaded = await _storage.load();
    // 忽略过期的 restore，避免覆盖用户刚改规格/数量后的内存态。
    if (epoch != _writeEpoch) return;
    state = loaded;
  }

  Future<void> _persist() => _storage.save(state);

  void _commit(SHOCartSnapshot next) {
    _writeEpoch++;
    state = next;
  }

  String _lineId(String productId, String variantLabel) =>
      '$productId::$variantLabel';

  int _stockFor(String productId, {int? preferred}) {
    if (preferred != null && preferred > 0) return preferred;
    return SHOCartReconcileService.mockStockFor(productId);
  }

  Future<void> addProduct({
    required SHOProductDetail product,
    required String variantLabel,
    int quantity = 1,
    int? stock,
    SHOCheckoutActivityLine? activity,
    String? sessionEndAt,
  }) async {
    final lineId = _lineId(product.id, variantLabel);
    final maxStock = _stockFor(product.id, preferred: stock);
    final unitPrice = activity?.unitPriceCents ?? product.price;
    final listPrice = activity?.originalUnitPriceCents ??
        (product.originalPrice > product.price
            ? product.originalPrice
            : product.price);
    final sessionId = activity?.sessionId ?? '';
    final endsAt = sessionEndAt ?? '';

    final matches = state.items.where((i) => i.id == lineId);
    final existing = matches.isEmpty ? null : matches.first;

    final items = [...state.items];
    if (existing != null) {
      final index = items.indexWhere((i) => i.id == lineId);
      final nextQty = (existing.quantity + quantity).clamp(1, maxStock);
      items[index] = existing.copyWith(
        quantity: nextQty,
        selected: true,
        unavailable: false,
        stock: maxStock,
        price: unitPrice,
        listPrice: listPrice,
        sessionId: sessionId.isNotEmpty ? sessionId : existing.sessionId,
        sessionEndAt: endsAt.isNotEmpty ? endsAt : existing.sessionEndAt,
        title: product.title,
        imageUrl: product.imageUrl,
      );
    } else {
      items.add(
        SHOCartItem(
          id: lineId,
          productId: product.id,
          title: product.title,
          imageUrl: product.imageUrl,
          price: unitPrice,
          listPrice: listPrice,
          quantity: quantity.clamp(1, maxStock),
          variantLabel: variantLabel,
          stock: maxStock,
          sessionId: sessionId,
          sessionEndAt: endsAt,
        ),
      );
    }
    _commit(SHOCartSnapshot(items: items));
    await _persist();
    await SHOAnalyticsManager.instance.trackEvent(
      SHOAnalyticsRegistry.addToCart,
      {'product_id': product.id, 'sku_id': lineId, 'quantity': quantity},
    );
  }

  /// 购物车内改规格：原地替换行，若目标规格已存在则合并数量。
  ///
  /// [expectedProductId] 与面板商品对齐时传入，防止 lineId / 商品串线。
  Future<void> changeVariant({
    required String lineId,
    required String newVariantLabel,
    required int quantity,
    String? expectedProductId,
  }) async {
    final sourceIndex = state.items.indexWhere((i) => i.id == lineId);
    if (sourceIndex < 0) return;
    final source = state.items[sourceIndex];
    if (source.unavailable) return;
    if (expectedProductId != null &&
        expectedProductId.isNotEmpty &&
        source.productId != expectedProductId) {
      return;
    }

    final newId = _lineId(source.productId, newVariantLabel);
    final stock = source.stock > 0
        ? source.stock
        : _stockFor(source.productId);
    final qty = quantity.clamp(1, stock);

    if (newId == lineId) {
      await updateQuantity(lineId, qty);
      return;
    }

    final items = [...state.items];
    final duplicateIndex = items.indexWhere(
      (i) => i.id == newId && i.id != lineId,
    );

    if (duplicateIndex >= 0) {
      // 同商品已有目标规格：合并到当前编辑位，去掉另一行，避免列表错位看起来像改错商品。
      final duplicate = items[duplicateIndex];
      final mergedQty = (duplicate.quantity + qty).clamp(1, stock);
      final merged = duplicate.copyWith(
        quantity: mergedQty,
        selected: true,
        unavailable: false,
        stock: stock,
      );
      if (duplicateIndex > sourceIndex) {
        items.removeAt(duplicateIndex);
        items[sourceIndex] = merged;
      } else {
        items.removeAt(sourceIndex);
        items[duplicateIndex] = merged;
      }
    } else {
      // 原地改规格，保持列表位置不变。
      items[sourceIndex] = source.copyWith(
        id: newId,
        variantLabel: newVariantLabel,
        quantity: qty,
        selected: true,
        unavailable: false,
        stock: stock,
      );
    }

    _commit(SHOCartSnapshot(items: items));
    await _persist();
  }

  Future<void> updateQuantity(String lineId, int quantity) async {
    if (quantity < 1) return;
    _commit(
      SHOCartSnapshot(
        items: [
          for (final item in state.items)
            if (item.id == lineId)
              item.copyWith(
                quantity: quantity.clamp(
                  1,
                  item.stock > 0 ? item.stock : kSHOCartDefaultStock,
                ),
              )
            else
              item,
        ],
      ),
    );
    await _persist();
  }

  Future<void> removeItem(String lineId) async {
    _commit(
      SHOCartSnapshot(
        items: state.items.where((i) => i.id != lineId).toList(),
      ),
    );
    await _persist();
  }

  Future<void> removeItems(Iterable<String> lineIds) async {
    final idSet = lineIds.toSet();
    if (idSet.isEmpty) return;
    _commit(
      SHOCartSnapshot(
        items: state.items.where((i) => !idSet.contains(i.id)).toList(),
      ),
    );
    await _persist();
  }

  Future<void> toggleSelected(String lineId) async {
    _commit(
      SHOCartSnapshot(
        items: [
          for (final item in state.items)
            if (item.id == lineId && !item.unavailable)
              item.copyWith(selected: !item.selected)
            else
              item,
        ],
      ),
    );
    await _persist();
  }

  Future<void> selectAll(bool selected) async {
    _commit(
      SHOCartSnapshot(
        items: [
          for (final item in state.items)
            item.unavailable
                ? item.copyWith(selected: false)
                : item.copyWith(selected: selected),
        ],
      ),
    );
    await _persist();
  }

  Future<void> removeSelected() async {
    _commit(
      SHOCartSnapshot(
        items:
            state.items.where((i) => !(i.selected && !i.unavailable)).toList(),
      ),
    );
    await _persist();
  }

  Future<void> clear() async {
    _commit(const SHOCartSnapshot());
    await _storage.clear();
  }

  Future<void> applyReconciledItems(List<SHOCartItem> items) async {
    _commit(SHOCartSnapshot(items: items));
    await _persist();
  }

  Future<void> removeUnavailableItems() async {
    _commit(
      SHOCartSnapshot(
        items: state.items.where((item) => !item.unavailable).toList(),
      ),
    );
    await _persist();
  }
}

/// 结算前：把购物车勾选行的活动价同步到内存 activity map。
void syncCheckoutActivityFromCart(
  WidgetRef ref,
  List<SHOCartItem> selectedItems,
) {
  final map = <String, SHOCheckoutActivityLine>{};
  for (final item in selectedItems) {
    if (!item.hasActivity || item.isActivityExpired) continue;
    map[item.productId] = SHOCheckoutActivityLine(
      productId: item.productId,
      sessionId: item.sessionId,
      unitPriceCents: item.effectiveUnitCents,
      originalUnitPriceCents:
          item.listPrice > item.effectiveUnitCents ? item.listPrice : 0,
    );
  }
  ref.read(checkoutActivityLinesProvider.notifier).state = map;
}
