import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/hos_dio_client.dart';
import '../domain/hos_review.dart';

final reviewApiProvider = Provider<SHOReviewApi>((ref) {
  return SHOReviewApi(ref.watch(dioProvider));
});

class SHOReviewApi {
  SHOReviewApi(this._dio);

  final Dio _dio;

  Future<SHOProductReviewSummary> fetchReviews(String productId) {
    return _dio.getData<SHOProductReviewSummary>(
      '/products/$productId/reviews',
      parser: (data) =>
          SHOProductReviewSummary.fromJson(data as Map<String, dynamic>),
    );
  }
}
