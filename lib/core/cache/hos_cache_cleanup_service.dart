import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../constants/hos_constants.dart';
import '../logging/hos_log_manager.dart';
import '../marketing/hos_activity_prefetch_service.dart';
import '../storage/hos_image_cache_manager.dart';
import '../storage/hos_local_storage.dart';
import '../../features/cart/data/hos_cart_storage.dart';
import '../../features/search/data/hos_search_history_storage.dart';

enum SHOCacheCategory {
  logs,
  images,
  searchHistory,
  cart,
  activityPrefetch,
  appPreferences,
}

class SHOCacheCategoryInfo {
  const SHOCacheCategoryInfo({
    required this.category,
    required this.titleKey,
    required this.subtitleKey,
  });

  final SHOCacheCategory category;
  final String titleKey;
  final String subtitleKey;
}

final cacheCleanupServiceProvider = Provider<SHOCacheCleanupService>((ref) {
  return SHOCacheCleanupService(
    ref.watch(localStorageProvider),
    ref.watch(cartStorageProvider),
    ref.watch(searchHistoryStorageProvider),
  );
});

class SHOCacheCleanupService {
  SHOCacheCleanupService(
    this._storage,
    this._cartStorage,
    this._searchHistoryStorage,
  );

  final SHOLocalStorage _storage;
  final SHOCartStorage _cartStorage;
  final SHOSearchHistoryStorage _searchHistoryStorage;

  static const categories = [
    SHOCacheCategoryInfo(
      category: SHOCacheCategory.logs,
      titleKey: 'settingsCacheLogs',
      subtitleKey: 'settingsCacheLogsHint',
    ),
    SHOCacheCategoryInfo(
      category: SHOCacheCategory.images,
      titleKey: 'settingsCacheImages',
      subtitleKey: 'settingsCacheImagesHint',
    ),
    SHOCacheCategoryInfo(
      category: SHOCacheCategory.searchHistory,
      titleKey: 'settingsCacheSearch',
      subtitleKey: 'settingsCacheSearchHint',
    ),
    SHOCacheCategoryInfo(
      category: SHOCacheCategory.cart,
      titleKey: 'settingsCacheCart',
      subtitleKey: 'settingsCacheCartHint',
    ),
    SHOCacheCategoryInfo(
      category: SHOCacheCategory.activityPrefetch,
      titleKey: 'settingsCacheActivity',
      subtitleKey: 'settingsCacheActivityHint',
    ),
    SHOCacheCategoryInfo(
      category: SHOCacheCategory.appPreferences,
      titleKey: 'settingsCachePreferences',
      subtitleKey: 'settingsCachePreferencesHint',
    ),
  ];

  Future<Map<SHOCacheCategory, int>> loadSizes() async {
    return {
      SHOCacheCategory.logs: await SHOAppLogManager.instance.cachedByteSize(),
      SHOCacheCategory.images: await _imageCacheBytes(),
      SHOCacheCategory.searchHistory: await _textKeyBytes(
        SHOAppConstants.searchHistoryKey,
      ),
      SHOCacheCategory.cart: await _textKeyBytes(SHOAppConstants.cartStorageKey),
      SHOCacheCategory.activityPrefetch: await _activityPrefetchBytes(),
      SHOCacheCategory.appPreferences: await _miscPreferenceBytes(),
    };
  }

  Future<int> totalBytes() async {
    final sizes = await loadSizes();
    return sizes.values.fold<int>(0, (sum, v) => sum + v);
  }

  Future<void> clear(SHOCacheCategory category) async {
    switch (category) {
      case SHOCacheCategory.logs:
        await SHOAppLogManager.instance.clear();
      case SHOCacheCategory.images:
        try {
          await SHOImageCacheManager.instance.emptyCache();
        } catch (error) {
          if (SHOImageCacheManager.isReadonlyDbError(error)) {
            await SHOImageCacheManager.recoverFromReadonlyError(error: error);
          } else {
            rethrow;
          }
        }
      case SHOCacheCategory.searchHistory:
        await _searchHistoryStorage.clear();
      case SHOCacheCategory.cart:
        await _cartStorage.clear();
      case SHOCacheCategory.activityPrefetch:
        await _clearActivityPrefetch();
      case SHOCacheCategory.appPreferences:
        await _storage.clear();
    }
  }

  Future<void> clearAll() async {
    for (final item in categories) {
      await clear(item.category);
    }
  }

  Future<int> _imageCacheBytes() async {
    try {
      final supportDir = await getApplicationSupportDirectory();
      final cacheDir = Directory(p.join(supportDir.path, 'shoo_image_cache'));
      if (!await cacheDir.exists()) return 0;
      return _directorySize(cacheDir);
    } catch (_) {
      return 0;
    }
  }

  Future<int> _directorySize(Directory dir) async {
    var total = 0;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) total += await entity.length();
    }
    return total;
  }

  Future<int> _textKeyBytes(String key) async {
    return _storage.estimateKeyBytes(key);
  }

  Future<int> _activityPrefetchBytes() async {
    var total = 0;
    for (final key in _storage.keys) {
      if (!key.startsWith(activityPrefetchConfigPrefix) &&
          !key.startsWith(activityPrefetchImagePrefix)) {
        continue;
      }
      total += _storage.estimateKeyBytes(key);
      if (key.startsWith(activityPrefetchImagePrefix)) {
        final path = _storage.readSync<String>(key);
        if (path != null) {
          final file = File(path);
          if (await file.exists()) total += await file.length();
        }
      }
    }
    return total;
  }

  Future<int> _miscPreferenceBytes() async {
    const preserved = {
      SHOAppConstants.themeModeKey,
      SHOAppConstants.localeKey,
      SHOAppConstants.debugEnvOverrideKey,
      SHOAppConstants.debugShowEnvBadgeKey,
      SHOAppConstants.searchHistoryKey,
      SHOAppConstants.cartStorageKey,
    };
    var total = 0;
    for (final key in _storage.keys) {
      if (preserved.contains(key)) continue;
      if (key.startsWith(activityPrefetchConfigPrefix) ||
          key.startsWith(activityPrefetchImagePrefix)) {
        continue;
      }
      total += _storage.estimateKeyBytes(key);
    }
    return total;
  }

  Future<void> _clearActivityPrefetch() async {
    for (final key in _storage.keys.toList()) {
      if (!key.startsWith(activityPrefetchConfigPrefix) &&
          !key.startsWith(activityPrefetchImagePrefix)) {
        continue;
      }
      final path = _storage.readSync<String>(key);
      await _storage.remove(key);
      if (path != null &&
          key.startsWith(activityPrefetchImagePrefix) &&
          await File(path).exists()) {
        await File(path).delete();
      }
    }
  }
}
