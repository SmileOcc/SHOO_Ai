import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/home/domain/entities/hos_banner.dart';
import 'package:shoo/features/home/domain/entities/hos_home_config.dart';
import 'package:shoo/features/home/domain/entities/hos_product.dart';
import 'package:shoo/features/home/data/datasources/remote/hos_home_remote_ds.dart';

final homeRepositoryProvider = Provider<SHOHomeRepository>((ref) {
  return SHOHomeRepository(ref.watch(homeApiProvider));
});

class SHOHomeRepository {
  SHOHomeRepository(this._api);

  final SHOHomeApi _api;

  Future<List<SHOBannerItem>> getBanners() => _api.fetchBanners();

  Future<List<SHOHomeQuickEntry>> getQuickEntries() async {
    try {
      final items = await _api.fetchQuickEntries();
      if (items.isNotEmpty) return items;
      if (kDebugMode) {
        debugPrint(
          '[SHOO] home-quick-entries returned empty; using local fallback',
        );
      }
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('[SHOO] home-quick-entries failed: $error');
        debugPrint('$stack');
      }
    }
    return _fallbackQuickEntries;
  }

  Future<SHOHomeFeedConfig> getFeedConfig() async {
    try {
      return await _api.fetchFeedConfig();
    } catch (_) {
      return SHOHomeFeedConfig.fallback;
    }
  }

  Future<List<SHOProduct>> getRecommendedProducts({
    SHOHomeFeedConfig? config,
  }) async {
    final feed = config ?? await getFeedConfig();
    final pageSize = feed.pageSize <= 0 ? 50 : feed.pageSize;

    switch (feed.mode) {
      case 'category':
        if (feed.categoryId.isEmpty) break;
        final page = await _api.fetchProducts(
          pageSize: pageSize,
          categoryId: feed.categoryId,
        );
        return page.items;
      case 'productIds':
        if (feed.productIds.isEmpty) break;
        return _api.fetchProductsBatch(feed.productIds);
      case 'latest':
      default:
        break;
    }

    final page = await _api.fetchProducts(pageSize: pageSize);
    return page.items;
  }
}

const _fallbackQuickEntries = <SHOHomeQuickEntry>[
  SHOHomeQuickEntry(
    id: 'home-flash',
    title: '抢购活动',
    icon: '⚡',
    link: '/flash-sale?activityId=activity_flash_001',
  ),
  SHOHomeQuickEntry(
    id: 'home-discount',
    title: '折扣活动',
    icon: '🏷️',
    link: '/flash-sale?activityId=activity_discount_001',
    sort: 1,
  ),
];
