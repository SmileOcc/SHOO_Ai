import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/hos_routes.dart';
import 'domain/hos_community_models.dart';
import 'presentation/hos_community_detail_pages.dart';

List<RouteBase> shoCommunityRoutes({
  required GlobalKey<NavigatorState> rootKey,
}) =>
    [
      GoRoute(
        path: SHOAppRoutes.communityNewsDetail,
        parentNavigatorKey: rootKey,
        builder: (context, state) {
          final item = state.extra;
          if (item is SHOCommunityFeedItem) {
            return SHOCommunityNewsDetailPage(item: item);
          }
          return const Scaffold(
            body: Center(child: Text('Content not found')),
          );
        },
      ),
      GoRoute(
        path: SHOAppRoutes.communityPostDetail,
        parentNavigatorKey: rootKey,
        builder: (context, state) {
          final item = state.extra;
          if (item is SHOCommunityFeedItem) {
            return SHOCommunityPostDetailPage(item: item);
          }
          return const Scaffold(
            body: Center(child: Text('Content not found')),
          );
        },
      ),
    ];
