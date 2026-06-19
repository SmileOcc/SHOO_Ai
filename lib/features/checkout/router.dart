import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/features/order/domain/entities/hos_order.dart';
import 'package:shoo/features/checkout/presentation/pages/hos_checkout_page.dart';
import 'package:shoo/features/checkout/presentation/pages/hos_payment_page.dart';

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
          fromCartStack: state.uri.queryParameters['fromCartStack'] == '1',
          initialOrder: state.extra is SHOOrderDetail
              ? state.extra! as SHOOrderDetail
              : null,
        ),
      ),
    ];
