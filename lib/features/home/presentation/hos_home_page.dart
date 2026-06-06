import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';

import '../../../core/marketing/hos_popup_orchestrator.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/utils/hos_async_value_ui.dart';
import '../../../core/widgets/hos_error_view.dart';
import '../../../core/widgets/hos_banner_carousel.dart';
import '../../../core/widgets/hos_product_card.dart';
import '../../../core/widgets/hos_quick_entry_grid.dart';
import '../../../core/widgets/hos_skeleton_box.dart';
import '../../category/presentation/hos_category_controller.dart';
import 'hos_home_controller.dart';

class SHOHomePage extends ConsumerStatefulWidget {
  const SHOHomePage({super.key});

  @override
  ConsumerState<SHOHomePage> createState() => _SHOHomePageState();
}

class _SHOHomePageState extends ConsumerState<SHOHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) await SHOPopupOrchestrator.showHomePopups(context, ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(homeFeedProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return feedAsync.whenWidget(
      loading: const _SHOHomeSkeleton(),
      error: (error, _) => SHOAppErrorView(
        message: error.toString(),
        onRetry: () {
          ref.invalidate(homeFeedProvider);
          ref.invalidate(categoriesProvider);
        },
      ),
      data: (feed) {
        return RefreshIndicator(
          color: SHOAppColors.accent,
          onRefresh: () async {
            ref.invalidate(homeFeedProvider);
            ref.invalidate(categoriesProvider);
            await ref.read(homeFeedProvider.future);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: SHOAppSpacing.sm),
                    SHOBannerCarousel(banners: feed.banners),
                    const SizedBox(height: SHOAppSpacing.lg),
                    categoriesAsync.when(
                      data: (categories) => SHOQuickEntryGrid(items: categories),
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(horizontal: SHOAppSpacing.pagePadding),
                        child: SHOSkeletonBox(height: 90),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: SHOAppSpacing.lg),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.pagePadding),
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
                padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.pagePadding),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: SHOAppSpacing.gridGap,
                    crossAxisSpacing: SHOAppSpacing.gridGap,
                    childAspectRatio: 0.52,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = feed.products[index];
                      return SHOProductCard(
                        product: product,
                        onTap: () => context.push(SHOAppRoutes.product(product.id)),
                      );
                    },
                    childCount: feed.products.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: SHOAppSpacing.xxxl)),
            ],
          ),
        );
      },
    );
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
            Expanded(child: AspectRatio(aspectRatio: 0.52, child: SHOSkeletonBox())),
            SizedBox(width: SHOAppSpacing.gridGap),
            Expanded(child: AspectRatio(aspectRatio: 0.52, child: SHOSkeletonBox())),
          ],
        ),
      ],
    );
  }
}

class SHOHomeSearchBar extends StatelessWidget {
  const SHOHomeSearchBar({super.key, required this.onSearchTap});

  final VoidCallback onSearchTap;

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
          Text(
            l10n.appName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(width: SHOAppSpacing.lg),
          Expanded(
            child: GestureDetector(
              onTap: onSearchTap,
              child: Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.lg),
                decoration: BoxDecoration(
                  color: SHOAppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(SHOAppSpacing.buttonRadius),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 18, color: SHOAppColors.textMuted),
                    const SizedBox(width: SHOAppSpacing.sm),
                    Text(
                      l10n.searchHint,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
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
