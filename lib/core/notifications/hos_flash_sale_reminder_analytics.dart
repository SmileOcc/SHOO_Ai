import 'package:shoo/core/analytics/hos_analytics_manager.dart';
import 'package:shoo/core/analytics/hos_analytics_registry.dart';
import 'package:shoo/core/logging/hos_logger.dart';
import 'package:shoo/core/notifications/hos_flash_sale_reminder_nav.dart';
import 'package:shoo/core/notifications/hos_flash_sale_reminder_service.dart';

/// 抢购提醒通知 / 弹窗埋点。
abstract final class SHOFlashSaleReminderAnalytics {
  static Map<String, Object?> payloadParams(
    SHOFlashSaleReminderPayload payload, {
    String? rawPayload,
  }) {
    return {
      'session_id': payload.sessionId,
      'product_id': payload.productId,
      'activity_id': SHOFlashSaleReminderNav.normalizeActivityId(
        payload.activityId,
      ),
      'title': payload.title,
      if (rawPayload != null && rawPayload.isNotEmpty) 'raw_payload': rawPayload,
    };
  }

  static Future<void> trackReceive({
    required String rawPayload,
    required String source,
  }) async {
    final parsed = SHOFlashSaleReminderNav.parsePayload(rawPayload);
    if (parsed == null) {
      SHOAppLogger.w(
        '[ANALYTICS] flash_sale_notification_receive skipped: invalid payload',
      );
      return;
    }

    SHOAppLogger.d('[ANALYTICS] flash_sale_notification_receive source=$source');
    await SHOAnalyticsManager.instance.trackEvent(
      SHOAnalyticsRegistry.flashSaleNotificationReceive,
      {
        ...payloadParams(parsed, rawPayload: rawPayload),
        'source': source,
      },
    );
  }

  static Future<void> trackClick({
    required String rawPayload,
    required String source,
  }) async {
    final parsed = SHOFlashSaleReminderNav.parsePayload(rawPayload);
    if (parsed == null) {
      SHOAppLogger.w(
        '[ANALYTICS] flash_sale_notification_click skipped: invalid payload',
      );
      return;
    }

    SHOAppLogger.d('[ANALYTICS] flash_sale_notification_click source=$source');
    await SHOAnalyticsManager.instance.trackEvent(
      SHOAnalyticsRegistry.flashSaleNotificationClick,
      {
        ...payloadParams(parsed, rawPayload: rawPayload),
        'source': source,
      },
    );
  }

  static Future<void> trackPopupShow({
    required SHOFlashSaleReminderPayload payload,
    required String trigger,
  }) async {
    await SHOAnalyticsManager.instance.trackEvent(
      SHOAnalyticsRegistry.flashSaleReminderPopupShow,
      {
        ...payloadParams(payload),
        'trigger': trigger,
      },
    );
  }

  static Future<void> trackPopupAction({
    required SHOFlashSaleReminderPayload payload,
    required String action,
  }) async {
    await SHOAnalyticsManager.instance.trackEvent(
      SHOAnalyticsRegistry.flashSaleReminderPopupAction,
      {
        ...payloadParams(payload),
        'action': action,
      },
    );
  }
}
