import 'package:go_router/go_router.dart';

import '../../features/cart/presentation/hos_cart_page.dart';
import '../../features/category/presentation/hos_category_page.dart';
import '../../features/home/presentation/hos_home_page.dart';
import '../../features/message/presentation/hos_message_page.dart';
import '../../features/profile/presentation/hos_profile_page.dart';
import '../../features/profile/presentation/hos_about_page.dart';
import '../../features/profile/presentation/hos_settings_cache_page.dart';
import '../../features/profile/presentation/hos_settings_page.dart';
import '../shell/hos_main_shell.dart';
import 'hos_router_keys.dart';
import 'hos_routes.dart';

List<RouteBase> shoShellRoutes() => [
      GoRoute(
        path: SHOAppRoutes.settings,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SHOSettingsPage(),
        routes: [
          GoRoute(
            path: 'about',
            builder: (context, state) => const SHOAboutPage(),
          ),
          GoRoute(
            path: 'cache',
            builder: (context, state) => const SHOSettingsCachePage(),
          ),
        ],
      ),
      GoRoute(
        path: SHOAppRoutes.messages,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SHOMessagePage(),
      ),
      // StatefulShellRoute 是专门为包含底部 导航栏 或侧边导航栏的应用设计的，
      //它能够保持多个 Tab 页面的状态，同时支持在 Tab 之间切换时保持各页面的滚动位置和表单数据。
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return SHOMainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: SHOAppRoutes.home,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SHOHomePage()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorCategoryKey,
            routes: [
              GoRoute(
                path: SHOAppRoutes.category,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SHOCategoryPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorCartKey,
            routes: [
              GoRoute(
                path: SHOAppRoutes.cart,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SHOCartPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorProfileKey,
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
    ];
