import 'package:flutter/material.dart';

import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/widgets/hos_expandable_text.dart';
import 'package:shoo/features/community/domain/entities/hos_community_models.dart';
import 'package:shoo/features/community/presentation/widgets/hos_community_cell_shared.dart';

class SHOCommunityNewsCell extends StatelessWidget {
  const SHOCommunityNewsCell({
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
      child: switch (item.newsStyle) {
        SHOCommunityNewsStyle.headline =>
          _HeadlineNews(item: item, onTap: onTap),
        SHOCommunityNewsStyle.imageText =>
          _ImageTextNews(item: item, onTap: onTap),
        SHOCommunityNewsStyle.tripleImage =>
          _TripleImageNews(item: item, onTap: onTap),
        SHOCommunityNewsStyle.video => _VideoNews(item: item, onTap: onTap),
        SHOCommunityNewsStyle.topicCard =>
          _TopicCardNews(item: item, onTap: onTap),
        null => _ImageTextNews(item: item, onTap: onTap),
      },
    );
  }
}

class _HeadlineNews extends StatelessWidget {
  const _HeadlineNews({required this.item, required this.onTap});

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
              Row(
                children: [
                  if (item.isPinned) const SHOCommunityPinnedBadge(),
                  if (item.isPinned) const SizedBox(width: SHOAppSpacing.sm),
                  if (item.source.isNotEmpty)
                    Text(
                      item.source,
                      style: const TextStyle(
                        fontSize: 11,
                        color: SHOAppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: SHOAppSpacing.sm),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  color: SHOAppColors.textPrimary,
                ),
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
            height: 1.4,
            color: SHOAppColors.textSecondary,
          ),
        ],
        SHOCommunityTappableSection(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(top: SHOAppSpacing.md),
            child: SHOCommunityStatsRow(
              readCount: item.readCount,
              likeCount: item.likeCount,
              commentCount: item.commentCount,
              shareCount: item.shareCount,
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageTextNews extends StatelessWidget {
  const _ImageTextNews({required this.item, required this.onTap});

  final SHOCommunityFeedItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SHOCommunityTappableSection(
      onTap: onTap,
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.isPinned) const SHOCommunityPinnedBadge(),
              if (item.isPinned) const SizedBox(height: SHOAppSpacing.xs),
              Text(
                item.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: SHOAppSpacing.sm),
              Text(
                '${item.source.isNotEmpty ? '${item.source} · ' : ''}${item.category}',
                style: const TextStyle(
                  fontSize: 11,
                  color: SHOAppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        if (item.coverUrl.isNotEmpty) ...[
          const SizedBox(width: SHOAppSpacing.md),
          SizedBox(
            width: 108,
            height: 72,
            child: SHOCommunityCoverImage(
              url: item.coverUrl,
              aspectRatio: 3 / 2,
              borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
            ),
          ),
        ],
      ],
      ),
    );
  }
}

class _TripleImageNews extends StatelessWidget {
  const _TripleImageNews({required this.item, required this.onTap});

  final SHOCommunityFeedItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final images = item.imageUrls.isNotEmpty
        ? item.imageUrls.take(3).toList()
        : (item.coverUrl.isNotEmpty ? [item.coverUrl] : <String>[]);

    return SHOCommunityTappableSection(
      onTap: onTap,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        if (images.isNotEmpty) ...[
          const SizedBox(height: SHOAppSpacing.md),
          Row(
            children: [
              for (var i = 0; i < images.length; i++) ...[
                if (i > 0) const SizedBox(width: SHOAppSpacing.xs),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: SHOCommunityCoverImage(url: images[i]),
                  ),
                ),
              ],
            ],
          ),
        ],
        const SizedBox(height: SHOAppSpacing.sm),
        Text(
          item.source,
          style: const TextStyle(fontSize: 11, color: SHOAppColors.textMuted),
        ),
      ],
      ),
    );
  }
}

class _VideoNews extends StatelessWidget {
  const _VideoNews({required this.item, required this.onTap});

  final SHOCommunityFeedItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SHOCommunityTappableSection(
      onTap: onTap,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: SHOAppSpacing.md),
        SHOCommunityCoverImage(
          url: item.coverUrl,
          overlay: Container(
            color: Colors.black26,
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.all(SHOAppSpacing.md),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
        if (item.videoDuration.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: SHOAppSpacing.xs),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                item.videoDuration,
                style: const TextStyle(
                  fontSize: 11,
                  color: SHOAppColors.textMuted,
                ),
              ),
            ),
          ),
      ],
      ),
    );
  }
}

class _TopicCardNews extends StatelessWidget {
  const _TopicCardNews({required this.item, required this.onTap});

  final SHOCommunityFeedItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF5F5), Color(0xFFFFFBF0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(SHOAppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SHOCommunityTappableSection(
            onTap: onTap,
            child: Text(
              item.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ),
          if (item.summary.isNotEmpty) ...[
            const SizedBox(height: SHOAppSpacing.sm),
            SHOAppExpandableText(
              text: item.summary,
              maxLines: 2,
              fontSize: 12,
              color: SHOAppColors.textSecondary,
            ),
          ],
          SHOCommunityTappableSection(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.only(top: SHOAppSpacing.md),
              child: Row(
                children: [
                  for (final url in item.topicAvatars.take(3)) ...[
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage(url),
                    ),
                    const SizedBox(width: SHOAppSpacing.xxs),
                  ],
                  const SizedBox(width: SHOAppSpacing.sm),
                  Text(
                    '${item.topicDiscussCount} 讨论 · ${item.topicPostCount} 帖子',
                    style: const TextStyle(
                      fontSize: 11,
                      color: SHOAppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
