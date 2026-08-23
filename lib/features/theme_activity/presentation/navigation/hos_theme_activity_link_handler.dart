import 'package:flutter/material.dart';
import 'package:shoo/app/router/hos_route_navigator.dart';
import 'package:shoo/core/deeplink/hos_deeplink_resolver.dart';
import 'package:shoo/features/theme_activity/presentation/analytics/hos_theme_activity_analytics.dart';
import 'package:shoo/features/theme_activity/presentation/analytics/hos_theme_activity_tracking_scope.dart';

/// ThemeActivity 内所有「打开新页面」点击的统一出口。
abstract final class SHOThemeActivityLinkHandler {
  static Future<void> open(
    BuildContext context,
    String? link, {
    String? moduleId,
    String? itemId,
  }) async {
    final trimmed = link?.trim() ?? '';
    if (trimmed.isEmpty) return;

    final scope = SHOThemeActivityTrackingScope.maybeOf(context);
    final resolved = SHODeepLinkResolver.resolveLink(trimmed);
    if (scope != null) {
      await SHOThemeActivityAnalytics.trackLinkClick(
        activityId: scope.activityId,
        link: trimmed,
        moduleId: moduleId,
        itemId: itemId,
        resolvedActionType: resolved?.type.name,
        channel: scope.channel,
      );
    }

    if (!context.mounted) return;
    await SHORouteNavigator.followLink(context, trimmed);
  }
}
