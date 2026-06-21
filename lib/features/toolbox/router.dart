import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/features/study/presentation/pages/study_article_page.dart';
import 'package:shoo/features/study/presentation/pages/study_home_page.dart';
import 'package:shoo/features/toolbox/presentation/pages/hos_download_list_page.dart';
import 'package:shoo/features/toolbox/presentation/pages/hos_toolbox_page.dart';
import 'package:shoo/features/toolbox/presentation/pages/hos_toolbox_web_page.dart';
import 'package:shoo/features/toolbox/presentation/pages/hos_txt_reader_route_page.dart';
import 'package:shoo/features/toolbox/presentation/pages/hos_music_player_route_page.dart';
import 'package:shoo/features/toolbox/presentation/pages/hos_video_player_route_page.dart';

List<RouteBase> shoToolboxRoutes({required GlobalKey<NavigatorState> rootKey}) =>
    [
      GoRoute(
        path: SHOAppRoutes.toolbox,
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SHOToolboxPage(),
        routes: [
          GoRoute(
            path: 'study',
            parentNavigatorKey: rootKey,
            builder: (context, state) => const SHOStudyHomePage(),
            routes: [
              GoRoute(
                path: 'article',
                parentNavigatorKey: rootKey,
                builder: (context, state) {
                  final slug = state.uri.queryParameters['slug'] ?? '';
                  return SHOStudyArticlePage(articleId: slug);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'downloads',
            parentNavigatorKey: rootKey,
            builder: (context, state) => const SHODownloadListPage(),
          ),
          GoRoute(
            path: 'web',
            parentNavigatorKey: rootKey,
            builder: (context, state) => const SHOToolboxWebPage(),
          ),
          GoRoute(
            path: 'reader',
            parentNavigatorKey: rootKey,
            builder: (context, state) {
              final taskId = state.uri.queryParameters['taskId'] ?? '';
              return SHOTxtReaderRoutePage(taskId: taskId);
            },
          ),
          GoRoute(
            path: 'video',
            parentNavigatorKey: rootKey,
            builder: (context, state) {
              final entryId = state.uri.queryParameters['entryId'] ?? '';
              final taskId = state.uri.queryParameters['taskId'] ?? '';
              return SHOVideoPlayerRoutePage(
                entryId: entryId,
                taskId: taskId,
              );
            },
          ),
          GoRoute(
            path: 'music',
            parentNavigatorKey: rootKey,
            builder: (context, state) {
              final trackId = state.uri.queryParameters['trackId'] ?? '';
              final index =
                  int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0;
              final fromDownloadPack =
                  state.uri.queryParameters['fromDownloadPack'] == '1';
              return SHOMusicPlayerRoutePage(
                trackId: trackId,
                startIndex: index,
                fromDownloadPack: fromDownloadPack,
              );
            },
          ),
        ],
      ),
    ];
