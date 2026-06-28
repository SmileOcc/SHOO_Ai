import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/marketing/hos_popup_orchestrator.dart';
import 'package:shoo/core/theme/hos_theme_extension.dart';
import 'package:shoo/l10n/app_localizations.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/widgets/hos_banner_carousel.dart';
import 'package:shoo/core/widgets/hos_pull_refresh.dart';
import 'package:shoo/core/widgets/hos_product_card.dart';
import 'package:shoo/core/widgets/hos_quick_entry_grid.dart';
import 'package:shoo/core/widgets/hos_skeleton_box.dart';
import 'package:shoo/features/category/domain/entities/hos_category.dart';
import 'package:shoo/features/category/presentation/state/hos_category_controller.dart';
import 'package:shoo/features/flash_sale/domain/hos_flash_sale_activities.dart';
import 'package:shoo/features/home/presentation/state/hos_home_controller.dart';

class SHOHomePage extends SHODataPage<SHOHomeFeed> {
  const SHOHomePage({super.key});

  @override
  SHODataPageState<SHOHomeFeed, SHOHomePage> createState() =>
      _SHOHomePageState();
}

class _SHOHomePageState extends SHODataPageState<SHOHomeFeed, SHOHomePage> {
  @override
  ProviderListenable<AsyncValue<SHOHomeFeed>> get dataProvider =>
      homeFeedProvider;

  @override
  void invalidateData(WidgetRef ref) {
    ref.invalidate(homeFeedProvider);
    ref.invalidate(categoriesProvider);
  }

  @override
  String get pageName => 'home';

  @override
  void onPagePreload(WidgetRef ref) {
    super.onPagePreload(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) await SHOPopupOrchestrator.showHomePopups(context, ref);
    });
  }

  @override
  Widget? buildLoading(BuildContext context) => const _SHOHomeSkeleton();

  @override
  Widget buildContent(BuildContext context, WidgetRef ref, SHOHomeFeed feed) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return SHOAppPullRefresh(
      onRefresh: () async {
        invalidateData(ref);
        await ref.read(homeFeedProvider.future);
      },
      child: CustomScrollView(
        physics: SHOAppPullRefresh.scrollPhysics,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: SHOAppSpacing.xs),
                SHOBannerCarousel(banners: feed.banners),
                const SizedBox(height: SHOAppSpacing.sm),
                categoriesAsync.when(
                  data: (categories) => SHOQuickEntryGrid(
                    items: _homeQuickEntries(categories),
                    onTap: (item) => _onQuickEntryTap(context, item),
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SHOAppSpacing.pagePadding,
                    ),
                    child: SHOSkeletonBox(height: 90),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: SHOAppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SHOAppSpacing.pagePadding,
                  ),
                  child: Text(
                    AppLocalizations.of(context).recommendedTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(height: SHOAppSpacing.md),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: SHOAppSpacing.pagePadding,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: SHOAppSpacing.lg,
                crossAxisSpacing: SHOAppSpacing.lg,
                childAspectRatio: SHOProductCard.gridChildAspectRatio,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = feed.products[index];
                return SHOProductCard(
                  product: product,
                  onTap: () => context.push(SHOAppRoutes.product(product.id)),
                );
              }, childCount: feed.products.length),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: SHOAppSpacing.xxxl)),
        ],
      ),
    );
  }
}

List<SHOCategoryItem> _homeQuickEntries(List<SHOCategoryItem> categories) {
  final rest = categories.length > 2
      ? categories.sublist(2)
      : const <SHOCategoryItem>[];
  return [
    const SHOCategoryItem(id: 'home-flash', name: '抢购活动', icon: '⚡'),
    const SHOCategoryItem(id: 'home-discount', name: '折扣活动', icon: '🏷️'),
    ...rest,
  ];
}

void _onQuickEntryTap(BuildContext context, SHOCategoryItem item) {
  switch (item.id) {
    case 'home-flash':
      context.push(
        SHOAppRoutes.flashSaleFor(activityId: SHOFlashSaleActivities.flash),
      );
    case 'home-discount':
      context.push(
        SHOAppRoutes.flashSaleFor(activityId: SHOFlashSaleActivities.discount),
      );
    default:
      context.go(SHOAppRoutes.category);
  }
}

class _SHOHomeSkeleton extends StatelessWidget {
  const _SHOHomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
      children: const [
        SHOSkeletonBox(height: 140),
        SizedBox(height: SHOAppSpacing.lg),
        SHOSkeletonBox(height: 90),
        SizedBox(height: SHOAppSpacing.lg),
        SHOSkeletonBox(height: 16, width: 180),
        SizedBox(height: SHOAppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AspectRatio(aspectRatio: 0.52, child: SHOSkeletonBox()),
            ),
            SizedBox(width: SHOAppSpacing.gridGap),
            Expanded(
              child: AspectRatio(aspectRatio: 0.52, child: SHOSkeletonBox()),
            ),
          ],
        ),
      ],
    );
  }
}

class SHOHomeSearchBar extends StatelessWidget {
  const SHOHomeSearchBar({
    super.key,
    required this.onSearchTap,
    this.onBrandTap,
  });

  final VoidCallback onSearchTap;
  final VoidCallback? onBrandTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SHOAppSpacing.pagePadding,
        SHOAppSpacing.sm,
        SHOAppSpacing.pagePadding,
        SHOAppSpacing.sm,
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onBrandTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SHOAppSpacing.xs,
                  vertical: SHOAppSpacing.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.dehaze_rounded,
                      size: 20,
                      color: context.shoTheme.textSecondary,
                    ),
                    const SizedBox(width: SHOAppSpacing.xs),
                    Text(
                      l10n.appName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: SHOAppSpacing.lg),
          Expanded(
            child: GestureDetector(
              onTap: onSearchTap,
              child: Container(
                height: 34,
                padding: const EdgeInsets.symmetric(
                  horizontal: SHOAppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  color: context.shoTheme.surfaceMuted,
                  borderRadius: BorderRadius.circular(
                    SHOAppSpacing.buttonRadius,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      size: 18,
                      color: context.shoTheme.textMuted,
                    ),
                    const SizedBox(width: SHOAppSpacing.sm),
                    Text(
                      l10n.searchHint,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: SHOAppSpacing.sm),
          const Icon(Icons.notifications_none_rounded, size: 22),
        ],
      ),
    );
  }
}
