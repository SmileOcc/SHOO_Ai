import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/pages/hos_route_args.dart';
import 'package:shoo/features/toolbox/presentation/pages/hos_bookshelf_list_page.dart';
import 'package:shoo/features/toolbox/presentation/pages/hos_music_library_page.dart';
import 'package:shoo/features/toolbox/presentation/pages/hos_video_library_page.dart';
import 'package:shoo/features/profile/presentation/pages/hos_profile_activity_list_page.dart';
import 'package:shoo/features/profile/presentation/state/hos_profile_controller.dart';

List<RouteBase> shoProfileRoutes({required GlobalKey<NavigatorState> rootKey}) =>
    [
      GoRoute(
        path: SHOAppRoutes.profileFootprints,
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SHOProfileActivityListPage(
          kind: SHOProfileActivityListKind.footprints,
        ),
      ),
      GoRoute(
        path: SHOAppRoutes.profileFavorites,
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SHOProfileActivityListPage(
          kind: SHOProfileActivityListKind.favorites,
        ),
      ),
      GoRoute(
        path: SHOAppRoutes.profileBookshelf,
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SHOBookshelfListPage(),
      ),
      GoRoute(
        path: SHOAppRoutes.profileVideoLibrary,
        parentNavigatorKey: rootKey,
        builder: (context, state) => const SHOVideoLibraryPage(),
      ),
      GoRoute(
        path: SHOAppRoutes.profileMusicLibrary,
        parentNavigatorKey: rootKey,
        builder: (context, state) {
          return SHOMusicLibraryPage(
            fromDownload: state.musicLibraryArgs.fromDownload,
          );
        },
      ),
    ];
