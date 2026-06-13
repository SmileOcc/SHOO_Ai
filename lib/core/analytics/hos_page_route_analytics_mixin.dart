import 'package:flutter/material.dart';

import 'hos_page_analytics_action.dart';
import 'hos_page_analytics_reporter.dart';
import 'hos_page_route_info.dart';
import 'hos_page_route_observer.dart';

/// 单页精细埋点：混入 [State] 后自动订阅 [shoPageRouteObserver] 并上报
/// enter / exit / cover / resume。
///
/// ```dart
/// class _MyPageState extends State<MyPage> with SHOPageRouteAnalyticsMixin {
///   @override
///   String get pageAnalyticsName => 'my_page';
/// }
/// ```
mixin SHOPageRouteAnalyticsMixin<T extends StatefulWidget> on State<T>
    implements RouteAware {
  /// 埋点用的页面名，默认 Widget 运行时类型。
  String get pageAnalyticsName => widget.runtimeType.toString();

  /// 附加业务字段，如 tab、articleId 等。
  Map<String, Object?> get pageAnalyticsExtra => const {};

  ModalRoute<void>? _subscribedRoute;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is! ModalRoute<void>) return;
    if (_subscribedRoute == route) return;
    if (_subscribedRoute != null) {
      shoPageRouteObserver.unsubscribe(this);
    }
    shoPageRouteObserver.subscribe(this, route);
    _subscribedRoute = route;
  }

  @override
  void dispose() {
    if (_subscribedRoute != null) {
      shoPageRouteObserver.unsubscribe(this);
      _subscribedRoute = null;
    }
    super.dispose();
  }

  @override
  void didPush() => _onAction(SHOPageAnalyticsAction.enter);

  @override
  void didPop() => _onAction(SHOPageAnalyticsAction.exit);

  @override
  void didPushNext() => _onAction(SHOPageAnalyticsAction.cover);

  @override
  void didPopNext() => _onAction(SHOPageAnalyticsAction.resume);

  void _onAction(SHOPageAnalyticsAction action) {
    if (!mounted) return;
    final info = SHOPageRouteInfo.tryFromContext(
      context,
      pageName: pageAnalyticsName,
      previousRoutePath:
          SHOPageAnalyticsReporter.resolvePreviousRoutePath(null),
    );
    if (info == null) return;
    SHOPageAnalyticsReporter.reportPageAction(
      action: action,
      info: info,
      extra: pageAnalyticsExtra,
    );
  }
}
