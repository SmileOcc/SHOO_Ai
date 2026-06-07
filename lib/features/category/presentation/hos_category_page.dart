import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_theme_extension.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/utils/hos_async_value_ui.dart';
import '../../../core/widgets/hos_empty_state.dart';
import '../../../core/widgets/hos_error_view.dart';
import '../../../core/widgets/hos_profile_section_card.dart';
import '../../../core/widgets/hos_skeleton_box.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/presentation/hos_profile_controller.dart';
import '../domain/hos_category.dart';
import 'hos_category_controller.dart';
import 'hos_category_sort.dart';

bool _hasStaleCategoryCache(List<SHOCategoryItem> items) {
  for (final item in items) {
    try {
      // ignore: unnecessary_statements
      item.groups;
    } catch (_) {
      return true;
    }
  }
  return false;
}

class SHOCategoryPage extends ConsumerWidget {
  const SHOCategoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.whenWidget(
      loading: Row(
        children: [
          SizedBox(
            width: 96,
            child: ListView.builder(
              itemCount: 8,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.all(SHOAppSpacing.md),
                child: SHOSkeletonBox(height: 36),
              ),
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.all(SHOAppSpacing.pagePadding),
              child: SHOSkeletonBox(height: 320),
            ),
          ),
        ],
      ),
      error: (error, _) => SHOAppErrorView(
        message: error.toString(),
        onRetry: () => ref.invalidate(categoriesProvider),
      ),
      data: (rawCategories) {
        if (_hasStaleCategoryCache(rawCategories)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.invalidate(categoriesProvider);
          });
        }

        final categories = normalizeCategoryItems(rawCategories);
        if (categories.isEmpty) {
          return SHOEmptyState(title: AppLocalizations.of(context).noData);
        }

        final selectedIndex = ref.watch(selectedCategoryIndexProvider)
            .clamp(0, categories.length - 1);
        final selectedCategory = categories[selectedIndex];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SHOCategorySortBar(),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PrimaryCategoryRail(
                    categories: categories,
                    selectedIndex: selectedIndex,
                    onSelected: (index) {
                      ref.read(selectedCategoryIndexProvider.notifier).state =
                          index;
                      ref
                          .read(profileActivityProvider.notifier)
                          .recordFollowedCategory(categories[index].id);
                    },
                  ),
                  Expanded(
                    child: _CategoryGroupPanel(category: selectedCategory),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PrimaryCategoryRail extends StatelessWidget {
  const _PrimaryCategoryRail({
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<SHOCategoryItem> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = context.shoTheme;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return ColoredBox(
      color: theme.surfaceMuted,
      child: SizedBox(
        width: 96,
        child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final item = categories[index];
            final selected = index == selectedIndex;

            return InkWell(
              onTap: () => onSelected(index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SHOAppSpacing.sm,
                  vertical: SHOAppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  color: selected ? context.shoSurface : null,
                  border: Border(
                    left: BorderSide(
                      color: selected ? SHOAppColors.accent : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Text(item.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: SHOAppSpacing.xs),
                    Text(
                      item.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? onSurface : theme.textSecondary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryGroupPanel extends ConsumerWidget {
  const _CategoryGroupPanel({required this.category});

  final SHOCategoryItem category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(categorySortProvider);
    final groups = safeCategoryGroups(category);
    if (groups.isEmpty) {
      return SHOEmptyState(title: AppLocalizations.of(context).noData);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
      itemCount: groups.length,
      separatorBuilder: (_, __) => const SizedBox(height: SHOAppSpacing.lg),
      itemBuilder: (context, index) {
        final group = groups[index];
        return _SecondaryGroupSection(group: group, sort: sort);
      },
    );
  }
}

class _SecondaryGroupSection extends StatelessWidget {
  const _SecondaryGroupSection({
    required this.group,
    required this.sort,
  });

  final SHOCategoryGroup group;
  final SHOCategorySort sort;

  @override
  Widget build(BuildContext context) {
    final theme = context.shoTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: SHOAppSpacing.xs,
            bottom: SHOAppSpacing.sm,
          ),
          child: Text(
            group.name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.shoSurface,
            borderRadius: BorderRadius.circular(SHOProfileSectionCard.radius),
            border: Border.all(
              color: theme.border,
              width: SHOProfileSectionCard.borderWidth,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(SHOAppSpacing.md),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const columns = 3;
                const gap = SHOAppSpacing.sm;
                final cellWidth =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;

                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final leaf in sortCategoryLeaves(group.children, sort))
                      SizedBox(
                        width: cellWidth,
                        child: _TertiaryCategoryChip(leaf: leaf),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _TertiaryCategoryChip extends StatelessWidget {
  const _TertiaryCategoryChip({required this.leaf});

  final SHOCategoryLeaf leaf;

  @override
  Widget build(BuildContext context) {
    final theme = context.shoTheme;

    return Material(
      color: theme.surfaceMuted,
      borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
      child: InkWell(
        onTap: () => context.push(
          SHOAppRoutes.categoryProductsFiltered(
            leafId: leaf.id,
            title: leaf.name,
          ),
        ),
        borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SHOAppSpacing.sm,
            vertical: SHOAppSpacing.md,
          ),
          child: Text(
            leaf.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
          ),
        ),
      ),
    );
  }
}
