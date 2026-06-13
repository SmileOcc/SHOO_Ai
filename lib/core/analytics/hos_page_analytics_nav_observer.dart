import 'package:flutter/material.dart';

import 'hos_page_analytics_action.dart';
import 'hos_page_analytics_reporter.dart';
import 'hos_page_route_info.dart';

/// 导航栈级埋点：监听全局 push / pop / replace / remove。
///
/// 与 [SHOPageRouteAnalyticsMixin]（单页 [RouteAware]）互补：
/// - 本 Observer：任意路由变化都会上报，无需页面接入
/// - RouteAware mixin：区分 enter / exit / cover / resume 可见性语义
class SHOPageAnalyticsNavigatorObserver extends NavigatorObserver {
  SHOPageAnalyticsNavigatorObserver({this.navigatorId = 'root'});

  final String navigatorId;

  static final SHOPageAnalyticsNavigatorObserver root =
      SHOPageAnalyticsNavigatorObserver();

  void _report(
    SHORouteNavigatorAction action,
    Route<dynamic>? route,
    Route<dynamic>? previousRoute,
  ) {
    if (route == null) return;
    final routeInfo = SHOPageRouteInfo.fromRoute(route);
    final previousInfo = previousRoute == null
        ? null
        : SHOPageRouteInfo.fromRoute(previousRoute);
    SHOPageAnalyticsReporter.reportNavigatorAction(
      action: action,
      routeInfo: routeInfo,
      previousRouteInfo: previousInfo,
      navigatorId: navigatorId,
    );
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _report(SHORouteNavigatorAction.push, route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _report(SHORouteNavigatorAction.pop, route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _report(SHORouteNavigatorAction.replace, newRoute, oldRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _report(SHORouteNavigatorAction.remove, route, previousRoute);
  }
}
