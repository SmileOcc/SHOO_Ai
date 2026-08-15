import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/debug/modules/activity/hos_debug_activity_config_page.dart';
import 'package:shoo/core/debug/modules/analytics/hos_debug_analytics_page.dart';
import 'package:shoo/core/debug/modules/brand/hos_debug_brand_page.dart';
import 'package:shoo/core/debug/modules/deeplink/hos_debug_deeplink_page.dart';
import 'package:shoo/core/debug/modules/dependencies/hos_debug_dependencies_page.dart';
import 'package:shoo/core/debug/modules/flash_sale/hos_debug_flash_sale_reminder_page.dart';
import 'package:shoo/core/debug/modules/feedback/hos_debug_feedback_page.dart';
import 'package:shoo/core/debug/modules/hittest/hos_debug_hittest_page.dart';
import 'package:shoo/core/debug/modules/microtask/hos_debug_microtask_page.dart';
import 'package:shoo/core/debug/modules/native/hos_debug_native_example_page.dart';
import 'package:shoo/core/debug/modules/native/hos_debug_native_examples.dart';
import 'package:shoo/core/debug/modules/native/hos_debug_native_hub_page.dart';
import 'package:shoo/core/debug/modules/mixin/hos_debug_mixin_page.dart';
import 'package:shoo/core/debug/modules/network_log/hos_debug_network_log_page.dart';
import 'package:shoo/core/debug/modules/overlap/hos_debug_overlap_page.dart';
import 'package:shoo/core/debug/modules/secure_network/hos_debug_secure_network_page.dart';
import 'package:shoo/core/debug/modules/update/hos_debug_update_config_page.dart';
import 'package:shoo/core/debug/panel/hos_debug_panel_page.dart';

List<RouteBase> shoDebugRoutes({required GlobalKey<NavigatorState> rootKey}) =>
    [
      GoRoute(
        path: SHOAppRoutes.debug,
        parentNavigatorKey: rootKey,
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
          GoRoute(
            path: 'flash-sale-reminder',
            builder: (context, state) => const SHODebugFlashSaleReminderPage(),
          ),
          GoRoute(
            path: 'brand',
            builder: (context, state) => const SHODebugBrandPage(),
          ),
          GoRoute(
            path: 'analytics',
            builder: (context, state) => const SHODebugAnalyticsPage(),
          ),
          GoRoute(
            path: 'mixin',
            builder: (context, state) => const SHODebugMixinPage(),
          ),
          GoRoute(
            path: 'network-log',
            builder: (context, state) => const SHODebugNetworkLogPage(),
          ),
          GoRoute(
            path: 'secure-network',
            builder: (context, state) => const SHODebugSecureNetworkPage(),
          ),
          GoRoute(
            path: 'feedback',
            builder: (context, state) => const SHODebugFeedbackPage(),
          ),
          GoRoute(
            path: 'microtask',
            builder: (context, state) => const SHODebugMicrotaskPage(),
          ),
          GoRoute(
            path: 'hittest',
            builder: (context, state) => const SHODebugHitTestPage(),
          ),
          GoRoute(
            path: 'overlap',
            builder: (context, state) => const SHODebugOverlapPage(),
          ),
          GoRoute(
            path: 'dependencies',
            builder: (context, state) =>
                const DebugAllDependenciesWidget(child: SizedBox.shrink()),
          ),
          GoRoute(
            path: 'deeplink',
            builder: (context, state) => const SHODebugDeepLinkPage(),
          ),
          GoRoute(
            path: 'native',
            builder: (context, state) => const SHODebugNativeHubPage(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final example = findNativeDebugExample(
                    state.pathParameters['id']!,
                  );
                  if (example == null) {
                    return const SHODebugNativeHubPage();
                  }
                  return SHODebugNativeExamplePage(example: example);
                },
              ),
            ],
          ),
        ],
      ),
    ];
