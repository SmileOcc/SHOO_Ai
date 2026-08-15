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
import 'package:shoo/features/home/domain/entities/hos_home_config.dart';
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
    final l10n = AppLocalizations.of(context);
    final sectionTitle = feed.feedConfig.title.trim().isEmpty
        ? l10n.recommendedTitle
        : feed.feedConfig.title;
    final quickItems = feed.quickEntries
        .map(
          (e) => SHOCategoryItem(id: e.id, name: e.title, icon: e.icon),
        )
        .toList();

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
                if (quickItems.isNotEmpty)
                  SHOQuickEntryGrid(
                    items: quickItems,
                    onTap: (item) {
                      final entry = feed.quickEntries.firstWhere(
                        (e) => e.id == item.id,
                        orElse: () => SHOHomeQuickEntry(
                          id: item.id,
                          title: item.name,
                          icon: item.icon,
                          link: '/',
                        ),
                      );
                      _onQuickEntryTap(context, entry);
                    },
                  )
                else
                  const SizedBox.shrink(),
                const SizedBox(height: SHOAppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SHOAppSpacing.pagePadding,
                  ),
                  child: Text(
                    sectionTitle,
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

void _onQuickEntryTap(BuildContext context, SHOHomeQuickEntry entry) {
  final raw = entry.link.trim();
  if (raw.isEmpty) return;

  final uri = Uri.tryParse(raw);
  if (uri == null) {
    context.push(raw);
    return;
  }

  final path = uri.path.isEmpty ? '/' : uri.path;
  if (path == SHOAppRoutes.category || path == '/category') {
    context.go(SHOAppRoutes.category);
    return;
  }

  final location = uri.hasQuery ? '$path?${uri.query}' : path;
  context.push(location);
}

class _SHOHomeSkeleton extends StatelessWidget {
  const _SHOHomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: SHOAppSpacing.xs),
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SHOAppSpacing.pagePadding,
                ),
                child: SHOSkeletonBox(height: 160),
              ),
              const SizedBox(height: SHOAppSpacing.sm),
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SHOAppSpacing.pagePadding,
                ),
                child: SHOSkeletonBox(height: 90),
              ),
              const SizedBox(height: SHOAppSpacing.lg),
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SHOAppSpacing.pagePadding,
                ),
                child: SHOSkeletonBox(height: 20, width: 120),
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
            delegate: SliverChildBuilderDelegate(
              (context, index) => const SHOSkeletonBox(),
              childCount: 4,
            ),
          ),
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
