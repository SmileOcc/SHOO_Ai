import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/debug/hos_debug_activity_config_page.dart';
import '../../core/debug/hos_debug_panel_page.dart';
import '../../core/debug/hos_debug_update_config_page.dart';
import '../../features/auth/presentation/hos_login_page.dart';
import '../../features/auth/presentation/hos_register_page.dart';
import '../../features/cart/presentation/hos_cart_page.dart';
import '../../features/category/presentation/hos_category_page.dart';
import '../../features/home/presentation/hos_home_page.dart';
import '../../features/message/presentation/hos_message_page.dart';
import '../../features/profile/presentation/hos_profile_page.dart';
import '../../features/order/presentation/hos_logistics_page.dart';
import '../../features/order/presentation/hos_order_detail_page.dart';
import '../../features/order/presentation/hos_order_list_page.dart';
import '../../features/product/presentation/hos_product_detail_page.dart';
import '../../features/profile/presentation/hos_settings_page.dart';
import '../../features/review/presentation/hos_reviews_page.dart';
import '../../features/search/presentation/hos_search_page.dart';
import '../../features/splash/presentation/hos_onboarding_page.dart';
import '../../features/splash/presentation/hos_splash_page.dart';
import '../shell/hos_main_shell.dart';
import 'hos_routes.dart';
import 'hos_router_notifier.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorCategoryKey = GlobalKey<NavigatorState>(debugLabel: 'shellCategory');
final _shellNavigatorCartKey = GlobalKey<NavigatorState>(debugLabel: 'shellCart');
final _shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: SHOAppRoutes.splash,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: SHOAppRoutes.splash,
        builder: (context, state) => const SHOSplashPage(),
      ),
      GoRoute(
        path: SHOAppRoutes.onboarding,
        builder: (context, state) => const SHOOnboardingPage(),
      ),
      GoRoute(
        path: SHOAppRoutes.login,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => SHOLoginPage(
          redirectTo: state.uri.queryParameters['redirect'],
        ),
      ),
      GoRoute(
        path: SHOAppRoutes.register,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SHORegisterPage(),
      ),
      GoRoute(
        path: SHOAppRoutes.settings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SHOSettingsPage(),
      ),
      GoRoute(
        path: SHOAppRoutes.messages,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SHOMessagePage(),
      ),
      GoRoute(
        path: SHOAppRoutes.search,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => SHOSearchPage(
          initialQuery: state.uri.queryParameters['q'],
        ),
      ),
      GoRoute(
        path: SHOAppRoutes.orders,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SHOOrderListPage(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => SHOOrderDetailPage(
              orderId: state.pathParameters['id']!,
            ),
            routes: [
              GoRoute(
                path: 'logistics',
                builder: (context, state) => SHOLogisticsPage(
                  orderId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/product/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => SHOProductDetailPage(
          productId: state.pathParameters['id']!,
        ),
        routes: [
          GoRoute(
            path: 'reviews',
            builder: (context, state) => SHOReviewsPage(
              productId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: SHOAppRoutes.debug,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SHODebugPanelPage(),
        routes: [
          GoRoute(
            path: 'update',
            builder: (context, state) => const SHODebugUpdateConfigPage(),
          ),
          GoRoute(
            path: 'activity',
            builder: (context, state) => const SHODebugActivityConfigPage(),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return SHOMainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: SHOAppRoutes.home,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SHOHomePage()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorCategoryKey,
            routes: [
              GoRoute(
                path: SHOAppRoutes.category,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SHOCategoryPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorCartKey,
            routes: [
              GoRoute(
                path: SHOAppRoutes.cart,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SHOCartPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: SHOAppRoutes.profile,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SHOProfilePage()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
