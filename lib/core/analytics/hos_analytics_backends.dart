import 'package:flutter/foundation.dart';

import '../debug/modules/network_log/hos_debug_network_log_config_bridge.dart';
import '../logging/hos_log_manager.dart';
import '../logging/hos_logger.dart';
import '../logging/hos_remote_log_base_url.dart';
import '../logging/hos_remote_log_uploader.dart';
import 'hos_analytics_backend.dart';
import 'hos_analytics_event.dart';

/// 控制台输出（Debug 构建默认启用）。
class SHOAnalyticsConsoleBackend extends SHOAnalyticsBackend {
  const SHOAnalyticsConsoleBackend();

  @override
  String get id => 'console';

  @override
  String get title => 'Console';

  @override
  String get description => 'Print analytics payload to debug console';

  @override
  bool get enabled => kDebugMode;

  @override
  Future<void> report(SHOAnalyticsEventDef event, Map<String, Object?> params) async {
    // ignore: avoid_print
    print('[SHOO][ANALYTICS] ${event.key} $params');
  }
}

/// 写入本地日志缓存（开发包全量；正式包走 LogManager 级别策略）。
class SHOAnalyticsLogCacheBackend extends SHOAnalyticsBackend {
  const SHOAnalyticsLogCacheBackend();

  @override
  String get id => 'log_cache';

  @override
  String get title => 'Log cache';

  @override
  String get description => 'Append analytics events to local log file';

  @override
  bool get enabled => true;

  @override
  Future<void> report(SHOAnalyticsEventDef event, Map<String, Object?> params) async {
    await SHOAppLogManager.instance.append(
      'INFO',
      '[ANALYTICS] ${event.key} $params',
    );
  }
}

/// Mock 远程上报（Debug 开启 Mock 时仅本地模拟，不真实发网）。
class SHOAnalyticsMockRemoteBackend extends SHOAnalyticsBackend {
  SHOAnalyticsMockRemoteBackend();

  final List<Map<String, Object?>> sent = [];

  @override
  String get id => 'mock_remote';

  @override
  String get title => 'Mock remote';

  @override
  String get description => 'Simulate HTTP analytics endpoint (debug only)';

  @override
  bool get enabled =>
      kDebugMode && SHODebugNetworkLogConfigBridge.config.useMockRemoteLog;

  @override
  Future<void> report(SHOAnalyticsEventDef event, Map<String, Object?> params) async {
    sent.add({
      'event': event.key,
      'params': params,
      'ts': DateTime.now().toIso8601String(),
    });
    // ignore: avoid_print
    print('[SHOO][ANALYTICS][MOCK_REMOTE] POST /v1/analytics/events ${event.key}');
  }
}

/// 真实远程上报（POST 到本地/当前环境 API Server）。
class SHOAnalyticsRemoteBackend extends SHOAnalyticsBackend {
  const SHOAnalyticsRemoteBackend();

  @override
  String get id => 'remote';

  @override
  String get title => 'Remote API';

  @override
  String get description => 'POST analytics events to server /analytics/events';

  @override
  bool get enabled =>
      kDebugMode && !SHODebugNetworkLogConfigBridge.config.useMockRemoteLog;

  @override
  Future<void> report(SHOAnalyticsEventDef event, Map<String, Object?> params) async {
    await SHORemoteLogUploader.uploadAnalytics(
      eventKey: event.key,
      params: params,
    );
    SHOAppLogger.debug(
      'Analytics remote upload',
      '${event.key} → ${SHORemoteLogBaseUrl.resolve()}${SHORemoteLogUploader.analyticsPath}',
    );
  }
}
