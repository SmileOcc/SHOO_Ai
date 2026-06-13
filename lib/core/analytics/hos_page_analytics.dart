/// 页面通用埋点方案（RouteAware + RouteObserver + NavigatorObserver）
///
/// ## 架构
///
/// ```
/// GoRouter.observers
///   ├── shoPageRouteObserver          ← RouteAware 订阅源
///   ├── SHOPageAnalyticsNavigatorObserver  ← 栈级 push/pop/replace/remove
///   └── SHOMusicNavigatorObserver   ← 业务专用（音乐路由同步）
///
/// 页面接入（二选一）
///   ├── SHOPageRouteAnalyticsMixin  ← StatefulWidget / ConsumerStatefulWidget
///   └── SHOPageAnalyticsBinder      ← StatelessWidget 包裹
/// ```
///
/// ## 事件
///
/// | 事件 key | 触发时机 | 来源 |
/// |----------|----------|------|
/// | page_enter | 页面首次显示 | RouteAware.didPush |
/// | page_exit | 页面出栈 | RouteAware.didPop |
/// | page_cover | 被上层路由覆盖 | RouteAware.didPushNext |
/// | page_resume | 上层 pop 后恢复 | RouteAware.didPopNext |
/// | route_push | 导航栈 push | NavigatorObserver |
/// | route_pop | 导航栈 pop | NavigatorObserver |
/// | route_replace | 路由替换 | NavigatorObserver |
/// | route_remove | 路由移除 | NavigatorObserver |
/// | tab_switch | 底部 Tab 切换 | SHOMainShell.onTap |
///
/// ## 接入步骤
///
/// 1. 路由已注册 `shoPageRouteObserver`（见 [hos_router.dart]）
/// 2. 在页面 State 上 mixin [SHOPageRouteAnalyticsMixin]，或外层包 [SHOPageAnalyticsBinder]
/// 3. 可选：覆写 [SHOPageRouteAnalyticsMixin.pageAnalyticsName] 与 [pageAnalyticsExtra]
///
/// ## 与 App 生命周期埋点的关系
///
/// - [SHOAppLifecycleBinder]：冷启动 / 进后台（app_launch / app_close）
/// - 本模块：页面级 push / pop / 覆盖 / 恢复
///
/// ## Shell Tab 说明
///
/// [StatefulShellRoute] 的 Tab 切换由 indexedStack 管理，不一定触发 push/pop。
/// Tab 切换使用 [SHOTabAnalyticsReporter]（见 [hos_tab_analytics.dart]）。
library;

export 'hos_page_analytics_action.dart';
export 'hos_tab_analytics.dart';
export 'hos_page_analytics_binder.dart';
export 'hos_page_analytics_nav_observer.dart';
export 'hos_page_analytics_reporter.dart';
export 'hos_page_route_analytics_mixin.dart';
export 'hos_page_route_info.dart';
export 'hos_page_route_observer.dart';
