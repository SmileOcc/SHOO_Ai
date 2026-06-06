import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/hos_routes.dart';
import 'presentation/hos_checkout_page.dart';
import 'presentation/hos_payment_page.dart';

List<RouteBase> shoCheckoutRoutes({required GlobalKey<NavigatorState> rootKey}) => [
      GoRoute(
        path: SHOAppRoutes.checkout,
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SHOCheckoutPage(),
      ),
      GoRoute(
        path: '/payment/:orderId',
        parentNavigatorKey: rootKey,
        builder: (context, state) => SHOPaymentPage(
          orderId: state.pathParameters['orderId']!,
        ),
      ),
    ];
