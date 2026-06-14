import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shoo/core/logging/hos_logging.dart';

import '../../core/analytics/hos_page_analytics.dart';
import '../../core/debug/router.dart';
import '../../features/address/router.dart';
import '../../features/after_sale/router.dart';
import '../../features/auth/router.dart';
import '../../features/cart/router.dart';
import '../../features/category/router.dart';
import '../../features/checkout/router.dart';
import '../../features/coupon/router.dart';
import '../../features/order/router.dart';
import '../../features/product/router.dart';
import '../../features/profile/router.dart';
import '../../features/search/router.dart';
import '../../features/splash/router.dart';
import '../../features/toolbox/presentation/music/hos_music_nav_observer.dart';
import '../../features/toolbox/presentation/music/hos_music_route_state.dart';
import '../../features/toolbox/router.dart';
import 'hos_not_found_page.dart';
import 'hos_router_keys.dart';
import 'hos_router_notifier.dart';
import 'hos_routes.dart';
import 'hos_shell_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // 只能赋值一次，防止意外修改
  final notifier = ref.watch(routerNotifierProvider);

  //syncMusicRoute 闭包需要引用 router ，但 router 在闭包定义时尚未创建
  late final GoRouter router;
  void syncMusicRoute() => syncMusicPlayerRouteState(ref, router);

  router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: SHOAppRoutes.splash,
    refreshListenable: notifier, // ← 路由守卫刷新
    redirect: notifier.redirect, // ← 路由守卫逻辑
    observers: [
      shoPageRouteObserver,
      SHOPageAnalyticsNavigatorObserver.root,
      SHOMusicNavigatorObserver(syncMusicRoute),
    ],
    errorBuilder: (context, state) =>
        SHONotFoundPage(location: state.uri.toString()),
    routes: [
      ...shoSplashRoutes(),
      ...shoAuthRoutes(rootKey: rootNavigatorKey),
      ...shoCartRoutes(rootKey: rootNavigatorKey),
      ...shoSearchRoutes(rootKey: rootNavigatorKey),
      ...shoCategoryRoutes(rootKey: rootNavigatorKey),
      ...shoProfileRoutes(rootKey: rootNavigatorKey),
      ...shoCheckoutRoutes(rootKey: rootNavigatorKey),
      ...shoCouponRoutes(rootKey: rootNavigatorKey),
      ...shoAfterSaleRoutes(rootKey: rootNavigatorKey),
      ...shoAddressRoutes(rootKey: rootNavigatorKey),
      ...shoOrderRoutes(rootKey: rootNavigatorKey),
      ...shoProductRoutes(rootKey: rootNavigatorKey),
      ...shoToolboxRoutes(rootKey: rootNavigatorKey),
      ...shoDebugRoutes(rootKey: rootNavigatorKey),
      ...shoShellRoutes(),
    ],
  );
  //addListener 需要无参函数，但 syncMusicPlayerRouteState 需要 ref 和 router 参数
  router.routerDelegate.addListener(syncMusicRoute);
  //ProviderScope 重建、应用退出等场景
  ref.onDispose(() => router.routerDelegate.removeListener(syncMusicRoute));
  //微任务：在当前事件循环结束后立即执行回调
  SHOAppLogger.i('microtask syncMusicRoute --1');
  Future.microtask(syncMusicRoute);
  SHOAppLogger.i('microtask syncMusicRoute --2');
  return router;
});

/*
┌─────────────────────────────────────────────────────────────┐
│                    GoRouter 内部结构                         │
└─────────────────────────────────────────────────────────────┘

GoRouter
    │
    ├── routerDelegate: GoRouterDelegate
    │       │
    │       ├── currentConfiguration: RouteMatchList
    │       │       └── 当前路由匹配列表（路由栈）
    │       │
    │       ├── addListener()    ←── 添加监听器
    │       ├── removeListener() ←── 移除监听器
    │       │
    │       └── notifyListeners() ←── 路由变化时调用
    │
    └── routeInformationParser: GoRouteInformationParser
*/

/**
 * 
监听器触发流程 ：
用户导航到新页面
    ↓
GoRouter 内部更新路由栈
    ↓
routerDelegate.currentConfiguration 变化
    ↓
routerDelegate.notifyListeners() 被调用
    ↓
所有 addListener 注册的监听器执行
    ↓
syncMusicRoute() 执行
    ↓
musicOnPlayerPageProvider 状态更新
    ↓
UI 响应式更新（如迷你播放器显示/隐藏）
 * 
 */
