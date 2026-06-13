import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 从 [BuildContext] / [Route] 解析出的页面路由信息，用于埋点 payload。
class SHOPageRouteInfo {
  const SHOPageRouteInfo({
    required this.pageName,
    required this.routePath,
    this.routeUri,
    this.routeName,
    this.previousRoutePath,
  });

  /// 业务页面名，通常为 Widget 类名或显式传入的 pageName。
  final String pageName;

  /// go_router matched location，例如 `/toolbox/downloads`。
  final String routePath;

  /// 完整 URI（含 query），例如 `/toolbox/music?trackId=1`。
  final String? routeUri;

  /// [RouteSettings.name]，GoRouter 可能为空。
  final String? routeName;

  /// 上一个可见路由 path，用于串联浏览路径。
  final String? previousRoutePath;

  Map<String, Object?> toParams({Map<String, Object?>? extra}) {
    return {
      'page_name': pageName,
      'route_path': routePath,
      if (routeUri != null && routeUri!.isNotEmpty) 'route_uri': routeUri,
      if (routeName != null && routeName!.isNotEmpty) 'route_name': routeName,
      if (previousRoutePath != null && previousRoutePath!.isNotEmpty)
        'previous_route_path': previousRoutePath,
      if (extra != null) ...extra,
    };
  }

  /// 从 [context] 解析；若不在路由树中则返回 null。
  static SHOPageRouteInfo? tryFromContext(
    BuildContext context, {
    required String pageName,
    String? previousRoutePath,
  }) {
    final route = ModalRoute.of(context);
    if (route == null) return null;

    String routePath = _routeLabel(route);
    String? routeUri;
    String? routeName = route.settings.name;

    try {
      final state = GoRouterState.of(context);
      routePath = state.matchedLocation;
      routeUri = state.uri.toString();
      routeName ??= state.name;
    } catch (_) {
      // 非 GoRouter 子树（如 Dialog）时仅用 RouteSettings。
    }

    return SHOPageRouteInfo(
      pageName: pageName,
      routePath: routePath,
      routeUri: routeUri,
      routeName: routeName,
      previousRoutePath: previousRoutePath,
    );
  }

  /// 从 [Route] 解析栈级信息（NavigatorObserver 无 BuildContext 时使用）。
  static SHOPageRouteInfo fromRoute(
    Route<dynamic> route, {
    String? previousRoutePath,
  }) {
    return SHOPageRouteInfo(
      pageName: _routeLabel(route),
      routePath: _routeLabel(route),
      routeName: route.settings.name,
      previousRoutePath: previousRoutePath,
    );
  }

  static String _routeLabel(Route<dynamic> route) {
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) return name;
    return route.settings.toString();
  }
}
