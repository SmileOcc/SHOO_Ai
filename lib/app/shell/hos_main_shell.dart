import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/core/debug/core/hos_debug_tap_detector.dart';
import 'package:shoo/core/feedback/hos_toast.dart';
import 'package:shoo/features/category/presentation/state/hos_category_controller.dart';
import 'package:shoo/features/home/presentation/pages/hos_home_page.dart';
import 'package:shoo/features/home/presentation/widgets/hos_home_side_drawer.dart';
import 'package:shoo/l10n/app_localizations.dart';
import 'package:shoo/app/router/hos_routes.dart';
import 'hos_bottom_nav.dart';
import 'package:shoo/features/cart/presentation/state/hos_cart_controller.dart';
import 'package:shoo/features/cart/presentation/state/hos_cart_manage_provider.dart';
import 'package:shoo/features/auth/presentation/state/hos_session_provider.dart';

class SHOMainShell extends ConsumerWidget {
  const SHOMainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    SHOAppTabItem(
      route: SHOAppRoutes.home,
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      showSearchBar: true,
    ),
    SHOAppTabItem(
      route: SHOAppRoutes.category,
      icon: Icons.grid_view_rounded,
      activeIcon: Icons.grid_view_rounded,
    ),
    SHOAppTabItem(
      route: SHOAppRoutes.community,
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      showCommunityActions: true,
    ),
    SHOAppTabItem(
      route: SHOAppRoutes.cart,
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag_rounded,
    ),
    SHOAppTabItem(
      route: SHOAppRoutes.profile,
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  String _tabLabel(AppLocalizations l10n, int index) => switch (index) {
    0 => l10n.tabShop,
    1 => l10n.tabCategory,
    2 => l10n.tabCommunity,
    3 => l10n.tabBag,
    _ => l10n.tabMe,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = navigationShell.currentIndex;
    final showSearch = _tabs[current].showSearchBar;
    final isCategoryTab = current == 1;
    final isCommunityTab = current == 2;
    final categoryTitle = ref.watch(categoryAppBarTitleProvider);

    final isProfileTab = current == 4;
    final isCartTab = current == 3;

    if (!isCartTab && ref.watch(cartManageModeProvider)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ref.read(cartManageModeProvider)) {
          ref.read(cartManageModeProvider.notifier).state = false;
        }
      });
    }

    final cartManaging = ref.watch(cartManageModeProvider);
    final cartHasItems = ref.watch(cartProvider).items.isNotEmpty;
    final showCartManage = isCartTab &&
        ref.watch(sessionProvider).isAuthenticated &&
        cartHasItems;

    if (isCartTab && cartManaging && !cartHasItems) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ref.read(cartManageModeProvider)) {
          ref.read(cartManageModeProvider.notifier).state = false;
        }
      });
    }

    return SHOHomeSideDrawerHost(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: isProfileTab
            ? null
            : SHODebugTapAppBar(
                appBar: showSearch
                    ? AppBar(
                        toolbarHeight: 52,
                        title: SHOHomeSearchBar(
                          onSearchTap: () => context.push(SHOAppRoutes.search),
                          onBrandTap: () => openHomeSideDrawer(ref),
                        ),
                        titleSpacing: 0,
                      )
                    : isCommunityTab
                    ? AppBar(
                        title: Text(
                          l10n.communityCenterTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.search_rounded),
                            onPressed: () => context.push(SHOAppRoutes.search),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () =>
                                SHOAppToast.info(l10n.communityPostComingSoon),
                          ),
                        ],
                      )
                    : AppBar(
                        title: Text(
                          isCategoryTab && categoryTitle.isNotEmpty
                              ? categoryTitle
                              : _tabLabel(l10n, current),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        actions: [
                          if (showCartManage)
                            TextButton(
                              onPressed: () {
                                ref.read(cartManageModeProvider.notifier).state =
                                    !cartManaging;
                              },
                              child: Text(
                                cartManaging
                                    ? l10n.cartManageDone
                                    : l10n.cartManage,
                              ),
                            ),
                        ],
                      ),
              ),
        body: navigationShell,
        bottomNavigationBar: SHOAppBottomNav(
          navigationShell: navigationShell,
          tabs: _tabs,
          tabLabel: _tabLabel,
        ),
      ),
    );
  }
}
