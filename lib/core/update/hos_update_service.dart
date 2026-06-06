import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/hos_config.dart';
import '../debug/core/hos_debug_config_repository.dart';
import '../debug/modules/update/hos_debug_update_config.dart';
import '../network/hos_dio_client.dart';
import '../logging/hos_logger.dart';
import '../utils/hos_version_utils.dart';

final appUpdateServiceProvider = Provider<SHOAppUpdateService>((ref) {
  return SHOAppUpdateService(ref.watch(dioProvider), ref);
});

class SHOAppUpdateInfo {
  const SHOAppUpdateInfo({
    required this.hasUpdate,
    required this.latestVersion,
    required this.forceUpdate,
    required this.updateUrl,
    required this.releaseNotes,
    required this.currentVersion,
  });

  final bool hasUpdate;
  final String latestVersion;
  final bool forceUpdate;
  final String updateUrl;
  final String releaseNotes;
  final String currentVersion;
}

/// 检查更新服务（Mock API + 版本比对）。
class SHOAppUpdateService {
  SHOAppUpdateService(this._dio, this._ref);

  final Dio _dio;
  final Ref _ref;

  Future<SHOAppUpdateInfo> checkUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final current = packageInfo.version;

    final debug = await _loadActiveDebugOverride();
    if (debug != null) {
      final hasUpdate = SHOVersionUtils.hasUpdate(current, debug.latestVersion);
      return SHOAppUpdateInfo(
        hasUpdate: hasUpdate,
        latestVersion: debug.latestVersion,
        forceUpdate: debug.forceUpdate,
        updateUrl: debug.updateUrl,
        releaseNotes: debug.releaseNotes,
        currentVersion: current,
      );
    }

    final remote = await _dio.getData<Map<String, dynamic>>(
      '/app/version',
      parser: (data) => data as Map<String, dynamic>,
    );

    final latest = remote['latestVersion'] as String? ?? current;
    final minVersion = remote['minVersion'] as String? ?? current;
    final hasUpdate = SHOVersionUtils.hasUpdate(current, latest);
    final forceUpdate = SHOVersionUtils.compare(current, minVersion) < 0;

    return SHOAppUpdateInfo(
      hasUpdate: hasUpdate,
      latestVersion: latest,
      forceUpdate: forceUpdate,
      updateUrl: remote['updateUrl'] as String? ?? '',
      releaseNotes: remote['releaseNotes'] as String? ?? '',
      currentVersion: current,
    );
  }

  /// 从本地存储读取最新调试配置，避免 Provider 异步恢复导致未生效。
  Future<SHODebugUpdateConfig?> _loadActiveDebugOverride() async {
    if (!SHOAppConfig.instance.isDebugPanelEnabled) return null;

    final config = await _ref.read(debugConfigRepositoryProvider).loadUpdateConfig();
    if (!config.overrideEnabled) return null;

    SHOAppLogger.debug(
      'Update check using debug override: ${config.latestVersion}, force=${config.forceUpdate}',
    );
    return config;
  }

  Future<void> openUpdateUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      SHOAppLogger.warn('Cannot launch update url: $url');
    }
  }
}
