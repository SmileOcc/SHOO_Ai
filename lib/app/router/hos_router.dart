import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/debug/router.dart';
import '../../features/address/router.dart';
import '../../features/after_sale/router.dart';
import '../../features/auth/router.dart';
import '../../features/checkout/router.dart';
import '../../features/coupon/router.dart';
import '../../features/order/router.dart';
import '../../features/product/router.dart';
import '../../features/search/router.dart';
import '../../features/splash/router.dart';
import 'hos_not_found_page.dart';
import 'hos_router_keys.dart';
import 'hos_router_notifier.dart';
import 'hos_routes.dart';
import 'hos_shell_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: SHOAppRoutes.splash,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    errorBuilder: (context, state) => SHONotFoundPage(location: state.uri.toString()),
    routes: [
      ...shoSplashRoutes(),
      ...shoAuthRoutes(rootKey: rootNavigatorKey),
      ...shoSearchRoutes(rootKey: rootNavigatorKey),
      ...shoCheckoutRoutes(rootKey: rootNavigatorKey),
      ...shoCouponRoutes(rootKey: rootNavigatorKey),
      ...shoAfterSaleRoutes(rootKey: rootNavigatorKey),
      ...shoAddressRoutes(rootKey: rootNavigatorKey),
      ...shoOrderRoutes(rootKey: rootNavigatorKey),
      ...shoProductRoutes(rootKey: rootNavigatorKey),
      ...shoDebugRoutes(rootKey: rootNavigatorKey),
      ...shoShellRoutes(),
    ],
  );
});
