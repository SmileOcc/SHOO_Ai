import 'package:freezed_annotation/freezed_annotation.dart';

part 'hos_review.freezed.dart';
part 'hos_review.g.dart';

@freezed
class SHOProductReview with _$SHOProductReview {
  const factory SHOProductReview({
    required String id,
    required String userName,
    @Default('') String userAvatarUrl,
    required double rating,
    required String content,
    required String createdAt,
    @Default(<String>[]) List<String> imageUrls,
    @Default('') String variantLabel,
  }) = _SHOProductReview;

  factory SHOProductReview.fromJson(Map<String, dynamic> json) =>
      _$SHOProductReviewFromJson(json);
}

@freezed
class SHOProductReviewSummary with _$SHOProductReviewSummary {
  const factory SHOProductReviewSummary({
    required double averageRating,
    @Default(0) int totalCount,
    @Default(<SHOProductReview>[]) List<SHOProductReview> items,
    @Default(false) bool hasMore,
    @Default(1) int page,
    @Default(10) int pageSize,
  }) = _SHOProductReviewSummary;

  factory SHOProductReviewSummary.fromJson(Map<String, dynamic> json) =>
      _$SHOProductReviewSummaryFromJson(json);
}
