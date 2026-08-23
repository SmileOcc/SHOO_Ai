import 'package:shoo/core/analytics/hos_analytics_manager.dart';
import 'package:shoo/core/analytics/hos_analytics_registry.dart';
import 'package:shoo/core/config/hos_config.dart';
import 'package:shoo/core/logging/hos_logger.dart';

/// ThemeActivity 业务埋点（配置加载、刷新、链接点击、分享、分页、领券）。
abstract final class SHOThemeActivityAnalytics {
  static String get _configSource =>
      SHOAppConfig.instance.useMockApi ? 'mock' : 'remote';

  static Future<void> trackConfigLoad({
    required String activityId,
    required bool success,
    required int durationMs,
    String? channel,
    String? error,
  }) async {
    SHOAppLogger.d(
      '[ThemeActivity] config_load $activityId success=$success ${durationMs}ms',
    );
    await SHOAnalyticsManager.instance.trackEvent(
      SHOAnalyticsRegistry.themeActivityConfigLoad,
      {
        'activity_id': activityId,
        'success': success,
        'duration_ms': durationMs,
        'source': _configSource,
        if (channel != null && channel.isNotEmpty) 'channel': channel,
        if (error != null && error.isNotEmpty) 'error': error,
      },
    );
  }

  static Future<void> trackRefresh({
    required String activityId,
    required bool success,
    required int durationMs,
    String? channel,
  }) async {
    await SHOAnalyticsManager.instance.trackEvent(
      SHOAnalyticsRegistry.themeActivityRefresh,
      {
        'activity_id': activityId,
        'success': success,
        'duration_ms': durationMs,
        'source': _configSource,
        if (channel != null && channel.isNotEmpty) 'channel': channel,
      },
    );
  }

  static Future<void> trackLinkClick({
    required String activityId,
    required String link,
    String? moduleId,
    String? itemId,
    String? resolvedActionType,
    String? channel,
  }) async {
    await SHOAnalyticsManager.instance.trackEvent(
      SHOAnalyticsRegistry.themeActivityLinkClick,
      {
        'activity_id': activityId,
        'link': link,
        if (moduleId != null && moduleId.isNotEmpty) 'module_id': moduleId,
        if (itemId != null && itemId.isNotEmpty) 'item_id': itemId,
        if (resolvedActionType != null && resolvedActionType.isNotEmpty)
          'resolved_action_type': resolvedActionType,
        if (channel != null && channel.isNotEmpty) 'channel': channel,
      },
    );
  }

  static Future<void> trackShare({
    required String activityId,
    String? channel,
  }) async {
    await SHOAnalyticsManager.instance.trackEvent(
      SHOAnalyticsRegistry.themeActivityShare,
      {
        'activity_id': activityId,
        if (channel != null && channel.isNotEmpty) 'channel': channel,
      },
    );
  }

  static Future<void> trackFooterLoadMore({
    required String activityId,
    required int page,
    required bool success,
    String? channel,
  }) async {
    await SHOAnalyticsManager.instance.trackEvent(
      SHOAnalyticsRegistry.themeActivityFooterLoadMore,
      {
        'activity_id': activityId,
        'page': page,
        'success': success,
        if (channel != null && channel.isNotEmpty) 'channel': channel,
      },
    );
  }

  static Future<void> trackCouponClaim({
    required String activityId,
    required String couponId,
    required bool success,
    String? moduleId,
    String? channel,
  }) async {
    await SHOAnalyticsManager.instance.trackEvent(
      SHOAnalyticsRegistry.themeActivityCouponClaim,
      {
        'activity_id': activityId,
        'coupon_id': couponId,
        'success': success,
        if (moduleId != null && moduleId.isNotEmpty) 'module_id': moduleId,
        if (channel != null && channel.isNotEmpty) 'channel': channel,
      },
    );
  }
}
