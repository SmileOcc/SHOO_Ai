import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/analytics/hos_page_analytics.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/theme/hos_theme_extension.dart';
import 'package:shoo/core/widgets/hos_pull_refresh.dart';
import 'package:shoo/core/widgets/hos_empty_state.dart';
import 'package:shoo/core/widgets/hos_error_view.dart';
import 'package:shoo/core/widgets/hos_skeleton_box.dart';
import 'package:shoo/l10n/app_localizations.dart';
import 'package:shoo/features/community/presentation/state/hos_community_controller.dart';
import 'package:shoo/features/community/presentation/widgets/hos_community_feed_cell.dart';
import 'package:shoo/features/community/presentation/widgets/hos_community_filter_tabs.dart';
import 'package:shoo/features/community/presentation/widgets/hos_community_menu_bar.dart';

class SHOCommunityPage extends ConsumerStatefulWidget {
  const SHOCommunityPage({super.key});

  @override
  ConsumerState<SHOCommunityPage> createState() => _SHOCommunityPageState();
}

class _SHOCommunityPageState extends ConsumerState<SHOCommunityPage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  final _scrollController = ScrollController();

  @override
  String get pageName => 'community';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  bool _onScrollNotification(ScrollNotification notification) {
    final feedState = ref.read(communityFeedListProvider);
    if (!feedState.hasMore || feedState.isLoadingMore) return false;
    if (notification is ScrollEndNotification &&
        notification.metrics.extentAfter < 120) {
      ref.read(communityFeedListProvider.notifier).loadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(communityFeedScrollToTopProvider, (previous, next) {
      if (previous != null && next > previous) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToTop());
      }
    });

    final feedState = ref.watch(communityFeedListProvider);
    final selectedSort = ref.watch(communitySortProvider);
    final l10n = AppLocalizations.of(context);
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    if (feedState.isInitialLoading) {
      return buildTrackedPage(
        SHOAppPullRefresh(
          onRefresh: () =>
              ref.read(communityFeedListProvider.notifier).refresh(),
          child: _buildLoadingSkeleton(),
        ),
        onRetry: () => ref.read(communityFeedListProvider.notifier).refresh(),
      );
    }

    if (feedState.isEmpty && feedState.error != null) {
      return buildTrackedPage(
        SHOAppErrorView(
          message: feedState.error.toString(),
          onRetry: () => ref.read(communityFeedListProvider.notifier).refresh(),
        ),
        onRetry: () => ref.read(communityFeedListProvider.notifier).refresh(),
      );
    }

    return buildTrackedPage(
      NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: SHOAppPullRefresh(
          onRefresh: () =>
              ref.read(communityFeedListProvider.notifier).refresh(),
          child: CustomScrollView(
            controller: _scrollController,
            physics: SHOAppPullRefresh.scrollPhysics,
            slivers: [
              SliverToBoxAdapter(
                child: SHOCommunityMenuBar(items: feedState.menuItems),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: SHOCommunityFilterTabsDelegate(
                  backgroundColor: backgroundColor,
                  selected: selectedSort,
                  l10n: l10n,
                  onSortChanged: (sort) {
                    if (sort == selectedSort) return;
                    ref.read(communitySortProvider.notifier).state = sort;
                  },
                ),
              ),
              if (feedState.error != null && feedState.items.isNotEmpty)
                SliverToBoxAdapter(
                  child: _RefreshErrorBanner(
                    message: feedState.error.toString(),
                    onRetry: () =>
                        ref.read(communityFeedListProvider.notifier).refresh(),
                  ),
                ),
              if (feedState.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: SHOEmptyState(title: l10n.noData),
                )
              else ...[
                SliverList.separated(
                  itemCount: feedState.items.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: context.shoTheme.divider,
                  ),
                  itemBuilder: (context, index) {
                    return SHOCommunityFeedCell(item: feedState.items[index]);
                  },
                ),
                SliverToBoxAdapter(child: _buildListFooter(context, feedState)),
              ],
            ],
          ),
        ),
      ),
      onRetry: () => ref.read(communityFeedListProvider.notifier).refresh(),
    );
  }

  Widget _buildListFooter(
    BuildContext context,
    SHOCommunityFeedListState feedState,
  ) {
    final l10n = AppLocalizations.of(context);

    if (feedState.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(SHOAppSpacing.xl),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (feedState.loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.all(SHOAppSpacing.xl),
        child: Center(
          child: TextButton.icon(
            onPressed: () =>
                ref.read(communityFeedListProvider.notifier).loadMore(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(l10n.retry),
          ),
        ),
      );
    }

    if (!feedState.hasMore && feedState.items.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(SHOAppSpacing.xl),
        child: Center(
          child: Text(
            l10n.pagedListNoMore,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.shoTheme.textMuted,
            ),
          ),
        ),
      );
    }

    return const SizedBox(height: SHOAppSpacing.xxxl);
  }

  Widget _buildLoadingSkeleton() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
      children: const [
        SHOSkeletonBox(height: 72),
        SizedBox(height: SHOAppSpacing.lg),
        SHOSkeletonBox(height: 28),
        SizedBox(height: SHOAppSpacing.lg),
        SHOSkeletonBox(height: 180),
        SizedBox(height: SHOAppSpacing.lg),
        SHOSkeletonBox(height: 180),
      ],
    );
  }
}

class SHOCommunityPageError extends ConsumerWidget {
  const SHOCommunityPageError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SHOAppErrorView(
      message: message,
      onRetry: () => ref.read(communityFeedListProvider.notifier).refresh(),
    );
  }
}

class _RefreshErrorBanner extends StatelessWidget {
  const _RefreshErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: SHOAppColors.error.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SHOAppSpacing.pagePadding,
          vertical: SHOAppSpacing.md,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              size: 16,
              color: SHOAppColors.error,
            ),
            const SizedBox(width: SHOAppSpacing.sm),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: SHOAppColors.error),
              ),
            ),
            TextButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}
