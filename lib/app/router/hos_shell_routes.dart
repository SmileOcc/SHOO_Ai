import 'package:go_router/go_router.dart';

import 'package:shoo/core/pages/hos_tab_keep_alive_page.dart';
import 'package:shoo/features/cart/presentation/pages/hos_cart_page.dart';
import 'package:shoo/features/category/presentation/pages/hos_category_page.dart';
import 'package:shoo/features/category/router.dart';
import 'package:shoo/features/community/presentation/pages/hos_community_page.dart';
import 'package:shoo/features/home/presentation/pages/hos_home_page.dart';
import 'package:shoo/features/message/presentation/pages/hos_message_page.dart';
import 'package:shoo/features/profile/presentation/pages/hos_profile_page.dart';
import 'package:shoo/features/profile/presentation/pages/hos_about_page.dart';
import 'package:shoo/features/profile/presentation/pages/hos_settings_cache_page.dart';
import 'package:shoo/features/profile/presentation/pages/hos_settings_help_page.dart';
import 'package:shoo/features/profile/presentation/pages/hos_settings_notifications_page.dart';
import 'package:shoo/features/profile/presentation/pages/hos_settings_profile_page.dart';
import 'package:shoo/features/profile/presentation/pages/hos_settings_payment_page.dart';
import 'package:shoo/features/profile/presentation/pages/hos_settings_security_page.dart';
import 'package:shoo/features/profile/presentation/pages/hos_settings_page.dart';
import 'package:shoo/app/shell/hos_main_shell.dart';
import 'package:shoo/app/router/hos_router_keys.dart';
import 'package:shoo/app/router/hos_routes.dart';

List<RouteBase> shoShellRoutes() => [
  GoRoute(
    path: SHOAppRoutes.settings,
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const SHOSettingsPage(),
    routes: [
      GoRoute(path: 'about', builder: (context, state) => const SHOAboutPage()),
      GoRoute(
        path: 'cache',
        builder: (context, state) => const SHOSettingsCachePage(),
      ),
      GoRoute(
        path: 'notifications',
        builder: (context, state) => const SHOSettingsNotificationsPage(),
      ),
      GoRoute(
        path: 'profile',
        builder: (context, state) => const SHOSettingsProfilePage(),
      ),
      GoRoute(
        path: 'security',
        builder: (context, state) => const SHOSettingsSecurityPage(),
      ),
      GoRoute(
        path: 'help',
        builder: (context, state) => const SHOSettingsHelpPage(),
      ),
      GoRoute(
        path: 'payment',
        builder: (context, state) => const SHOSettingsPaymentPage(),
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
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SHOTabKeepAlivePage(child: SHOHomePage()),
            ),
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: shellNavigatorCategoryKey,
        routes: [
          GoRoute(
            path: SHOAppRoutes.category,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SHOTabKeepAlivePage(child: SHOCategoryPage()),
            ),
            routes: [
              shoCategoryProductsRoute(rootKey: rootNavigatorKey),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: shellNavigatorCommunityKey,
        routes: [
          GoRoute(
            path: SHOAppRoutes.community,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SHOTabKeepAlivePage(child: SHOCommunityPage()),
            ),
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: shellNavigatorCartKey,
        routes: [
          GoRoute(
            path: SHOAppRoutes.cart,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SHOTabKeepAlivePage(child: SHOCartPage()),
            ),
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: shellNavigatorProfileKey,
        routes: [
          GoRoute(
            path: SHOAppRoutes.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SHOTabKeepAlivePage(child: SHOProfilePage()),
            ),
          ),
        ],
      ),
    ],
  ),
];
