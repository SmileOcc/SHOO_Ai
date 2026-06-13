/// 页面可见性生命周期动作（对应 [RouteAware] 回调语义）。
enum SHOPageAnalyticsAction {
  /// [RouteAware.didPush]：页面首次进入导航栈并显示。
  enter,

  /// [RouteAware.didPop]：页面从导航栈移除（用户返回或代码 pop）。
  exit,

  /// [RouteAware.didPushNext]：上层路由 push，本页被覆盖但仍保留在栈中。
  cover,

  /// [RouteAware.didPopNext]：上层路由 pop，本页从被覆盖状态恢复显示。
  resume,
}

/// Navigator 栈级动作（对应 [NavigatorObserver] 回调）。
enum SHORouteNavigatorAction {
  push,
  pop,
  replace,
  remove,
}
