import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/notifications/hos_flash_sale_reminder_service.dart';
import 'package:shoo/features/flash_sale/domain/hos_flash_sale_activities.dart';

/// 抢购提醒通知 → 活动页路由与当前页比对。
abstract final class SHOFlashSaleReminderNav {
  static String normalizeActivityId(String? activityId) {
    if (activityId == null || activityId.isEmpty) {
      return SHOFlashSaleActivities.defaults;
    }
    return activityId;
  }

  static SHOFlashSaleReminderPayload? parsePayload(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split('|');
    if (parts.length < 2) return null;
    return SHOFlashSaleReminderPayload(
      sessionId: parts[0],
      productId: parts[1],
      title: parts.length > 2 ? parts[2] : '',
      imageUrl: parts.length > 3 ? parts[3] : '',
      sessionStartAt: parts.length > 4 ? parts[4] : '',
      activityId: parts.length > 5 && parts[5].isNotEmpty ? parts[5] : null,
    );
  }

  static String routeFor(SHOFlashSaleReminderPayload payload) {
    return SHOAppRoutes.flashSaleFor(
      activityId: normalizeActivityId(payload.activityId),
    );
  }

  static bool isOnSameActivity(
    GoRouter router,
    SHOFlashSaleReminderPayload payload,
  ) {
    final uri = router.state.uri;
    if (uri.path != SHOAppRoutes.flashSale) return false;
    final current = normalizeActivityId(uri.queryParameters['activityId']);
    final target = normalizeActivityId(payload.activityId);
    return current == target;
  }

  static void openActivity(
    GoRouter router,
    SHOFlashSaleReminderPayload payload,
  ) {
    router.push(routeFor(payload));
  }
}
