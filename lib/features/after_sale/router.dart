import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/hos_routes.dart';
import 'presentation/hos_after_sale_apply_page.dart';
import 'presentation/hos_after_sale_list_page.dart';

List<RouteBase> shoAfterSaleRoutes({required GlobalKey<NavigatorState> rootKey}) => [
      GoRoute(
        path: SHOAppRoutes.afterSales,
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SHOAfterSaleListPage(),
        routes: [
          GoRoute(
            path: 'apply/:orderId',
            builder: (context, state) => SHOAfterSaleApplyPage(
              orderId: state.pathParameters['orderId']!,
            ),
          ),
        ],
      ),
    ];
