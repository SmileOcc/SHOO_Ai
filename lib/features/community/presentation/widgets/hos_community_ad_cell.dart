import 'package:flutter/material.dart';

import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/widgets/hos_expandable_text.dart';
import 'package:shoo/core/widgets/hos_network_image.dart';
import 'package:shoo/core/widgets/hos_price_text.dart';
import 'package:shoo/features/community/domain/entities/hos_community_models.dart';
import 'package:shoo/features/community/presentation/widgets/hos_community_cell_shared.dart';

class SHOCommunityAdCell extends StatelessWidget {
  const SHOCommunityAdCell({
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
      child: switch (item.adStyle) {
        SHOCommunityAdStyle.banner => _BannerAd(item: item, onTap: onTap),
        SHOCommunityAdStyle.nativeProduct =>
          _NativeProductAd(item: item, onTap: onTap),
        SHOCommunityAdStyle.brandStory =>
          _BrandStoryAd(item: item, onTap: onTap),
        SHOCommunityAdStyle.carousel =>
          _CarouselAd(item: item, onTap: onTap),
        null => _BannerAd(item: item, onTap: onTap),
      },
    );
  }
}

class _BannerAd extends StatelessWidget {
  const _BannerAd({required this.item, required this.onTap});

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
                  SHOCommunityAdLabel(label: item.adLabel),
                  const Spacer(),
                  if (item.readCount > 0)
                    Text(
                      '${item.readCount} 浏览',
                      style: const TextStyle(
                        fontSize: 10,
                        color: SHOAppColors.textMuted,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: SHOAppSpacing.sm),
              SHOCommunityCoverImage(
                url: item.coverUrl,
                aspectRatio: 750 / 280,
                borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
              ),
              const SizedBox(height: SHOAppSpacing.sm),
              Text(
                item.title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        if (item.summary.isNotEmpty)
          SHOAppExpandableText(
            text: item.summary,
            maxLines: 2,
            fontSize: 11,
            color: SHOAppColors.textSecondary,
          ),
      ],
    );
  }
}

class _NativeProductAd extends StatelessWidget {
  const _NativeProductAd({required this.item, required this.onTap});

  final SHOCommunityFeedItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SHOCommunityAdLabel(label: item.adLabel),
            const Spacer(),
            const Icon(Icons.shopping_bag_outlined, size: 14),
          ],
        ),
        const SizedBox(height: SHOAppSpacing.md),
        SHOCommunityTappableSection(
          onTap: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: SHOCommunityCoverImage(
                  url: product?.imageUrl ?? item.coverUrl,
                  aspectRatio: 1,
                  borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
                ),
              ),
              const SizedBox(width: SHOAppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (product != null) ...[
                      const SizedBox(height: SHOAppSpacing.sm),
                      SHOAppPriceText(
                        priceCents: product.priceCents,
                        originalCents: product.originalPriceCents,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (item.summary.isNotEmpty) ...[
          const SizedBox(height: SHOAppSpacing.xs),
          SHOAppExpandableText(
            text: item.summary,
            maxLines: 2,
            fontSize: 11,
            color: SHOAppColors.textSecondary,
          ),
        ],
      ],
    );
  }
}

class _BrandStoryAd extends StatelessWidget {
  const _BrandStoryAd({required this.item, required this.onTap});

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
                  if (item.brandLogoUrl.isNotEmpty)
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: NetworkImage(item.brandLogoUrl),
                    ),
                  if (item.brandLogoUrl.isNotEmpty)
                    const SizedBox(width: SHOAppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.brandName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (item.brandSlogan.isNotEmpty)
                          Text(
                            item.brandSlogan,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: SHOAppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: SHOAppSpacing.sm),
                  SHOCommunityAdLabel(label: item.adLabel),
                ],
              ),
              const SizedBox(height: SHOAppSpacing.md),
              SHOCommunityCoverImage(
                url: item.coverUrl,
                borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
              ),
              const SizedBox(height: SHOAppSpacing.sm),
              Text(
                item.title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        if (item.summary.isNotEmpty)
          SHOAppExpandableText(
            text: item.summary,
            maxLines: 2,
            fontSize: 11,
            color: SHOAppColors.textSecondary,
          ),
      ],
    );
  }
}

class _CarouselAd extends StatefulWidget {
  const _CarouselAd({required this.item, required this.onTap});

  final SHOCommunityFeedItem item;
  final VoidCallback onTap;

  @override
  State<_CarouselAd> createState() => _CarouselAdState();
}

class _CarouselAdState extends State<_CarouselAd> {
  late final PageController _controller = PageController(viewportFraction: 0.82);
  var _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.item.carouselCards;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SHOCommunityTappableSection(
          onTap: widget.onTap,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: SHOAppSpacing.sm),
              SHOCommunityAdLabel(label: widget.item.adLabel),
            ],
          ),
        ),
        if (widget.item.summary.isNotEmpty) ...[
          const SizedBox(height: SHOAppSpacing.xs),
          SHOAppExpandableText(
            text: widget.item.summary,
            maxLines: 2,
            fontSize: 11,
            color: SHOAppColors.textSecondary,
          ),
        ],
        const SizedBox(height: SHOAppSpacing.md),
        SHOCommunityTappableSection(
          onTap: widget.onTap,
          child: SizedBox(
            height: 220,
            child: NotificationListener<ScrollNotification>(
              onNotification: (_) => true,
              child: PageView.builder(
                controller: _controller,
                itemCount: cards.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: SHOAppSpacing.md),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(SHOAppSpacing.cardRadius),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          SHOAppNetworkImage(url: card.imageUrl, fit: BoxFit.cover),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(SHOAppSpacing.md),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [Colors.black54, Colors.transparent],
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    card.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    card.subtitle,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        if (cards.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: SHOAppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(cards.length, (i) {
                return Container(
                  width: i == _index ? 12 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i == _index
                        ? SHOAppColors.primary
                        : SHOAppColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
