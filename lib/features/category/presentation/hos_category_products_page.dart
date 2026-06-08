import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/utils/hos_async_value_ui.dart';
import '../../../core/widgets/hos_empty_state.dart';
import '../../../core/widgets/hos_error_view.dart';
import '../../../core/widgets/hos_product_card.dart';
import '../../../core/widgets/hos_skeleton_box.dart';
import '../../../l10n/app_localizations.dart';
import 'hos_category_controller.dart';
import 'hos_category_product_filter.dart';
import 'hos_category_sort.dart';

class SHOCategoryProductsPage extends ConsumerWidget {
  const SHOCategoryProductsPage({
    super.key,
    required this.leafCategoryId,
    required this.title,
  });

  final String leafCategoryId;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sort = ref.watch(categorySortProvider);
    final filter = ref.watch(categoryProductFilterProvider);
    final productsAsync = ref.watch(categoryProductsProvider(leafCategoryId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SHOCategorySortBar(trailing: SHOCategoryFilterButton()),
          Expanded(
            child: Stack(
              children: [
                productsAsync.whenWidget(
                  loading: GridView.builder(
                    padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: SHOAppSpacing.lg,
                      crossAxisSpacing: SHOAppSpacing.lg,
                      childAspectRatio: SHOProductCard.gridChildAspectRatio,
                    ),
                    itemCount: 4,
                    itemBuilder: (_, __) => const SHOSkeletonBox(height: 220),
                  ),
                  error: (error, _) => SHOAppErrorView(
                    message: error.toString(),
                    onRetry: () =>
                        ref.invalidate(categoryProductsProvider(leafCategoryId)),
                  ),
                  data: (products) {
                    final filtered = applyCategoryProductFilters(
                      products,
                      sort: sort,
                      filter: filter,
                    );

                    if (filtered.isEmpty) {
                      return SHOEmptyState(title: l10n.noData);
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: SHOAppSpacing.lg,
                        crossAxisSpacing: SHOAppSpacing.lg,
                        childAspectRatio: SHOProductCard.gridChildAspectRatio,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final product = filtered[index];
                        return SHOProductCard(
                          product: product,
                          onTap: () =>
                              context.push(SHOAppRoutes.product(product.id)),
                        );
                      },
                    );
                  },
                ),
                const SHOCategoryProductFilterOverlay(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
