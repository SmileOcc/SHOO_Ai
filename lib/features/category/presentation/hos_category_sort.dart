import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_extension.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/domain/hos_product.dart';
import '../domain/hos_category.dart';
import 'hos_category_controller.dart';

enum SHOCategorySort {
  all,
  hot,
  newest,
}

extension SHOCategorySortX on SHOCategorySort {
  String label(AppLocalizations l10n) => switch (this) {
        SHOCategorySort.all => l10n.categorySortAll,
        SHOCategorySort.hot => l10n.categorySortHot,
        SHOCategorySort.newest => l10n.categorySortNewest,
      };
}

List<SHOCategoryLeaf> sortCategoryLeaves(
  List<SHOCategoryLeaf> leaves,
  SHOCategorySort sort,
) {
  final copy = List<SHOCategoryLeaf>.from(leaves);
  switch (sort) {
    case SHOCategorySort.all:
      return copy;
    case SHOCategorySort.hot:
      copy.sort((a, b) => a.name.compareTo(b.name));
      return copy;
    case SHOCategorySort.newest:
      copy.sort((a, b) => b.id.compareTo(a.id));
      return copy;
  }
}

List<SHOProduct> sortCategoryProducts(
  List<SHOProduct> products,
  SHOCategorySort sort,
) {
  final copy = List<SHOProduct>.from(products);
  switch (sort) {
    case SHOCategorySort.all:
      return copy;
    case SHOCategorySort.hot:
      copy.sort((a, b) => b.soldCount.compareTo(a.soldCount));
      return copy;
    case SHOCategorySort.newest:
      copy.sort((a, b) => b.id.compareTo(a.id));
      return copy;
  }
}

class SHOCategorySortBar extends ConsumerWidget {
  const SHOCategorySortBar({super.key, this.trailing});

  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(categorySortProvider);

    return ColoredBox(
      color: context.shoSurface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SHOAppSpacing.pagePadding,
          SHOAppSpacing.sm,
          SHOAppSpacing.pagePadding,
          SHOAppSpacing.sm,
        ),
        child: Row(
          children: [
            for (final sort in SHOCategorySort.values) ...[
              _SortChip(
                label: sort.label(l10n),
                selected: selected == sort,
                onTap: () {
                  ref.read(categorySortProvider.notifier).state = sort;
                  ref.read(categoryProductFilterPanelOpenProvider.notifier).state =
                      false;
                },
              ),
              if (sort != SHOCategorySort.values.last)
                const SizedBox(width: SHOAppSpacing.sm),
            ],
            if (trailing != null) ...[
              const Spacer(),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.shoTheme;

    return Material(
      color: selected ? SHOAppColors.accent.withValues(alpha: 0.12) : theme.surfaceMuted,
      borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SHOAppSpacing.lg,
            vertical: SHOAppSpacing.sm,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? SHOAppColors.accent : theme.textSecondary,
                ),
          ),
        ),
      ),
    );
  }
}
