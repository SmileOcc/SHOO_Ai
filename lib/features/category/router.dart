import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/pages/hos_route_args.dart';
import 'package:shoo/features/category/presentation/pages/hos_category_products_page.dart';

List<RouteBase> shoCategoryRoutes({required GlobalKey<NavigatorState> rootKey}) =>
    [
      GoRoute(
        path: SHOAppRoutes.categoryProducts,
        parentNavigatorKey: rootKey,
        builder: (context, state) {
          final args = state.categoryProductsArgs;
          return SHOCategoryProductsPage(
            leafCategoryId: args.leafCategoryId,
            title: args.title,
          );
        },
      ),
    ];
