import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/pages/hos_route_args.dart';
import 'package:shoo/features/auth/presentation/pages/hos_login_page.dart';
import 'package:shoo/features/auth/presentation/pages/hos_register_page.dart';

List<RouteBase> shoAuthRoutes({required GlobalKey<NavigatorState> rootKey}) => [
  GoRoute(
    path: SHOAppRoutes.login,
    parentNavigatorKey: rootKey,
    builder: (context, state) =>
        SHOLoginPage(redirectTo: state.authArgs.redirectTo),
  ),
  GoRoute(
    path: SHOAppRoutes.register,
    parentNavigatorKey: rootKey,
    builder: (context, state) => const SHORegisterPage(),
  ),
];
