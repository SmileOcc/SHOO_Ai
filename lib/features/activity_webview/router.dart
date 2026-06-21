import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
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
}) =>
    [
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
              final url = state.uri.queryParameters['url'];
              if (url == null || url.isEmpty) return SHOAppRoutes.toolboxWeb;
              final title = state.uri.queryParameters['title'];
              return SHOAppRoutes.webviewFor(url, title: title);
            },
          ),
          GoRoute(
            path: 'image-preview',
            parentNavigatorKey: rootKey,
            builder: (context, state) {
              final index =
                  int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;
              return SHOImagePreviewPage(initialIndex: index);
            },
          ),
          GoRoute(
            path: 'payment',
            parentNavigatorKey: rootKey,
            redirect: (context, state) {
              final url = state.uri.queryParameters['url'];
              if (url == null || url.isEmpty) return SHOAppRoutes.toolbox;
              final decision = const SHOURLRouterService().resolve(url);
              if (decision.target == SHOURLTarget.inAppWebView) {
                return SHOAppRoutes.activityWebviewFor(url);
              }
              return null;
            },
            builder: (context, state) {
              final url = state.uri.queryParameters['url'] ?? '';
              return SHOActivityRedirectPage(url: url, isPayment: true);
            },
          ),
          GoRoute(
            path: 'external',
            parentNavigatorKey: rootKey,
            builder: (context, state) {
              final encoded = state.uri.queryParameters['url'] ?? '';
              final url = Uri.decodeComponent(encoded);
              return SHOActivityRedirectPage(url: url, isPayment: false);
            },
          ),
        ],
      ),
    ];
