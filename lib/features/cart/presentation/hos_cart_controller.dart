import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/hos_analytics.dart';
import '../../product/domain/hos_product_detail.dart';
import '../data/hos_cart_storage.dart';
import '../domain/hos_cart.dart';

final cartProvider = NotifierProvider<SHOCartNotifier, SHOCartSnapshot>(
  SHOCartNotifier.new,
);

class SHOCartNotifier extends Notifier<SHOCartSnapshot> {
  late final SHOCartStorage _storage;

  @override
  SHOCartSnapshot build() {
    _storage = ref.read(cartStorageProvider);
    Future.microtask(restore);
    return const SHOCartSnapshot();
  }

  Future<void> restore() async {
    state = await _storage.load();
  }

  Future<void> _persist() => _storage.save(state);

  String _lineId(String productId, String variantLabel) =>
      '$productId::$variantLabel';

  Future<void> addProduct({
    required SHOProductDetail product,
    required String variantLabel,
    int quantity = 1,
  }) async {
    final lineId = _lineId(product.id, variantLabel);
    final matches = state.items.where((i) => i.id == lineId);
    final existing = matches.isEmpty ? null : matches.first;

    final items = [...state.items];
    if (existing != null) {
      final index = items.indexWhere((i) => i.id == lineId);
      items[index] = existing.copyWith(
        quantity: existing.quantity + quantity,
        selected: true,
      );
    } else {
      items.add(
        SHOCartItem(
          id: lineId,
          productId: product.id,
          title: product.title,
          imageUrl: product.imageUrl,
          price: product.price,
          quantity: quantity,
          variantLabel: variantLabel,
        ),
      );
    }
    state = SHOCartSnapshot(items: items);
    await _persist();
    await SHOAnalyticsManager.instance.trackEvent(
      SHOAnalyticsRegistry.addToCart,
      {
        'product_id': product.id,
        'sku_id': lineId,
        'quantity': quantity,
      },
    );
  }

  Future<void> updateQuantity(String lineId, int quantity) async {
    if (quantity < 1) return;
    state = SHOCartSnapshot(
      items: [
        for (final item in state.items)
          if (item.id == lineId) item.copyWith(quantity: quantity) else item,
      ],
    );
    await _persist();
  }

  Future<void> removeItem(String lineId) async {
    state = SHOCartSnapshot(
      items: state.items.where((i) => i.id != lineId).toList(),
    );
    await _persist();
  }

  Future<void> toggleSelected(String lineId) async {
    state = SHOCartSnapshot(
      items: [
        for (final item in state.items)
          if (item.id == lineId) item.copyWith(selected: !item.selected) else item,
      ],
    );
    await _persist();
  }

  Future<void> selectAll(bool selected) async {
    state = SHOCartSnapshot(
      items: [for (final item in state.items) item.copyWith(selected: selected)],
    );
    await _persist();
  }

  Future<void> removeSelected() async {
    state = SHOCartSnapshot(
      items: state.items.where((i) => !i.selected).toList(),
    );
    await _persist();
  }

  Future<void> clear() async {
    state = const SHOCartSnapshot();
    await _storage.clear();
  }

  Future<void> applyReconciledItems(List<SHOCartItem> items) async {
    state = SHOCartSnapshot(items: items);
    await _persist();
  }

  Future<void> removeUnavailableItems() async {
    state = SHOCartSnapshot(
      items: state.items.where((item) => !item.unavailable).toList(),
    );
    await _persist();
  }
}
