import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/platform/hybrid/hos_hybrid_embedded_ui.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/widgets/hos_empty_state.dart';
import 'package:shoo/core/widgets/hos_product_card.dart';
import 'package:shoo/core/widgets/hos_skeleton_box.dart';
import 'package:shoo/l10n/app_localizations.dart';
import 'package:shoo/features/category/presentation/state/hos_category_controller.dart';
import 'package:shoo/features/category/presentation/widgets/hos_category_product_filter.dart';
import 'package:shoo/features/category/presentation/widgets/hos_category_sort.dart';
import 'package:shoo/features/home/domain/entities/hos_product.dart';

class SHOCategoryProductsPage extends SHODataPage<List<SHOProduct>> {
  const SHOCategoryProductsPage({
    super.key,
    required this.leafCategoryId,
    required this.title,
  });

  final String leafCategoryId;
  final String title;

  @override
  SHODataPageState<List<SHOProduct>, SHOCategoryProductsPage> createState() =>
      _SHOCategoryProductsPageState();
}

class _SHOCategoryProductsPageState
    extends SHODataPageState<List<SHOProduct>, SHOCategoryProductsPage> {
  @override
  ProviderListenable<AsyncValue<List<SHOProduct>>> get dataProvider =>
      categoryProductsProvider(widget.leafCategoryId);

  @override
  void invalidateData(WidgetRef ref) =>
      ref.invalidate(categoryProductsProvider(widget.leafCategoryId));

  @override
  String get pageName => 'category_products';

  @override
  Map<String, Object?> get pageAnalyticsExtra => {
        'category_id': widget.leafCategoryId,
      };

  @override
  PreferredSizeWidget? buildPageAppBar(BuildContext context, WidgetRef ref) {
    return SHOHybridEmbeddedUi.appBar(
      AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  @override
  Widget? buildLoading(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: SHOAppSpacing.lg,
        crossAxisSpacing: SHOAppSpacing.lg,
        childAspectRatio: SHOProductCard.gridChildAspectRatio,
      ),
      itemCount: 4,
      itemBuilder: (_, __) => const SHOSkeletonBox(height: 220),
    );
  }

  @override
  Widget buildContent(
    BuildContext context,
    WidgetRef ref,
    List<SHOProduct> products,
  ) {
    final l10n = AppLocalizations.of(context);
    final sort = ref.watch(categorySortProvider);
    final filter = ref.watch(categoryProductFilterProvider);
    final filtered = applyCategoryProductFilters(
      products,
      sort: sort,
      filter: filter,
    );

    if (filtered.isEmpty) {
      return SHOEmptyState(title: l10n.noData);
    }

    return Stack(
      children: [
        GridView.builder(
          padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
              onTap: () => context.push(SHOAppRoutes.product(product.id)),
            );
          },
        ),
        const SHOCategoryProductFilterOverlay(),
      ],
    );
  }

  @override
  SHOAppShellPage buildShell(
    BuildContext context,
    WidgetRef ref, {
    required PreferredSizeWidget? appBar,
    required Widget body,
  }) {
    return SHOAppShellPage(
      appBar: appBar,
      body: SHOHybridEmbeddedUi.padBody(
        context,
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SHOCategorySortBar(trailing: SHOCategoryFilterButton()),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
