import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_extension.dart';
import '../../../core/widgets/hos_loading_state.dart';
import '../../../core/widgets/hos_paged_scroll_view.dart';
import '../../../l10n/app_localizations.dart';
import 'hos_review_submit_sheet.dart';
import 'hos_review_tile.dart';
import 'hos_reviews_paged_controller.dart';

class SHOReviewsPage extends ConsumerStatefulWidget {
  const SHOReviewsPage({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<SHOReviewsPage> createState() => _SHOReviewsPageState();
}

class _SHOReviewsPageState extends ConsumerState<SHOReviewsPage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reviewsAsync = ref.watch(reviewsPagedProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reviewsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => SHOReviewSubmitSheet.show(
          context,
          productId: widget.productId,
        ),
        icon: const Icon(Icons.rate_review_outlined),
        label: Text(l10n.reviewSubmitAction),
      ),
      body: reviewsAsync.when(
        loading: () => const SHOAppLoadingState(
          state: SHOLoadingState.loading,
          loadingWidget: SHOAppListSkeleton(itemCount: 6),
        ),
        error: (error, _) => SHOAppLoadingState(
          state: SHOLoadingState.error,
          message: error.toString(),
          onRetry: () =>
              ref.read(reviewsPagedProvider(widget.productId).notifier).refresh(
                    widget.productId,
                  ),
        ),
        data: (paged) {
          if (paged.items.isEmpty) {
            return SHOAppLoadingState(
              state: SHOLoadingState.empty,
              message: l10n.reviewsEmpty,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (paged.summary != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SHOAppSpacing.pagePadding,
                    SHOAppSpacing.pagePadding,
                    SHOAppSpacing.pagePadding,
                    SHOAppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${paged.summary!.averageRating}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(width: SHOAppSpacing.sm),
                      Text(
                        l10n.reviewsCount(paged.summary!.totalCount),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: SHOPagedScrollView(
                  controller: _scrollController,
                  itemCount: paged.items.length,
                  onRefresh: () => ref
                      .read(reviewsPagedProvider(widget.productId).notifier)
                      .refresh(widget.productId),
                  onLoadMore: () => ref
                      .read(reviewsPagedProvider(widget.productId).notifier)
                      .loadMore(widget.productId),
                  isLoadingMore: paged.isLoadingMore,
                  hasMore: paged.hasMore,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: context.shoTheme.divider),
                  itemBuilder: (context, index) =>
                      SHOReviewTile(review: paged.items[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
