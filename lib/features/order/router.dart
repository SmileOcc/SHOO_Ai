import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/pages/hos_route_args.dart';
import 'package:shoo/features/order/presentation/pages/hos_logistics_page.dart';
import 'package:shoo/features/order/presentation/pages/hos_order_detail_page.dart';
import 'package:shoo/features/order/presentation/pages/hos_order_list_page.dart';

List<RouteBase> shoOrderRoutes({required GlobalKey<NavigatorState> rootKey}) =>
    [
      GoRoute(
        path: SHOAppRoutes.orders,
        parentNavigatorKey: rootKey,
        builder: (context, state) =>
            SHOOrderListPage(statusFilter: state.orderListArgs.status),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final args = state.orderDetailArgs;
              return SHOOrderDetailPage(
                orderId: args.orderId,
                skipPaymentFlowOnPop: args.skipPaymentFlowOnPop,
              );
            },
            routes: [
              GoRoute(
                path: 'logistics',
                builder: (context, state) =>
                    SHOLogisticsPage(orderId: state.pathIdArgs().id),
              ),
            ],
          ),
        ],
      ),
    ];
