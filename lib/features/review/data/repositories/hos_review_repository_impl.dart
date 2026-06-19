import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/review/domain/entities/hos_review.dart';
import 'package:shoo/features/review/data/datasources/remote/hos_review_remote_ds.dart';

final reviewRepositoryProvider = Provider<SHOReviewRepository>((ref) {
  return SHOReviewRepository(ref.watch(reviewApiProvider));
});

class SHOReviewRepository {
  SHOReviewRepository(this._api);

  final SHOReviewApi _api;

  Future<SHOProductReviewSummary> getReviews(String productId) =>
      getReviewsPage(productId);

  Future<SHOProductReviewSummary> getReviewsPage(
    String productId, {
    int page = 1,
    int pageSize = 10,
  }) {
    return _api.fetchReviews(productId, page: page, pageSize: pageSize);
  }
}
