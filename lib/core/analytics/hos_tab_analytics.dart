import '../../app/router/hos_routes.dart';
import 'hos_analytics_manager.dart';
import 'hos_analytics_registry.dart';

/// 底部 Tab 与路由 path 映射（与 [SHOMainShell] 分支顺序一致）。
abstract final class SHOTabAnalyticsRoutes {
  static const routes = <String>[
    SHOAppRoutes.home,
    SHOAppRoutes.category,
    SHOAppRoutes.cart,
    SHOAppRoutes.profile,
  ];

  static String routeAt(int index) {
    if (index < 0 || index >= routes.length) return 'unknown';
    return routes[index];
  }

  static const tabIds = <String>['home', 'category', 'cart', 'profile'];

  static String tabIdAt(int index) {
    if (index < 0 || index >= tabIds.length) return 'unknown';
    return tabIds[index];
  }
}

/// Shell Tab 切换埋点（[StatefulShellRoute] indexedStack 不触发 push/pop）。
abstract final class SHOTabAnalyticsReporter {
  /// 用户点击底部 Tab 时上报；重复点击当前 Tab 时 [isReselect] 为 true。
  static Future<void> reportSwitch({
    required int fromIndex,
    required int toIndex,
    required bool isReselect,
  }) {
    return SHOAnalyticsManager.instance.trackEvent(
      SHOAnalyticsRegistry.tabSwitch,
      {
        'from_index': fromIndex,
        'to_index': toIndex,
        'from_route': SHOTabAnalyticsRoutes.routeAt(fromIndex),
        'to_route': SHOTabAnalyticsRoutes.routeAt(toIndex),
        'from_tab_id': SHOTabAnalyticsRoutes.tabIdAt(fromIndex),
        'to_tab_id': SHOTabAnalyticsRoutes.tabIdAt(toIndex),
        'is_reselect': isReselect,
      },
    );
  }
}
