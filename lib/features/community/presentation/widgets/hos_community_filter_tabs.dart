import 'package:flutter/material.dart';

import 'package:shoo/core/analytics/hos_analytics_manager.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/l10n/app_localizations.dart';
import 'package:shoo/features/community/domain/entities/hos_community_models.dart';

class SHOCommunityFilterTabs extends StatelessWidget {
  const SHOCommunityFilterTabs({
    super.key,
    required this.selected,
    required this.l10n,
    required this.onSortChanged,
  });

  static const sorts = SHOCommunitySort.values;

  final SHOCommunitySort selected;
  final AppLocalizations l10n;
  final ValueChanged<SHOCommunitySort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: sorts.map((sort) {
        final isSelected = sort == selected;
        final label = switch (sort) {
          SHOCommunitySort.latest => l10n.communitySortLatest,
          SHOCommunitySort.all => l10n.communitySortAll,
          SHOCommunitySort.hot => l10n.communitySortHot,
        };
        return Padding(
          padding: const EdgeInsets.only(right: SHOAppSpacing.xl),
          child: InkWell(
            onTap: () {
              if (sort == selected) return;
              onSortChanged(sort);
              SHOAnalyticsManager.instance.track('community_sort_switch', {
                'sort': sort.name,
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected
                        ? SHOAppColors.textPrimary
                        : SHOAppColors.textMuted,
                  ),
                ),
                const SizedBox(height: SHOAppSpacing.xs),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: isSelected ? 20 : 0,
                  height: 2,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? SHOAppColors.accent
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class SHOCommunityFilterTabsDelegate extends SliverPersistentHeaderDelegate {
  SHOCommunityFilterTabsDelegate({
    required this.backgroundColor,
    required this.selected,
    required this.l10n,
    required this.onSortChanged,
  });

  final Color backgroundColor;
  final SHOCommunitySort selected;
  final AppLocalizations l10n;
  final ValueChanged<SHOCommunitySort> onSortChanged;

  static const _tabBarHeight = 44.0;

  @override
  double get minExtent => _tabBarHeight;

  @override
  double get maxExtent => _tabBarHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: backgroundColor,
      child: SizedBox(
        height: _tabBarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SHOAppSpacing.pagePadding,
          ),
          child: SHOCommunityFilterTabs(
            selected: selected,
            l10n: l10n,
            onSortChanged: onSortChanged,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SHOCommunityFilterTabsDelegate oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.selected != selected ||
        oldDelegate.l10n != l10n;
  }
}
