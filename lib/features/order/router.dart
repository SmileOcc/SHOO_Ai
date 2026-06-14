import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/hos_routes.dart';
import '../../core/navigation/hos_payment_flow_navigation.dart';
import 'presentation/hos_logistics_page.dart';
import 'presentation/hos_order_detail_page.dart';
import 'presentation/hos_order_list_page.dart';

List<RouteBase> shoOrderRoutes({required GlobalKey<NavigatorState> rootKey}) => [
      GoRoute(
        path: SHOAppRoutes.orders,
        parentNavigatorKey: rootKey,
        builder: (context, state) => SHOOrderListPage(
          statusFilter: state.uri.queryParameters['status'],
        ),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => SHOOrderDetailPage(
              orderId: state.pathParameters['id']!,
              skipPaymentFlowOnPop:
                  isOrderDetailFromPaymentSuccess(state.extra),
            ),
            routes: [
              GoRoute(
                path: 'logistics',
                builder: (context, state) => SHOLogisticsPage(
                  orderId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
        ],
      ),
    ];
