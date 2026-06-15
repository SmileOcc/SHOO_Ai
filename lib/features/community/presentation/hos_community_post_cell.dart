import 'package:flutter/material.dart';

import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/widgets/hos_expandable_text.dart';
import '../../../core/widgets/hos_price_text.dart';
import '../domain/hos_community_models.dart';
import 'hos_community_cell_shared.dart';

class SHOCommunityPostCell extends StatelessWidget {
  const SHOCommunityPostCell({
    super.key,
    required this.item,
    required this.onTap,
  });

  final SHOCommunityFeedItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SHOCommunityFeedCard(
      onTap: null,
      child: switch (item.postStyle) {
        SHOCommunityPostStyle.standard =>
          _StandardPost(item: item, onTap: onTap),
        SHOCommunityPostStyle.multiImage =>
          _MultiImagePost(item: item, onTap: onTap),
        SHOCommunityPostStyle.poll => _PollPost(item: item, onTap: onTap),
        SHOCommunityPostStyle.productShare =>
          _ProductSharePost(item: item, onTap: onTap),
        null => _StandardPost(item: item, onTap: onTap),
      },
    );
  }
}

class _StandardPost extends StatelessWidget {
  const _StandardPost({required this.item, required this.onTap});

  final SHOCommunityFeedItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SHOCommunityTappableSection(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SHOCommunityAuthorRow(
                author: item.author,
                publishedAt: item.publishedAt,
              ),
              const SizedBox(height: SHOAppSpacing.md),
              Text(
                item.title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              if (item.coverUrl.isNotEmpty) ...[
                const SizedBox(height: SHOAppSpacing.md),
                SHOCommunityCoverImage(url: item.coverUrl, aspectRatio: 1),
              ],
            ],
          ),
        ),
        if (item.summary.isNotEmpty) ...[
          const SizedBox(height: SHOAppSpacing.sm),
          SHOAppExpandableText(
            text: item.summary,
            maxLines: 3,
            fontSize: 13,
            height: 1.4,
            color: SHOAppColors.textSecondary,
          ),
        ],
        SHOCommunityTappableSection(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: SHOAppSpacing.md),
              SHOCommunityTagRow(tags: item.tags),
              const SizedBox(height: SHOAppSpacing.sm),
              SHOCommunityStatsRow(
                likeCount: item.likeCount,
                commentCount: item.commentCount,
                shareCount: item.shareCount,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MultiImagePost extends StatelessWidget {
  const _MultiImagePost({required this.item, required this.onTap});

  final SHOCommunityFeedItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final images = item.imageUrls.isNotEmpty
        ? item.imageUrls
        : (item.coverUrl.isNotEmpty ? [item.coverUrl] : <String>[]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SHOCommunityTappableSection(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SHOCommunityAuthorRow(
                author: item.author,
                publishedAt: item.publishedAt,
              ),
              const SizedBox(height: SHOAppSpacing.md),
              Text(
                item.title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        if (item.summary.isNotEmpty) ...[
          const SizedBox(height: SHOAppSpacing.sm),
          SHOAppExpandableText(
            text: item.summary,
            maxLines: 2,
            fontSize: 13,
            color: SHOAppColors.textSecondary,
          ),
        ],
        if (images.isNotEmpty) ...[
          const SizedBox(height: SHOAppSpacing.md),
          SHOCommunityTappableSection(
            onTap: onTap,
            child: _ImageGrid(urls: images),
          ),
        ],
        SHOCommunityTappableSection(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(top: SHOAppSpacing.md),
            child: SHOCommunityStatsRow(
              likeCount: item.likeCount,
              commentCount: item.commentCount,
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageGrid extends StatelessWidget {
  const _ImageGrid({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    final display = urls.take(6).toList();
    final crossCount = display.length == 1 ? 1 : (display.length <= 4 ? 2 : 3);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: display.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossCount,
        mainAxisSpacing: SHOAppSpacing.xs,
        crossAxisSpacing: SHOAppSpacing.xs,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final isMore = index == 5 && urls.length > 6;
        return Stack(
          fit: StackFit.expand,
          children: [
            SHOCommunityCoverImage(url: display[index]),
            if (isMore)
              Container(
                color: Colors.black45,
                alignment: Alignment.center,
                child: Text(
                  '+${urls.length - 5}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PollPost extends StatelessWidget {
  const _PollPost({required this.item, required this.onTap});

  final SHOCommunityFeedItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SHOCommunityTappableSection(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SHOCommunityAuthorRow(
                author: item.author,
                publishedAt: item.publishedAt,
              ),
              const SizedBox(height: SHOAppSpacing.md),
              Text(
                item.title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        if (item.summary.isNotEmpty) ...[
          const SizedBox(height: SHOAppSpacing.sm),
          SHOAppExpandableText(
            text: item.summary,
            maxLines: 2,
            fontSize: 13,
            color: SHOAppColors.textSecondary,
          ),
        ],
        SHOCommunityTappableSection(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: SHOAppSpacing.md),
              for (final option in item.pollOptions) ...[
                _PollBar(option: option),
                const SizedBox(height: SHOAppSpacing.sm),
              ],
              Text(
                '${item.pollParticipants} 人参与 · ${item.pollEndsIn}',
                style: const TextStyle(fontSize: 11, color: SHOAppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PollBar extends StatelessWidget {
  const _PollBar({required this.option});

  final SHOCommunityPollOption option;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 32,
          decoration: BoxDecoration(
            color: SHOAppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
          ),
        ),
        FractionallySizedBox(
          widthFactor: (option.percent.clamp(0, 100)) / 100,
          child: Container(
            height: 32,
            decoration: BoxDecoration(
              color: SHOAppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
            ),
          ),
        ),
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.md),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option.label,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Text(
                '${option.percent}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: SHOAppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductSharePost extends StatelessWidget {
  const _ProductSharePost({required this.item, required this.onTap});

  final SHOCommunityFeedItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SHOCommunityTappableSection(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SHOCommunityAuthorRow(
                author: item.author,
                publishedAt: item.publishedAt,
              ),
              const SizedBox(height: SHOAppSpacing.md),
              Text(
                item.title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        if (item.summary.isNotEmpty) ...[
          const SizedBox(height: SHOAppSpacing.sm),
          SHOAppExpandableText(
            text: item.summary,
            maxLines: 3,
            fontSize: 13,
            color: SHOAppColors.textSecondary,
          ),
        ],
        if (product != null && product.productId.isNotEmpty) ...[
          const SizedBox(height: SHOAppSpacing.md),
          SHOCommunityTappableSection(
            onTap: onTap,
            child: Container(
            padding: const EdgeInsets.all(SHOAppSpacing.md),
            decoration: BoxDecoration(
              color: SHOAppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: SHOCommunityCoverImage(
                    url: product.imageUrl,
                    aspectRatio: 1,
                  ),
                ),
                const SizedBox(width: SHOAppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: SHOAppSpacing.xs),
                      SHOAppPriceText(
                        priceCents: product.priceCents,
                        originalCents: product.originalPriceCents,
                        size: SHOAppPriceSize.small,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
        ],
      ],
    );
  }
}
