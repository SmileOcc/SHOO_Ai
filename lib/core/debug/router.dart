import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/hos_routes.dart';
import 'modules/activity/hos_debug_activity_config_page.dart';
import 'modules/analytics/hos_debug_analytics_page.dart';
import 'modules/brand/hos_debug_brand_page.dart';
import 'modules/feedback/hos_debug_feedback_page.dart';
import 'modules/microtask/hos_debug_microtask_page.dart';
import 'modules/native/hos_debug_native_example_page.dart';
import 'modules/native/hos_debug_native_examples.dart';
import 'modules/native/hos_debug_native_hub_page.dart';
import 'modules/network_log/hos_debug_network_log_page.dart';
import 'modules/update/hos_debug_update_config_page.dart';
import 'panel/hos_debug_panel_page.dart';

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
            path: 'brand',
            builder: (context, state) => const SHODebugBrandPage(),
          ),
          GoRoute(
            path: 'analytics',
            builder: (context, state) => const SHODebugAnalyticsPage(),
          ),
          GoRoute(
            path: 'network-log',
            builder: (context, state) => const SHODebugNetworkLogPage(),
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
