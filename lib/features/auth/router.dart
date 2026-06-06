import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/hos_routes.dart';
import 'presentation/hos_login_page.dart';
import 'presentation/hos_register_page.dart';

List<RouteBase> shoAuthRoutes({required GlobalKey<NavigatorState> rootKey}) => [
      GoRoute(
        path: SHOAppRoutes.login,
        parentNavigatorKey: rootKey,
        builder: (context, state) => SHOLoginPage(
          redirectTo: state.uri.queryParameters['redirect'],
        ),
      ),
      GoRoute(
        path: SHOAppRoutes.register,
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SHORegisterPage(),
      ),
    ];
