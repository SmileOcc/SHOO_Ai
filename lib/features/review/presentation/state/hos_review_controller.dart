import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/review/data/repositories/hos_review_repository_impl.dart';
import 'package:shoo/features/review/domain/entities/hos_review.dart';

final productReviewsProvider =
    FutureProvider.family<SHOProductReviewSummary, String>((
      ref,
      productId,
    ) async {
      final repo = ref.watch(reviewRepositoryProvider);
      return repo.getReviews(productId);
    });
