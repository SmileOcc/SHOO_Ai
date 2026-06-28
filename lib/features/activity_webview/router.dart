import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/pages/hos_route_args.dart';
import 'package:shoo/core/platform/webview/hos_url_decision.dart';
import 'package:shoo/core/platform/webview/hos_url_router_service.dart';
import 'package:shoo/features/activity_webview/presentation/pages/hos_activity_detail_page.dart';
import 'package:shoo/features/activity_webview/presentation/pages/hos_activity_level3_detail_page.dart';
import 'package:shoo/features/activity_webview/presentation/pages/hos_activity_page.dart';
import 'package:shoo/features/activity_webview/presentation/pages/hos_activity_redirect_page.dart';
import 'package:shoo/features/activity_webview/presentation/pages/hos_image_preview_page.dart';
import 'package:shoo/features/activity_webview/presentation/pages/hos_webview_page.dart';

List<RouteBase> shoActivityWebviewRoutes({
  required GlobalKey<NavigatorState> rootKey,
}) => [
  GoRoute(
    path: SHOAppRoutes.webview,
    parentNavigatorKey: rootKey,
    builder: (context, state) => SHOWebViewPage.fromRoute(state),
  ),
  GoRoute(
    path: SHOAppRoutes.activity,
    parentNavigatorKey: rootKey,
    builder: (context, state) => const SHOActivityPage(),
    routes: [
      GoRoute(
        path: 'detail',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SHOActivityDetailPage(),
        routes: [
          GoRoute(
            path: 'level3',
            parentNavigatorKey: rootKey,
            builder: (context, state) => const SHOActivityLevel3DetailPage(),
          ),
        ],
      ),
      GoRoute(
        path: 'webview',
        parentNavigatorKey: rootKey,
        redirect: (context, state) {
          final args = state.activityUrlArgs;
          if (args.url == null || args.url!.isEmpty) {
            return SHOAppRoutes.toolboxWeb;
          }
          return SHOAppRoutes.webviewFor(args.url!, title: args.title);
        },
      ),
      GoRoute(
        path: 'image-preview',
        parentNavigatorKey: rootKey,
        builder: (context, state) => SHOImagePreviewPage(
          initialIndex: state.imagePreviewArgs.initialIndex,
        ),
      ),
      GoRoute(
        path: 'payment',
        parentNavigatorKey: rootKey,
        redirect: (context, state) {
          final url = state.activityUrlArgs.url;
          if (url == null || url.isEmpty) return SHOAppRoutes.toolbox;
          final decision = const SHOURLRouterService().resolve(url);
          if (decision.target == SHOURLTarget.inAppWebView) {
            return SHOAppRoutes.activityWebviewFor(url);
          }
          return null;
        },
        builder: (context, state) => SHOActivityRedirectPage(
          url: state.activityUrlArgs.decodedUrl(),
          isPayment: true,
        ),
      ),
      GoRoute(
        path: 'external',
        parentNavigatorKey: rootKey,
        builder: (context, state) => SHOActivityRedirectPage(
          url: state.activityUrlArgs.decodedUrl(),
          isPayment: false,
        ),
      ),
    ],
  ),
];
