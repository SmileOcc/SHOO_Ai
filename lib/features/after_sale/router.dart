import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/pages/hos_route_args.dart';
import 'package:shoo/features/after_sale/presentation/pages/hos_after_sale_apply_page.dart';
import 'package:shoo/features/after_sale/presentation/pages/hos_after_sale_list_page.dart';

List<RouteBase> shoAfterSaleRoutes({required GlobalKey<NavigatorState> rootKey}) => [
      GoRoute(
        path: SHOAppRoutes.afterSales,
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SHOAfterSaleListPage(),
        routes: [
          GoRoute(
            path: 'apply/:orderId',
            builder: (context, state) => SHOAfterSaleApplyPage(
              orderId: state.pathIdArgs(key: 'orderId').id,
            ),
          ),
        ],
      ),
    ];
