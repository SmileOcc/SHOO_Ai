// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hos_review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SHOProductReviewImpl _$$SHOProductReviewImplFromJson(
  Map<String, dynamic> json,
) => _$SHOProductReviewImpl(
  id: json['id'] as String,
  userName: json['userName'] as String,
  userAvatarUrl: json['userAvatarUrl'] as String? ?? '',
  rating: (json['rating'] as num).toDouble(),
  content: json['content'] as String,
  createdAt: json['createdAt'] as String,
  imageUrls:
      (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  variantLabel: json['variantLabel'] as String? ?? '',
);

Map<String, dynamic> _$$SHOProductReviewImplToJson(
  _$SHOProductReviewImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userName': instance.userName,
  'userAvatarUrl': instance.userAvatarUrl,
  'rating': instance.rating,
  'content': instance.content,
  'createdAt': instance.createdAt,
  'imageUrls': instance.imageUrls,
  'variantLabel': instance.variantLabel,
};

_$SHOProductReviewSummaryImpl _$$SHOProductReviewSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$SHOProductReviewSummaryImpl(
  averageRating: (json['averageRating'] as num).toDouble(),
  totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => SHOProductReview.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SHOProductReview>[],
);

Map<String, dynamic> _$$SHOProductReviewSummaryImplToJson(
  _$SHOProductReviewSummaryImpl instance,
) => <String, dynamic>{
  'averageRating': instance.averageRating,
  'totalCount': instance.totalCount,
  'items': instance.items,
};
