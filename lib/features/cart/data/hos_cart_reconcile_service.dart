import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/data/hos_home_api.dart';
import '../domain/hos_cart.dart';

final cartReconcileServiceProvider = Provider<SHOCartReconcileService>((ref) {
  return SHOCartReconcileService(ref.watch(homeApiProvider));
});

class SHOCartReconcileReport {
  const SHOCartReconcileReport({
    required this.unavailableCount,
    required this.priceChangedCount,
    required this.updatedItems,
  });

  final int unavailableCount;
  final int priceChangedCount;
  final List<SHOCartItem> updatedItems;

  bool get hasIssues => unavailableCount > 0 || priceChangedCount > 0;
}

class SHOCartReconcileService {
  SHOCartReconcileService(this._homeApi);

  final SHOHomeApi _homeApi;

  Future<SHOCartReconcileReport> reconcile(SHOCartSnapshot snapshot) async {
    if (snapshot.items.isEmpty) {
      return const SHOCartReconcileReport(
        unavailableCount: 0,
        priceChangedCount: 0,
        updatedItems: [],
      );
    }

    final catalog = await _homeApi.fetchProducts(page: 1);
    final priceById = {
      for (final p in catalog.items) p.id: p.price,
    };

    var unavailable = 0;
    var priceChanged = 0;
    final updated = <SHOCartItem>[];

    for (final item in snapshot.items) {
      final currentPrice = priceById[item.productId];
      if (currentPrice == null) {
        unavailable++;
        updated.add(item.copyWith(unavailable: true, priceChanged: false));
        continue;
      }

      if (currentPrice != item.price) {
        priceChanged++;
        updated.add(
          item.copyWith(
            unavailable: false,
            priceChanged: true,
            price: currentPrice,
          ),
        );
      } else {
        updated.add(item.copyWith(unavailable: false, priceChanged: false));
      }
    }

    return SHOCartReconcileReport(
      unavailableCount: unavailable,
      priceChangedCount: priceChanged,
      updatedItems: updated,
    );
  }
}
