import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/constants/hos_constants.dart';
import 'package:shoo/core/pagination/hos_paged_mergeable_family_async_notifier.dart';
import 'package:shoo/features/review/data/repositories/hos_review_repository_impl.dart';
import 'package:shoo/features/review/domain/entities/hos_review.dart';

class SHOReviewsPagedState extends SHOPagedMergeableContainer<SHOProductReview> {
  SHOReviewsPagedState({
    this.summary,
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  final SHOProductReviewSummary? summary;
  final List<SHOProductReview> items;
  @override
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  @override
  List<SHOProductReview> get pagedItems => items;

  @override
  bool get pagedHasMore => hasMore;

  @override
  bool get pagedIsLoadingMore => isLoadingMore;

  @override
  SHOReviewsPagedState copyWithLoadingMore(bool loading) {
    return SHOReviewsPagedState(
      summary: summary,
      items: items,
      page: page,
      hasMore: hasMore,
      isLoadingMore: loading,
    );
  }

  @override
  SHOReviewsPagedState mergeNextPage(SHOPagedMergeableContainer<SHOProductReview> next) {
    final nextPage = next as SHOReviewsPagedState;
    return SHOReviewsPagedState(
      summary: summary ?? nextPage.summary,
      items: [...items, ...nextPage.items],
      page: nextPage.page,
      hasMore: nextPage.hasMore,
    );
  }
}

final reviewsPagedProvider =
    AutoDisposeAsyncNotifierProviderFamily<
      ReviewsPagedNotifier,
      SHOReviewsPagedState,
      String
    >(ReviewsPagedNotifier.new);

class ReviewsPagedNotifier
    extends AutoDisposeFamilyAsyncNotifier<SHOReviewsPagedState, String>
    with SHOPagedMergeableFamilyAsyncNotifier<SHOProductReview, SHOReviewsPagedState, String> {
  @override
  SHOReviewsPagedState emptyState(String arg) => SHOReviewsPagedState();

  @override
  Future<SHOReviewsPagedState> fetchPage(
    String productId,
    int page, {
    bool refreshing = false,
  }) async {
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
