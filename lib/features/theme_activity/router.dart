import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/pages/hos_route_args.dart';
import 'package:shoo/features/theme_activity/presentation/pages/hos_theme_activity_page.dart';

List<RouteBase> shoThemeActivityRoutes({
  required GlobalKey<NavigatorState> rootKey,
}) => [
  GoRoute(
    path: '${SHOAppRoutes.themeActivity}/:activityId',
    parentNavigatorKey: rootKey,
    builder: (context, state) {
      final args = state.themeActivityArgs;
      return SHOThemeActivityPage(
        activityId: args.activityId,
        channel: args.channel,
      );
    },
  ),
];
