import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/debug/hos_debug_tap_detector.dart';
import '../../core/navigation/hos_tab_badge_provider.dart';
import '../../core/theme/hos_colors.dart';
import '../../core/widgets/hos_tab_badge_icon.dart';
import '../../features/home/presentation/hos_home_page.dart';
import '../../l10n/app_localizations.dart';
import '../router/hos_routes.dart';

class SHOMainShell extends ConsumerWidget {
  const SHOMainShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    _SHOTabItem(
      route: SHOAppRoutes.home,
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      showSearchBar: true,
    ),
    _SHOTabItem(
      route: SHOAppRoutes.category,
      icon: Icons.grid_view_rounded,
      activeIcon: Icons.grid_view_rounded,
    ),
    _SHOTabItem(
      route: SHOAppRoutes.cart,
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag_rounded,
    ),
    _SHOTabItem(
      route: SHOAppRoutes.profile,
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  String _tabLabel(AppLocalizations l10n, int index) => switch (index) {
        0 => l10n.tabShop,
        1 => l10n.tabCategory,
        2 => l10n.tabBag,
        _ => l10n.tabMe,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final badges = ref.watch(tabBadgesProvider);
    final current = navigationShell.currentIndex;
    final showSearch = _tabs[current].showSearchBar;

    return Scaffold(
      backgroundColor: SHOAppColors.background,
      appBar: SHODebugTapAppBar(
        appBar: showSearch
            ? AppBar(
                toolbarHeight: 52,
                title: SHOHomeSearchBar(
                  onSearchTap: () => context.push(SHOAppRoutes.search),
                ),
                titleSpacing: 0,
              )
            : AppBar(
                title: Text(
                  _tabLabel(l10n, current),
                  style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
              ),
      ),
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: current,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        items: List.generate(_tabs.length, (index) {
          final tab = _tabs[index];
          final selected = index == current;
          return BottomNavigationBarItem(
            icon: SHOTabBadgeIcon(
              icon: selected ? tab.activeIcon : tab.icon,
              badge: badges[index],
            ),
            label: _tabLabel(l10n, index),
          );
        }),
      ),
    );
  }
}

class _SHOTabItem {
  const _SHOTabItem({
    required this.route,
    required this.icon,
    required this.activeIcon,
    this.showSearchBar = false,
  });

  final String route;
  final IconData icon;
  final IconData activeIcon;
  final bool showSearchBar;
}
