import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/hos_routes.dart';
import 'modules/activity/hos_debug_activity_config_page.dart';
import 'modules/native/hos_debug_native_example_page.dart';
import 'modules/native/hos_debug_native_examples.dart';
import 'modules/native/hos_debug_native_hub_page.dart';
import 'modules/update/hos_debug_update_config_page.dart';
import 'panel/hos_debug_panel_page.dart';

List<RouteBase> shoDebugRoutes({required GlobalKey<NavigatorState> rootKey}) => [
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
            path: 'native',
            builder: (context, state) => const SHODebugNativeHubPage(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final example = findNativeDebugExample(state.pathParameters['id']!);
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
