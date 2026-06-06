import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/hos_constants.dart';
import '../data/hos_review_repository.dart';
import '../domain/hos_review.dart';

class SHOReviewsPagedState {
  const SHOReviewsPagedState({
    this.summary,
    this.items = const [],
    this.page = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  final SHOProductReviewSummary? summary;
  final List<SHOProductReview> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
}

final reviewsPagedProvider = AutoDisposeAsyncNotifierProviderFamily<
    ReviewsPagedNotifier, SHOReviewsPagedState, String>(
  ReviewsPagedNotifier.new,
);

class ReviewsPagedNotifier
    extends AutoDisposeFamilyAsyncNotifier<SHOReviewsPagedState, String> {
  @override
  Future<SHOReviewsPagedState> build(String productId) => _fetchPage(productId, 1);

  Future<void> refresh(String productId) async {
    state = const AsyncLoading();
    state = AsyncData(await _fetchPage(productId, 1));
  }

  Future<void> loadMore(String productId) async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(
      SHOReviewsPagedState(
        summary: current.summary,
        items: current.items,
        page: current.page,
        hasMore: current.hasMore,
        isLoadingMore: true,
      ),
    );

    try {
      final repo = ref.read(reviewRepositoryProvider);
      final nextPage = current.page + 1;
      final summary = await repo.getReviewsPage(
        productId,
        page: nextPage,
        pageSize: SHOAppConstants.listPageSize,
      );
      state = AsyncData(
        SHOReviewsPagedState(
          summary: current.summary ?? summary,
          items: [...current.items, ...summary.items],
          page: nextPage,
          hasMore: summary.hasMore,
        ),
      );
    } catch (error, stack) {
      state = AsyncError(error, stack);
    }
  }

  Future<SHOReviewsPagedState> _fetchPage(String productId, int page) async {
    final repo = ref.read(reviewRepositoryProvider);
    final summary = await repo.getReviewsPage(
      productId,
      page: page,
      pageSize: SHOAppConstants.listPageSize,
    );
    return SHOReviewsPagedState(
      summary: summary,
      items: summary.items,
      page: page,
      hasMore: summary.hasMore,
    );
  }
}
