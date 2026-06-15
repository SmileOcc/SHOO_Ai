import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/hos_page_analytics.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/widgets/hos_empty_state.dart';
import '../../../core/widgets/hos_error_view.dart';
import '../../../core/widgets/hos_skeleton_box.dart';
import '../../../l10n/app_localizations.dart';
import 'hos_community_controller.dart';
import 'hos_community_feed_cell.dart';
import 'hos_community_filter_tabs.dart';
import 'hos_community_menu_bar.dart';

class SHOCommunityPage extends ConsumerStatefulWidget {
  const SHOCommunityPage({super.key});

  @override
  ConsumerState<SHOCommunityPage> createState() => _SHOCommunityPageState();
}

class _SHOCommunityPageState extends ConsumerState<SHOCommunityPage>
    with SHOPageRouteAnalyticsMixin {
  final _scrollController = ScrollController();

  @override
  String get pageAnalyticsName => 'SHOCommunityPage';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final state = ref.read(communityFeedListProvider);
    if (!state.hasMore || state.loadingMore || state.items.isEmpty) return;

    final threshold = _scrollController.position.maxScrollExtent - 240;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(communityFeedListProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() {
    return ref.read(communityFeedListProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(communityFeedListProvider);
    final selectedSort = ref.watch(communitySortProvider);
    final l10n = AppLocalizations.of(context);
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    if (feedState.items.isEmpty && feedState.loadingMore) {
      return _buildLoadingSkeleton();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
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
          if (feedState.items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: SHOEmptyState(title: l10n.noData),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(bottom: SHOAppSpacing.xxxl),
              sliver: SliverList.separated(
                itemCount: feedState.items.length +
                    (feedState.loadingMore ? 1 : 0),
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  color: SHOAppColors.divider,
                ),
                itemBuilder: (context, index) {
                  if (index >= feedState.items.length) {
                    return const Padding(
                      padding: EdgeInsets.all(SHOAppSpacing.xl),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return SHOCommunityFeedCell(item: feedState.items[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView(
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
  const SHOCommunityPageError({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SHOAppErrorView(
      message: message,
      onRetry: () => ref.read(communityFeedListProvider.notifier).refresh(),
    );
  }
}
