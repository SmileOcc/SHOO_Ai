import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/hos_routes.dart';
import 'presentation/hos_search_page.dart';

List<RouteBase> shoSearchRoutes({required GlobalKey<NavigatorState> rootKey}) => [
      GoRoute(
        path: SHOAppRoutes.search,
        parentNavigatorKey: rootKey,
        builder: (context, state) => SHOSearchPage(
          initialQuery: state.uri.queryParameters['q'],
        ),
      ),
    ];
