import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/core/pages/hos_route_args.dart';
import 'package:shoo/features/category/presentation/pages/hos_category_products_page.dart';

/// 挂在 Shell Tab `/category` 下的子路由（全路径仍为 `/category/products`）。
///
/// 必须作为 `/category` 的 child，并指定 [parentNavigatorKey] 用根 Navigator，
/// 否则与 StatefulShell 的 `/category` 前缀冲突，push 会触发 go_router assertion。
GoRoute shoCategoryProductsRoute({
  required GlobalKey<NavigatorState> rootKey,
}) {
  return GoRoute(
    path: 'products',
    parentNavigatorKey: rootKey,
    builder: (context, state) {
      final args = state.categoryProductsArgs;
      return SHOCategoryProductsPage(
        leafCategoryId: args.leafCategoryId,
        title: args.title,
      );
    },
  );
}
