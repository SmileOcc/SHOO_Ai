import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/hos_routes.dart';
import 'presentation/hos_category_products_page.dart';

List<RouteBase> shoCategoryRoutes({required GlobalKey<NavigatorState> rootKey}) =>
    [
      GoRoute(
        path: SHOAppRoutes.categoryProducts,
        parentNavigatorKey: rootKey,
        builder: (context, state) {
          final leafId = state.uri.queryParameters['leafId'] ?? '';
          final title = state.uri.queryParameters['title'] ?? '';
          return SHOCategoryProductsPage(
            leafCategoryId: leafId,
            title: title,
          );
        },
      ),
    ];
