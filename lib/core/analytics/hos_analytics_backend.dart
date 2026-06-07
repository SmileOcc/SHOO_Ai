import 'hos_analytics_event.dart';

/// 业务上报通道（可扩展：控制台、本地日志、远程 SDK 等）。
abstract class SHOAnalyticsBackend {
  const SHOAnalyticsBackend();

  String get id;
  String get title;
  String get description;

  /// 是否在当前构建下启用。
  bool get enabled;

  Future<void> report(SHOAnalyticsEventDef event, Map<String, Object?> params);
}
