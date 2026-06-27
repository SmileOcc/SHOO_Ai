import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/core/pages/hos_route_args.dart';
import 'package:shoo/features/review/presentation/pages/hos_reviews_page.dart';
import 'package:shoo/features/product/presentation/pages/hos_product_detail_page.dart';

List<RouteBase> shoProductRoutes({required GlobalKey<NavigatorState> rootKey}) => [
      GoRoute(
        path: '/product/:id',
        parentNavigatorKey: rootKey,
        builder: (context, state) {
          final args = state.productArgs;
          return SHOProductDetailPage(
            productId: args.productId,
            sessionId: args.sessionId,
          );
        },
        routes: [
          GoRoute(
            path: 'reviews',
            builder: (context, state) => SHOReviewsPage(
              productId: state.pathIdArgs().id,
            ),
          ),
        ],
      ),
    ];
