import 'package:flutter/foundation.dart';

import '../logging/hos_logger.dart';
import 'hos_analytics_backend.dart';
import 'hos_analytics_backends.dart';
import 'hos_analytics_event.dart';
import 'hos_analytics_registry.dart';

/// 业务上报管理器：统一 key、字段校验、多通道分发，支持扩展 Backend。
class SHOAnalyticsManager {
  SHOAnalyticsManager._();

  static final SHOAnalyticsManager instance = SHOAnalyticsManager._();

  static const _historyLimit = 50;

  final List<SHOAnalyticsBackend> _backends = [
    const SHOAnalyticsConsoleBackend(),
    const SHOAnalyticsLogCacheBackend(),
    SHOAnalyticsMockRemoteBackend(),
    const SHOAnalyticsRemoteBackend(),
  ];

  final List<SHOAnalyticsRecord> _history = [];

  List<SHOAnalyticsEventDef> get events => SHOAnalyticsRegistry.all;

  List<SHOAnalyticsBackend> get backends => List.unmodifiable(_backends);

  List<SHOAnalyticsRecord> get history => List.unmodifiable(_history);

  SHOAnalyticsMockRemoteBackend? get mockRemoteBackend {
    for (final backend in _backends) {
      if (backend is SHOAnalyticsMockRemoteBackend) return backend;
    }
    return null;
  }

  SHOAnalyticsRemoteBackend? get remoteBackend {
    for (final backend in _backends) {
      if (backend is SHOAnalyticsRemoteBackend) return backend;
    }
    return null;
  }

  void registerBackend(SHOAnalyticsBackend backend) {
    if (_backends.any((b) => b.id == backend.id)) return;
    _backends.add(backend);
  }

  void unregisterBackend(String backendId) {
    _backends.removeWhere((b) => b.id == backendId);
  }

  /// 按事件 key 上报；未知 key 在 Debug 下告警但仍尝试分发。
  Future<void> track(
    String eventKey,
    Map<String, Object?> params, {
    bool validate = true,
  }) async {
    final registered = SHOAnalyticsRegistry.find(eventKey);
    final event = registered ??
        SHOAnalyticsEventDef(
          key: eventKey,
          title: eventKey,
          fields: const [],
        );

    if (registered == null) {
      SHOAppLogger.warn('Unknown analytics event: $eventKey');
    }

    if (validate && registered != null) {
      final error = registered.validateParams(params);
      if (error != null) {
        SHOAppLogger.warn('Analytics validation failed: $error');
        _pushHistory(
          SHOAnalyticsRecord(
            eventKey: eventKey,
            params: params,
            timestamp: DateTime.now(),
            backendIds: const [],
            error: error,
          ),
        );
        if (kDebugMode) return;
      }
    }

    final enabledBackends = _backends.where((b) => b.enabled).toList();
    final backendIds = <String>[];

    for (final backend in enabledBackends) {
      try {
        await backend.report(event, params);
        backendIds.add(backend.id);
      } catch (error, stack) {
        SHOAppLogger.error('Analytics backend ${backend.id} failed', error, stack);
      }
    }

    _pushHistory(
      SHOAnalyticsRecord(
        eventKey: eventKey,
        params: params,
        timestamp: DateTime.now(),
        backendIds: backendIds,
      ),
    );
  }

  /// 便捷方法：按注册表事件定义上报。
  Future<void> trackEvent(
    SHOAnalyticsEventDef event,
    Map<String, Object?> params,
  ) {
    return track(event.key, params);
  }

  void clearHistory() => _history.clear();

  void _pushHistory(SHOAnalyticsRecord record) {
    _history.insert(0, record);
    if (_history.length > _historyLimit) {
      _history.removeRange(_historyLimit, _history.length);
    }
  }
}
