import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/hos_routes.dart';
import 'presentation/hos_download_list_page.dart';
import 'presentation/hos_toolbox_page.dart';
import 'presentation/hos_txt_reader_route_page.dart';

List<RouteBase> shoToolboxRoutes({required GlobalKey<NavigatorState> rootKey}) =>
    [
      GoRoute(
        path: SHOAppRoutes.toolbox,
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SHOToolboxPage(),
        routes: [
          GoRoute(
            path: 'downloads',
            parentNavigatorKey: rootKey,
            builder: (context, state) => const SHODownloadListPage(),
          ),
          GoRoute(
            path: 'reader',
            parentNavigatorKey: rootKey,
            builder: (context, state) {
              final taskId = state.uri.queryParameters['taskId'] ?? '';
              return SHOTxtReaderRoutePage(taskId: taskId);
            },
          ),
        ],
      ),
    ];
