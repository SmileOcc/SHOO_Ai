import 'package:flutter/material.dart';

import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/widgets/hos_network_image.dart';
import 'package:shoo/features/community/domain/entities/hos_community_models.dart';
import 'package:shoo/features/community/presentation/widgets/hos_community_format.dart';

class SHOCommunityFeedCard extends StatelessWidget {
  const SHOCommunityFeedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(SHOAppSpacing.pagePadding),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    return Material(
      color: SHOAppColors.surface,
      child: onTap == null
          ? content
          : InkWell(onTap: onTap, child: content),
    );
  }
}

/// Feed 卡片内可点击区域（与 [SHOAppExpandableText] 分区，避免「更多」触发跳转）。
class SHOCommunityTappableSection extends StatelessWidget {
  const SHOCommunityTappableSection({
    super.key,
    required this.onTap,
    required this.child,
  });

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }
}

class SHOCommunityAuthorRow extends StatelessWidget {
  const SHOCommunityAuthorRow({
    super.key,
    required this.author,
    this.publishedAt = '',
    this.trailing,
  });

  final SHOCommunityAuthor author;
  final String publishedAt;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: SHOAppColors.surfaceMuted,
          backgroundImage: author.avatarUrl.isNotEmpty
              ? NetworkImage(author.avatarUrl)
              : null,
          child: author.avatarUrl.isEmpty
              ? Text(
                  author.name.isNotEmpty ? author.name.characters.first : '?',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : null,
        ),
        const SizedBox(width: SHOAppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      author.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: SHOAppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (author.badge.isNotEmpty) ...[
                    const SizedBox(width: SHOAppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SHOAppSpacing.xs,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: SHOAppColors.accent.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(SHOAppSpacing.tagRadius),
                      ),
                      child: Text(
                        author.badge,
                        style: const TextStyle(
                          fontSize: 9,
                          color: SHOAppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (publishedAt.isNotEmpty)
                Text(
                  shoCommunityFormatRelativeTime(publishedAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: SHOAppColors.textMuted,
                  ),
                ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class SHOCommunityStatsRow extends StatelessWidget {
  const SHOCommunityStatsRow({
    super.key,
    required this.likeCount,
    required this.commentCount,
    this.readCount,
    this.shareCount,
  });

  final int likeCount;
  final int commentCount;
  final int? readCount;
  final int? shareCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (readCount != null) ...[
          _Stat(icon: Icons.visibility_outlined, value: readCount!),
          const SizedBox(width: SHOAppSpacing.lg),
        ],
        _Stat(icon: Icons.favorite_border_rounded, value: likeCount),
        const SizedBox(width: SHOAppSpacing.lg),
        _Stat(icon: Icons.chat_bubble_outline_rounded, value: commentCount),
        if (shareCount != null) ...[
          const SizedBox(width: SHOAppSpacing.lg),
          _Stat(icon: Icons.ios_share_rounded, value: shareCount!),
        ],
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value});

  final IconData icon;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: SHOAppColors.textMuted),
        const SizedBox(width: 2),
        Text(
          shoCommunityFormatCount(value),
          style: const TextStyle(fontSize: 11, color: SHOAppColors.textMuted),
        ),
      ],
    );
  }
}

class SHOCommunityTagRow extends StatelessWidget {
  const SHOCommunityTagRow({super.key, required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: SHOAppSpacing.xs,
      runSpacing: SHOAppSpacing.xs,
      children: tags.take(3).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SHOAppSpacing.sm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: SHOAppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(SHOAppSpacing.tagRadius),
          ),
          child: Text(
            '#$tag',
            style: const TextStyle(
              fontSize: 10,
              color: SHOAppColors.textSecondary,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class SHOCommunityCoverImage extends StatelessWidget {
  const SHOCommunityCoverImage({
    super.key,
    required this.url,
    this.aspectRatio = 16 / 9,
    this.borderRadius,
    this.overlay,
  });

  final String url;
  final double aspectRatio;
  final BorderRadius? borderRadius;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            SHOAppNetworkImage(url: url, fit: BoxFit.cover),
            if (overlay != null) overlay!,
          ],
        ),
      ),
    );
  }
}

class SHOCommunityPinnedBadge extends StatelessWidget {
  const SHOCommunityPinnedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SHOAppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: SHOAppColors.accent,
        borderRadius: BorderRadius.circular(SHOAppSpacing.tagRadius),
      ),
      child: const Text(
        '置顶',
        style: TextStyle(
          fontSize: 10,
          color: SHOAppColors.textOnAccent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class SHOCommunityAdLabel extends StatelessWidget {
  const SHOCommunityAdLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SHOAppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: SHOAppColors.border),
        borderRadius: BorderRadius.circular(SHOAppSpacing.tagRadius),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, color: SHOAppColors.textMuted),
      ),
    );
  }
}
