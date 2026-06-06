import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/hos_review_repository.dart';
import '../domain/hos_review.dart';

final productReviewsProvider =
    FutureProvider.family<SHOProductReviewSummary, String>((ref, productId) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getReviews(productId);
});
