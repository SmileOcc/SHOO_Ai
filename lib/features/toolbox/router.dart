import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/hos_routes.dart';
import 'presentation/hos_download_list_page.dart';
import 'presentation/hos_toolbox_page.dart';

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
        ],
      ),
    ];
