import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/hos_config.dart';
import '../logging/hos_logger.dart';
import '../storage/hos_image_cache_manager.dart';
import '../storage/hos_local_storage.dart';
import '../debug/modules/activity/hos_debug_activity_config.dart';
import 'hos_activity_popup_service.dart';

const activityPrefetchConfigPrefix = 'activity_prefetch_config_';
const activityPrefetchImagePrefix = 'activity_prefetch_image_';

final activityPrefetchServiceProvider = Provider<SHOActivityPrefetchService>((ref) {
  return SHOActivityPrefetchService(ref.watch(localStorageProvider));
});

/// 活动预拉取：提前下载图片并缓存活动配置到本地。
class SHOActivityPrefetchService {
  SHOActivityPrefetchService(this._storage);

  final SHOLocalStorage _storage;

  Future<void> prefetch(SHOActivityPopup activity) async {
    if (!activity.prefetchEnabled) return;

    await _storage.write(
      '$activityPrefetchConfigPrefix${activity.id}',
      jsonEncode(activity.toJson()),
    );

    try {
      final file = await SHOImageCacheManager.instance.downloadFile(activity.imageUrl);
      await _storage.write('$activityPrefetchImagePrefix${activity.id}', file.file.path);
      SHOAppLogger.info('Activity prefetch ok: ${activity.id}');
    } catch (e) {
      SHOAppLogger.warn('Activity prefetch image failed: $e');
    }
  }

  Future<void> prefetchFromDebug(SHODebugActivityConfig config) async {
    if (!SHOAppConfig.instance.isDebugPanelEnabled) return;
    await prefetch(config.toActivityPopup());
  }

  Future<SHOActivityPopup?> loadPrefetched(String id) async {
    final raw = await _storage.read<String>('$activityPrefetchConfigPrefix$id');
    if (raw == null) return null;
    try {
      final popup = SHOActivityPopup.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      final localPath = await _storage.read<String>('$activityPrefetchImagePrefix$id');
      if (localPath != null) {
        return popup.copyWith(cachedImagePath: localPath);
      }
      return popup;
    } catch (_) {
      return null;
    }
  }
}
