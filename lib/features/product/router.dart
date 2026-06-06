import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/review/presentation/hos_reviews_page.dart';
import 'presentation/hos_product_detail_page.dart';

List<RouteBase> shoProductRoutes({required GlobalKey<NavigatorState> rootKey}) => [
      GoRoute(
        path: '/product/:id',
        parentNavigatorKey: rootKey,
        builder: (context, state) => SHOProductDetailPage(
          productId: state.pathParameters['id']!,
        ),
        routes: [
          GoRoute(
            path: 'reviews',
            builder: (context, state) => SHOReviewsPage(
              productId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
    ];
