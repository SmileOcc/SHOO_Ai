import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/hos_routes.dart';
import 'presentation/hos_download_list_page.dart';
import 'presentation/hos_toolbox_page.dart';
import 'presentation/hos_txt_reader_route_page.dart';
import 'presentation/hos_music_player_route_page.dart';
import 'presentation/hos_video_player_route_page.dart';

List<RouteBase> shoToolboxRoutes({required GlobalKey<NavigatorState> rootKey}) =>
    [
      GoRoute(
        path: SHOAppRoutes.toolbox,
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SHOToolboxPage(),
        routes: [
          GoRoute(
            path: 'downloads',
            parentNavigatorKey: rootKey,
            builder: (context, state) => const SHODownloadListPage(),
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
