import 'dart:convert';

import '../../../core/analytics/hos_analytics.dart';
import '../domain/hos_download_task.dart';

abstract final class SHODownloadClickReporter {
  static Map<String, Object?> _clickFields(SHODownloadTask task) => {
        'download_url': task.url,
        'download_time': task.createdAt.toIso8601String(),
        'file_type': task.fileType.name,
        'file_id': task.id,
        'resource_name': task.fileName,
      };

  static Future<void> reportClick(SHODownloadTask task) {
    return SHOAnalyticsManager.instance.trackEvent(
      SHOAnalyticsRegistry.downloadItemClick,
      {'payload': jsonEncode(_clickFields(task))},
    );
  }

  static Map<String, Object?> _musicPackPathsPayload(
    SHODownloadTask task,
    List<String> extractPaths,
  ) =>
      {
        'resource_name': task.fileName,
        'file_type': task.fileType.name,
        'file_id': task.id,
        'download_url': task.url,
        'extract_paths': extractPaths,
      };

  static Future<void> reportMusicExtract({
    required SHODownloadTask task,
    required List<String> extractPaths,
  }) async {
    if (extractPaths.isEmpty) return;

    return SHOAnalyticsManager.instance.trackEvent(
      SHOAnalyticsRegistry.musicPackExtract,
      {'payload': jsonEncode(_musicPackPathsPayload(task, extractPaths))},
    );
  }

  static Future<void> reportMusicAlreadyExtracted({
    required SHODownloadTask task,
    required List<String> extractPaths,
  }) async {
    if (extractPaths.isEmpty) return;

    return SHOAnalyticsManager.instance.trackEvent(
      SHOAnalyticsRegistry.musicPackAlreadyExtracted,
      {'payload': jsonEncode(_musicPackPathsPayload(task, extractPaths))},
    );
  }
}
