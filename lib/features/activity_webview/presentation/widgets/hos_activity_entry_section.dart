import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/features/activity_webview/domain/entities/hos_activity_promo.dart';

class SHOActivityEntrySection extends StatelessWidget {
  const SHOActivityEntrySection({
    super.key,
    required this.navigation,
  });

  final SHOActivityNavigation? navigation;

  @override
  Widget build(BuildContext context) {
    final nav = navigation;
    if (nav == null) return const SizedBox.shrink();

    final entries = <_EntryItem>[
      _EntryItem(
        icon: Icons.shopping_bag_outlined,
        label: '活动商品列表',
        onTap: () => context.push(
          SHOAppRoutes.categoryProductsFiltered(
            leafId: nav.productListLeafId,
            title: nav.productListTitle,
          ),
        ),
      ),
      _EntryItem(
        icon: Icons.inventory_2_outlined,
        label: '商品详情',
        onTap: () => context.push(SHOAppRoutes.product(nav.sampleProductId)),
      ),
      _EntryItem(
        icon: Icons.article_outlined,
        label: '活动详情',
        onTap: () => context.push(SHOAppRoutes.activityDetail),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < entries.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              _EntryChip(item: entries[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _EntryItem {
  const _EntryItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _EntryChip extends StatelessWidget {
  const _EntryChip({required this.item});

  final _EntryItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                item.label,
                style: theme.textTheme.labelLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
