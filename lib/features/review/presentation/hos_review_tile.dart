import 'package:flutter/material.dart';

import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_extension.dart';
import '../../../core/widgets/hos_network_image.dart';
import '../domain/hos_review.dart';

class SHOReviewTile extends StatelessWidget {
  const SHOReviewTile({
    super.key,
    required this.review,
  });

  final SHOProductReview review;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SHOAppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: context.shoTheme.surfaceMuted,
                backgroundImage: review.userAvatarUrl.isNotEmpty
                    ? NetworkImage(review.userAvatarUrl)
                    : null,
                child: review.userAvatarUrl.isEmpty
                    ? Text(
                        review.userName.isNotEmpty
                            ? review.userName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(fontSize: 12),
                      )
                    : null,
              ),
              const SizedBox(width: SHOAppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                    ),
                    Text(
                      review.createdAt,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, size: 14, color: SHOAppColors.warning),
                  const SizedBox(width: 2),
                  Text(
                    review.rating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          if (review.variantLabel.isNotEmpty) ...[
            const SizedBox(height: SHOAppSpacing.xs),
            Text(
              review.variantLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.shoTheme.textMuted,
                  ),
            ),
          ],
          const SizedBox(height: SHOAppSpacing.sm),
          Text(
            review.content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  height: 1.4,
                ),
          ),
          if (review.imageUrls.isNotEmpty) ...[
            const SizedBox(height: SHOAppSpacing.md),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.imageUrls.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: SHOAppSpacing.sm),
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius:
                      BorderRadius.circular(SHOAppSpacing.cardRadius),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: SHOAppNetworkImage(
                      url: review.imageUrls[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
