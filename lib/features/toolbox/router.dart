import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/pages/hos_route_args.dart';
import 'package:shoo/features/study/presentation/pages/study_article_page.dart';
import 'package:shoo/features/study/presentation/pages/study_home_page.dart';
import 'package:shoo/features/toolbox/presentation/pages/hos_contact_list_page.dart';
import 'package:shoo/features/toolbox/presentation/pages/hos_download_list_page.dart';
import 'package:shoo/features/toolbox/presentation/pages/hos_toolbox_page.dart';
import 'package:shoo/features/toolbox/presentation/pages/hos_toolbox_web_debug_page.dart';
import 'package:shoo/features/toolbox/presentation/pages/hos_toolbox_web_page.dart';
import 'package:shoo/features/theme_activity/presentation/pages/hos_theme_activity_templates_page.dart';
import 'package:shoo/features/toolbox/presentation/pages/hos_txt_reader_route_page.dart';
import 'package:shoo/features/toolbox/presentation/pages/hos_music_player_route_page.dart';
import 'package:shoo/features/toolbox/presentation/pages/hos_video_player_route_page.dart';

List<RouteBase> shoToolboxRoutes({
  required GlobalKey<NavigatorState> rootKey,
}) => [
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
            builder: (context, state) => SHOStudyArticlePage(
              articleId: state.studyArticleArgs.articleId,
            ),
          ),
        ],
      ),
      GoRoute(
        path: 'contacts',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SHOContactListPage(),
      ),
      GoRoute(
        path: 'downloads',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SHODownloadListPage(),
      ),
      GoRoute(
        path: 'web-debug',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SHOToolboxWebDebugPage(),
      ),
      GoRoute(
        path: 'theme-activity',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SHOThemeActivityTemplatesPage(),
      ),
      GoRoute(
        path: 'web',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SHOToolboxWebPage(),
      ),
      GoRoute(
        path: 'reader',
        parentNavigatorKey: rootKey,
        builder: (context, state) =>
            SHOTxtReaderRoutePage(taskId: state.toolboxReaderArgs.taskId),
      ),
      GoRoute(
        path: 'video',
        parentNavigatorKey: rootKey,
        builder: (context, state) {
          final args = state.toolboxVideoArgs;
          return SHOVideoPlayerRoutePage(
            entryId: args.entryId,
            taskId: args.taskId,
          );
        },
      ),
      GoRoute(
        path: 'music',
        parentNavigatorKey: rootKey,
        builder: (context, state) {
          final args = state.musicPlayerArgs;
          return SHOMusicPlayerRoutePage(
            trackId: args.trackId,
            startIndex: args.startIndex,
            fromDownloadPack: args.fromDownloadPack,
          );
        },
      ),
    ],
  ),
];
