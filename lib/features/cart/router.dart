import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/hos_routes.dart';
import '../../l10n/app_localizations.dart';
import 'presentation/hos_cart_page.dart';

/// 从商品详情等页面 push 进入的购物车（带返回栏，pop 回到上一页）。
class SHOCartStackPage extends StatelessWidget {
  const SHOCartStackPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.tabBag,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: const SHOCartPage(),
    );
  }
}

List<RouteBase> shoCartRoutes({required GlobalKey<NavigatorState> rootKey}) => [
      GoRoute(
        path: SHOAppRoutes.cartStack,
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SHOCartStackPage(),
      ),
    ];
