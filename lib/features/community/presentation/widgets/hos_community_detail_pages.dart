import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/analytics/hos_page_analytics.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/feedback/hos_toast.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/widgets/hos_expandable_text.dart';
import 'package:shoo/features/community/domain/entities/hos_community_models.dart';
import 'package:shoo/features/community/presentation/widgets/hos_community_cell_shared.dart';
import 'package:shoo/features/community/presentation/widgets/hos_community_format.dart';

class SHOCommunityNewsDetailPage extends ConsumerStatefulWidget {
  const SHOCommunityNewsDetailPage({super.key, required this.item});

  final SHOCommunityFeedItem item;

  @override
  ConsumerState<SHOCommunityNewsDetailPage> createState() =>
      _SHOCommunityNewsDetailPageState();
}

class _SHOCommunityNewsDetailPageState
    extends ConsumerState<SHOCommunityNewsDetailPage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  @override
  String get pageName => 'community_news_detail';

  @override
  Map<String, Object?> get pageAnalyticsExtra => {
        'feed_id': widget.item.id,
        'article_slug': widget.item.articleSlug,
      };

  SHOCommunityFeedItem get item => widget.item;

  @override
  Widget build(BuildContext context) {
    return buildTrackedPage(
      Scaffold(
      appBar: AppBar(
        title: Text(
          item.source.isNotEmpty ? item.source : '资讯',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: () => SHOAppToast.info('分享即将上线'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.isPinned) const SHOCommunityPinnedBadge(),
            if (item.isPinned) const SizedBox(height: SHOAppSpacing.sm),
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
            const SizedBox(height: SHOAppSpacing.md),
            Row(
              children: [
                if (item.category.isNotEmpty)
                  Text(
                    item.category,
                    style: const TextStyle(
                      fontSize: 12,
                      color: SHOAppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (item.category.isNotEmpty)
                  const SizedBox(width: SHOAppSpacing.md),
                Text(
                  shoCommunityFormatRelativeTime(item.publishedAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: SHOAppColors.textMuted,
                  ),
                ),
              ],
            ),
            if (item.coverUrl.isNotEmpty) ...[
              const SizedBox(height: SHOAppSpacing.lg),
              SHOCommunityCoverImage(
                url: item.coverUrl,
                borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
              ),
            ],
            const SizedBox(height: SHOAppSpacing.lg),
            SHOAppExpandableText(
              text: item.summary.isNotEmpty
                  ? item.summary
                  : '正文内容加载中，完整文章即将上线。',
              fontSize: 15,
              height: 1.7,
              color: SHOAppColors.textPrimary,
              maxLines: 6,
            ),
            const SizedBox(height: SHOAppSpacing.lg),
            SHOCommunityTagRow(tags: item.tags),
            const SizedBox(height: SHOAppSpacing.xl),
            SHOCommunityStatsRow(
              readCount: item.readCount,
              likeCount: item.likeCount,
              commentCount: item.commentCount,
              shareCount: item.shareCount,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => SHOAppToast.info('评论即将上线'),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: Text(shoCommunityFormatCount(item.commentCount)),
                ),
              ),
              const SizedBox(width: SHOAppSpacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => SHOAppToast.success('已点赞'),
                  icon: const Icon(Icons.favorite_border_rounded, size: 18),
                  label: Text(shoCommunityFormatCount(item.likeCount)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class SHOCommunityPostDetailPage extends ConsumerStatefulWidget {
  const SHOCommunityPostDetailPage({super.key, required this.item});

  final SHOCommunityFeedItem item;

  @override
  ConsumerState<SHOCommunityPostDetailPage> createState() =>
      _SHOCommunityPostDetailPageState();
}

class _SHOCommunityPostDetailPageState
    extends ConsumerState<SHOCommunityPostDetailPage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  @override
  String get pageName => 'community_post_detail';

  @override
  Map<String, Object?> get pageAnalyticsExtra => {
        'feed_id': widget.item.id,
        'post_style': widget.item.style,
      };

  SHOCommunityFeedItem get item => widget.item;

  @override
  Widget build(BuildContext context) {
    final images = item.imageUrls.isNotEmpty
        ? item.imageUrls
        : (item.coverUrl.isNotEmpty ? [item.coverUrl] : <String>[]);

    return buildTrackedPage(
      Scaffold(
      appBar: AppBar(
        title: Text(
          item.author.name.isNotEmpty ? item.author.name : '帖子',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded),
            onPressed: () => SHOAppToast.info('更多操作即将上线'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SHOCommunityAuthorRow(
              author: item.author,
              publishedAt: item.publishedAt,
            ),
            const SizedBox(height: SHOAppSpacing.lg),
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
            if (item.summary.isNotEmpty) ...[
              const SizedBox(height: SHOAppSpacing.md),
              SHOAppExpandableText(
                text: item.summary,
                fontSize: 15,
                height: 1.7,
                color: SHOAppColors.textPrimary,
                maxLines: 5,
              ),
            ],
            if (images.isNotEmpty) ...[
              const SizedBox(height: SHOAppSpacing.lg),
              for (final url in images) ...[
                SHOCommunityCoverImage(
                  url: url,
                  aspectRatio: 1,
                  borderRadius:
                      BorderRadius.circular(SHOAppSpacing.cardRadius),
                ),
                const SizedBox(height: SHOAppSpacing.sm),
              ],
            ],
            if (item.pollOptions.isNotEmpty) ...[
              const SizedBox(height: SHOAppSpacing.md),
              for (final option in item.pollOptions)
                Padding(
                  padding: const EdgeInsets.only(bottom: SHOAppSpacing.sm),
                  child: _PollOptionRow(option: option),
                ),
            ],
            if (item.product != null &&
                item.product!.productId.isNotEmpty) ...[
              const SizedBox(height: SHOAppSpacing.lg),
              _LinkedProductCard(product: item.product!),
            ],
            const SizedBox(height: SHOAppSpacing.lg),
            SHOCommunityTagRow(tags: item.tags),
            const SizedBox(height: SHOAppSpacing.xl),
            SHOCommunityStatsRow(
              likeCount: item.likeCount,
              commentCount: item.commentCount,
              shareCount: item.shareCount,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '说点什么...',
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(SHOAppSpacing.buttonRadius),
                    ),
                  ),
                  onTap: () => SHOAppToast.info('评论即将上线'),
                  readOnly: true,
                ),
              ),
              const SizedBox(width: SHOAppSpacing.md),
              IconButton(
                onPressed: () => SHOAppToast.success('已点赞'),
                icon: const Icon(Icons.favorite_border_rounded),
              ),
              IconButton(
                onPressed: () => SHOAppToast.info('分享即将上线'),
                icon: const Icon(Icons.ios_share_rounded),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class _PollOptionRow extends StatelessWidget {
  const _PollOptionRow({required this.option});

  final SHOCommunityPollOption option;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SHOAppSpacing.md,
        vertical: SHOAppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: SHOAppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
      ),
      child: Row(
        children: [
          Expanded(child: Text(option.label)),
          Text(
            '${option.percent}%',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: SHOAppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkedProductCard extends StatelessWidget {
  const _LinkedProductCard({required this.product});

  final SHOCommunityLinkedProduct product;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SHOAppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
      child: InkWell(
        onTap: () => context.push(SHOAppRoutes.product(product.productId)),
        borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(SHOAppSpacing.md),
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
                child: Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
