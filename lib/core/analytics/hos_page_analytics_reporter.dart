import 'package:flutter/widgets.dart';

import 'hos_analytics_manager.dart';
import 'hos_analytics_registry.dart';
import 'hos_page_analytics_action.dart';
import 'hos_page_route_info.dart';

/// 页面与路由栈埋点统一上报入口。
abstract final class SHOPageAnalyticsReporter {
  static String? _lastVisibleRoutePath;

  static String? get lastVisibleRoutePath => _lastVisibleRoutePath;

  /// [RouteAware] 单页可见性上报。
  static Future<void> reportPageAction({
    required SHOPageAnalyticsAction action,
    required SHOPageRouteInfo info,
    Map<String, Object?> extra = const {},
  }) {
    if (action == SHOPageAnalyticsAction.enter ||
        action == SHOPageAnalyticsAction.resume) {
      _lastVisibleRoutePath = info.routePath;
    } else if (action == SHOPageAnalyticsAction.exit) {
      _lastVisibleRoutePath = info.previousRoutePath;
    }

    final event = switch (action) {
      SHOPageAnalyticsAction.enter => SHOAnalyticsRegistry.pageEnter,
      SHOPageAnalyticsAction.exit => SHOAnalyticsRegistry.pageExit,
      SHOPageAnalyticsAction.cover => SHOAnalyticsRegistry.pageCover,
      SHOPageAnalyticsAction.resume => SHOAnalyticsRegistry.pageResume,
    };

    return SHOAnalyticsManager.instance.trackEvent(
      event,
      info.toParams(extra: extra),
    );
  }

  /// [NavigatorObserver] 栈级 push / pop / replace / remove 上报。
  static Future<void> reportNavigatorAction({
    required SHORouteNavigatorAction action,
    required SHOPageRouteInfo routeInfo,
    SHOPageRouteInfo? previousRouteInfo,
    String navigatorId = 'root',
  }) {
    final event = switch (action) {
      SHORouteNavigatorAction.push => SHOAnalyticsRegistry.routePush,
      SHORouteNavigatorAction.pop => SHOAnalyticsRegistry.routePop,
      SHORouteNavigatorAction.replace => SHOAnalyticsRegistry.routeReplace,
      SHORouteNavigatorAction.remove => SHOAnalyticsRegistry.routeRemove,
    };

    final params = <String, Object?>{
      'navigator_id': navigatorId,
      'route_path': routeInfo.routePath,
      if (routeInfo.routeName != null) 'route_name': routeInfo.routeName,
      if (previousRouteInfo != null)
        'previous_route_path': previousRouteInfo.routePath,
    };

    if (action == SHORouteNavigatorAction.push) {
      _lastVisibleRoutePath = routeInfo.routePath;
    } else if (action == SHORouteNavigatorAction.pop &&
        previousRouteInfo != null) {
      _lastVisibleRoutePath = previousRouteInfo.routePath;
    }

    return SHOAnalyticsManager.instance.trackEvent(event, params);
  }

  /// 解析上一路由 path，优先用 Navigator 回调参数，否则用全局缓存。
  static String? resolvePreviousRoutePath(Route<dynamic>? previousRoute) {
    if (previousRoute != null) {
      return SHOPageRouteInfo.fromRoute(previousRoute).routePath;
    }
    return _lastVisibleRoutePath;
  }
}
