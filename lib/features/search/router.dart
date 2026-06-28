import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/pages/hos_route_args.dart';
import 'package:shoo/features/search/presentation/pages/hos_search_page.dart';

List<RouteBase> shoSearchRoutes({required GlobalKey<NavigatorState> rootKey}) =>
    [
      GoRoute(
        path: SHOAppRoutes.search,
        parentNavigatorKey: rootKey,
        builder: (context, state) =>
            SHOSearchPage(initialQuery: state.searchArgs.query),
      ),
    ];
