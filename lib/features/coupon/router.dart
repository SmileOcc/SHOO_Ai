import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/hos_routes.dart';
import 'presentation/hos_coupon_list_page.dart';

List<RouteBase> shoCouponRoutes({required GlobalKey<NavigatorState> rootKey}) => [
      GoRoute(
        path: SHOAppRoutes.coupons,
        parentNavigatorKey: rootKey,
        builder: (context, state) => SHOCouponListPage(
          selectMode: state.uri.queryParameters['select'] == '1',
        ),
      ),
    ];
