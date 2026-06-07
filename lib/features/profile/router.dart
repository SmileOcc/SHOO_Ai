import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/hos_routes.dart';
import 'presentation/hos_profile_activity_list_page.dart';
import 'presentation/hos_profile_controller.dart';

List<RouteBase> shoProfileRoutes({required GlobalKey<NavigatorState> rootKey}) =>
    [
      GoRoute(
        path: SHOAppRoutes.profileFootprints,
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SHOProfileActivityListPage(
          kind: SHOProfileActivityListKind.footprints,
        ),
      ),
      GoRoute(
        path: SHOAppRoutes.profileFavorites,
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SHOProfileActivityListPage(
          kind: SHOProfileActivityListKind.favorites,
        ),
      ),
    ];
