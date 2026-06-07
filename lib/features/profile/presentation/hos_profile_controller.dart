import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/hos_session_provider.dart';
import '../../home/domain/hos_product.dart';
import '../../order/data/hos_order_repository.dart';
import '../../order/domain/hos_order.dart';
import '../../product/data/hos_product_api.dart' show productApiProvider;
import '../data/hos_profile_activity_storage.dart';
import '../domain/hos_profile_activity_product.dart';

enum SHOProfileFeedTab { guessYouLike, favorites, reviews }

enum SHOProfileActivityListKind { footprints, favorites }

final profileFeedTabProvider =
    StateProvider<SHOProfileFeedTab>((ref) => SHOProfileFeedTab.guessYouLike);

final profileActivityProvider =
    StateNotifierProvider<SHOProfileActivityNotifier, SHOProfileActivitySnapshot>(
  (ref) => SHOProfileActivityNotifier(ref.watch(profileActivityStorageProvider)),
);

class SHOProfileActivityNotifier extends StateNotifier<SHOProfileActivitySnapshot> {
  SHOProfileActivityNotifier(this._storage) : super(_storage.read());

  final SHOProfileActivityStorage _storage;

  Future<void> refresh() async {
    state = _storage.read();
  }

  Future<void> recordFootprint(
    String productId, {
    SHOProfileProductCache? cache,
  }) async {
    state = await _storage.recordFootprint(productId, cache: cache);
  }

  Future<bool> toggleFavorite(
    String productId, {
    SHOProfileProductCache? cache,
  }) async {
    state = await _storage.toggleFavorite(productId, cache: cache);
    return state.favorites.contains(productId);
  }

  Future<void> recordFollowedCategory(String categoryId) async {
    state = await _storage.recordFollowedCategory(categoryId);
  }

  Future<void> removeFootprints(Iterable<String> productIds) async {
    state = await _storage.removeFootprints(productIds);
  }

  Future<void> removeFavorites(Iterable<String> productIds) async {
    state = await _storage.removeFavorites(productIds);
  }

  bool isFavorite(String productId) => state.favorites.contains(productId);
}

final profileQuickStatsProvider = Provider<SHOProfileQuickStats>((ref) {
  final authed = ref.watch(sessionProvider).isAuthenticated;
  if (!authed) return const SHOProfileQuickStats();

  final activity = ref.watch(profileActivityProvider);
  final orderCounts = ref.watch(profileOrderCountsProvider).maybeWhen(
        data: (counts) => counts.values.fold<int>(0, (sum, n) => sum + n),
        orElse: () => 0,
      );

  return SHOProfileQuickStats(
    footprints: activity.footprintCount,
    favorites: activity.favoriteCount,
    following: activity.followingCount,
    orders: orderCounts,
    showDiscoverBadge: activity.followingCount > 0,
  );
});

class SHOProfileQuickStats {
  const SHOProfileQuickStats({
    this.footprints = 0,
    this.favorites = 0,
    this.following = 0,
    this.orders = 0,
    this.showDiscoverBadge = false,
  });

  final int footprints;
  final int favorites;
  final int following;
  final int orders;
  final bool showDiscoverBadge;
}

final profileOrderCountsProvider =
    FutureProvider<Map<SHOOrderStatus, int>>((ref) async {
  if (!ref.watch(sessionProvider).isAuthenticated) {
    return {};
  }
  final page = await ref.watch(orderRepositoryProvider).getOrdersPage(
        page: 1,
        pageSize: 100,
      );
  final counts = <SHOOrderStatus, int>{};
  for (final order in page.items) {
    counts[order.status] = (counts[order.status] ?? 0) + 1;
  }
  return counts;
});

Future<List<SHOProfileActivityProduct>> _resolveActivityProducts({
  required List<String> ids,
  required Map<String, SHOProfileProductCache> cache,
  required Future<SHOProduct> Function(String id) fetchProduct,
}) async {
  final products = <SHOProfileActivityProduct>[];
  for (final id in ids) {
    try {
      final product = await fetchProduct(id);
      products.add(
        SHOProfileActivityProduct(product: product, available: true),
      );
    } catch (_) {
      final cached = cache[id];
      if (cached != null) {
        products.add(
          SHOProfileActivityProduct.fromCache(
            productId: id,
            cache: cached,
            available: false,
          ),
        );
      } else {
        products.add(
          SHOProfileActivityProduct(
            available: false,
            product: SHOProduct(
              id: id,
              title: id,
              imageUrl: '',
              price: 0,
              originalPrice: 0,
              rating: 0,
            ),
          ),
        );
      }
    }
  }
  return products;
}

Future<SHOProduct> _fetchListProduct(
  Ref ref,
  String id,
) async {
  final detail = await ref.watch(productApiProvider).fetchProductDetail(id);
  return SHOProduct(
    id: detail.id,
    title: detail.title,
    imageUrl: detail.imageUrl,
    price: detail.price,
    originalPrice: detail.originalPrice,
    discountLabel: detail.discountLabel,
    rating: detail.rating,
    soldCount: detail.soldCount,
  );
}

final profileFootprintActivityProductsProvider =
    FutureProvider.autoDispose<List<SHOProfileActivityProduct>>((ref) async {
  final activity = ref.watch(profileActivityProvider);
  if (activity.footprints.isEmpty) return const [];

  return _resolveActivityProducts(
    ids: activity.footprints,
    cache: activity.productCache,
    fetchProduct: (id) => _fetchListProduct(ref, id),
  );
});

final profileFavoriteActivityProductsProvider =
    FutureProvider.autoDispose<List<SHOProfileActivityProduct>>((ref) async {
  final activity = ref.watch(profileActivityProvider);
  if (activity.favorites.isEmpty) return const [];

  return _resolveActivityProducts(
    ids: activity.favorites,
    cache: activity.productCache,
    fetchProduct: (id) => _fetchListProduct(ref, id),
  );
});
