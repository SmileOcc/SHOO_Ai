import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/core/analytics/hos_tab_analytics.dart';
import 'package:shoo/core/navigation/hos_tab_badge_provider.dart';
import 'package:shoo/core/widgets/hos_tab_badge_icon.dart';
import 'package:shoo/l10n/app_localizations.dart';
import 'package:shoo/app/router/hos_routes.dart';

class SHOAppBottomNav extends ConsumerWidget {
  const SHOAppBottomNav({
    super.key,
    required this.navigationShell,
    required this.tabs,
    required this.tabLabel,
  });

  final StatefulNavigationShell navigationShell;
  final List<SHOAppTabItem> tabs;
  final String Function(AppLocalizations l10n, int index) tabLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final badges = ref.watch(tabBadgesProvider);
    final current = navigationShell.currentIndex;

    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        currentIndex: current,
        enableFeedback: false,
        onTap: (index) {
          final fromIndex = navigationShell.currentIndex;
          final isReselect = index == fromIndex;
          SHOTabAnalyticsReporter.reportSwitch(
            fromIndex: fromIndex,
            toIndex: index,
            isReselect: isReselect,
          );
          navigationShell.goBranch(
            index,
            initialLocation: isReselect,
          );
        },
        items: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final selected = index == current;
          return BottomNavigationBarItem(
            icon: SHOTabBadgeIcon(
              icon: selected ? tab.activeIcon : tab.icon,
              badge: badges[index],
            ),
            label: tabLabel(l10n, index),
          );
        }),
      ),
    );
  }
}

class SHOAppTabItem {
  const SHOAppTabItem({
    required this.route,
    required this.icon,
    required this.activeIcon,
    this.showSearchBar = false,
    this.showCommunityActions = false,
  });

  final String route;
  final IconData icon;
  final IconData activeIcon;
  final bool showSearchBar;
  final bool showCommunityActions;
}
