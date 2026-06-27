import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/features/flash_sale/domain/hos_flash_sale_activities.dart';
import 'package:shoo/features/flash_sale/presentation/pages/hos_flash_sale_follows_page.dart';
import 'package:shoo/features/flash_sale/presentation/pages/hos_flash_sale_page.dart';

List<RouteBase> shoFlashSaleRoutes({required GlobalKey<NavigatorState> rootKey}) => [
      GoRoute(
        path: SHOAppRoutes.flashSale,
        parentNavigatorKey: rootKey,
        builder: (context, state) {
          final activityId = state.uri.queryParameters['activityId'] ??
              SHOFlashSaleActivities.defaults;
          return SHOFlashSalePage(activityId: activityId);
        },
      ),
      GoRoute(
        path: SHOAppRoutes.profileFlashSaleFollows,
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SHOFlashSaleFollowsPage(),
      ),
    ];
