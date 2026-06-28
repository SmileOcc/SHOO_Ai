import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/feedback/hos_toast.dart';
import 'package:shoo/features/community/domain/entities/hos_community_models.dart';
import 'package:shoo/features/community/presentation/widgets/hos_community_ad_cell.dart';
import 'package:shoo/features/community/presentation/widgets/hos_community_news_cell.dart';
import 'package:shoo/features/community/presentation/widgets/hos_community_post_cell.dart';

class SHOCommunityFeedCell extends StatelessWidget {
  const SHOCommunityFeedCell({super.key, required this.item});

  final SHOCommunityFeedItem item;

  @override
  Widget build(BuildContext context) {
    return switch (item.kind) {
      SHOCommunityFeedKind.news => SHOCommunityNewsCell(
        item: item,
        onTap: () => _openNews(context),
      ),
      SHOCommunityFeedKind.post => SHOCommunityPostCell(
        item: item,
        onTap: () => _openPost(context),
      ),
      SHOCommunityFeedKind.ad => SHOCommunityAdCell(
        item: item,
        onTap: () => _openAd(context),
      ),
    };
  }

  void _openNews(BuildContext context) {
    context.push(SHOAppRoutes.communityNewsDetail, extra: item);
  }

  void _openPost(BuildContext context) {
    context.push(SHOAppRoutes.communityPostDetail, extra: item);
  }

  void _openAd(BuildContext context) {
    final productId = item.product?.productId;
    if (productId != null && productId.isNotEmpty) {
      context.push(SHOAppRoutes.product(productId));
      return;
    }
    if (item.link.startsWith('/products/')) {
      final id = item.link.replaceFirst('/products/', '');
      if (id.isNotEmpty) {
        context.push(SHOAppRoutes.product(id));
        return;
      }
    }
    SHOAppToast.info('活动详情即将上线');
  }
}
