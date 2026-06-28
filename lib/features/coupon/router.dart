import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/pages/hos_route_args.dart';
import 'package:shoo/features/coupon/presentation/pages/hos_coupon_list_page.dart';

List<RouteBase> shoCouponRoutes({required GlobalKey<NavigatorState> rootKey}) =>
    [
      GoRoute(
        path: SHOAppRoutes.coupons,
        parentNavigatorKey: rootKey,
        builder: (context, state) =>
            SHOCouponListPage(selectMode: state.selectArgs.selectMode),
      ),
    ];
