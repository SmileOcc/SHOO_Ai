import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/analytics/hos_page_analytics.dart';
import '../../features/toolbox/presentation/music/hos_music_nav_observer.dart';
import '../../features/toolbox/presentation/music/hos_music_route_state.dart';

import '../../core/debug/router.dart';
import '../../features/address/router.dart';
import '../../features/after_sale/router.dart';
import '../../features/auth/router.dart';
import '../../features/checkout/router.dart';
import '../../features/coupon/router.dart';
import '../../features/order/router.dart';
import '../../features/product/router.dart';
import '../../features/category/router.dart';
import '../../features/profile/router.dart';
import '../../features/search/router.dart';
import '../../features/toolbox/router.dart';
import '../../features/splash/router.dart';
import 'hos_not_found_page.dart';
import 'hos_router_keys.dart';
import 'hos_router_notifier.dart';
import 'hos_routes.dart';
import 'hos_shell_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  late final GoRouter router;
  void syncMusicRoute() => syncMusicPlayerRouteState(ref, router);

  router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: SHOAppRoutes.splash,
    refreshListenable: notifier,  // ← 路由守卫刷新
    redirect: notifier.redirect,  // ← 路由守卫逻辑
    observers: [
      shoPageRouteObserver,
      SHOPageAnalyticsNavigatorObserver.root,
      SHOMusicNavigatorObserver(syncMusicRoute),
    ],
    errorBuilder: (context, state) => SHONotFoundPage(location: state.uri.toString()),
    routes: [
      ...shoSplashRoutes(),
      ...shoAuthRoutes(rootKey: rootNavigatorKey),
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
  router.routerDelegate.addListener(syncMusicRoute);
  ref.onDispose(() => router.routerDelegate.removeListener(syncMusicRoute));
  Future.microtask(syncMusicRoute);
  return router;
});
