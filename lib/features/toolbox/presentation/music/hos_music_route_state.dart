import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/hos_routes.dart';

final musicOnPlayerPageProvider = StateProvider<bool>((ref) => false);

final musicOpenPlayerGuardProvider = StateProvider<bool>((ref) => false);

bool isMusicPlayerRoutePath(String path) {
  return path == SHOAppRoutes.toolboxMusicPlayer ||
      path.startsWith('${SHOAppRoutes.toolboxMusicPlayer}?') ||
      path.startsWith('${SHOAppRoutes.toolboxMusicPlayer}/');
}

bool isRouterOnMusicPlayerPage(GoRouter router) {
  final location = router.state.matchedLocation;
  final path = router.state.uri.path;
  return isMusicPlayerRoutePath(location) || isMusicPlayerRoutePath(path);
}

void syncMusicPlayerRouteState(Ref ref, GoRouter router) {
  _applyMusicPlayerRouteState(
    setOnPlayerPage: (value) =>
        ref.read(musicOnPlayerPageProvider.notifier).state = value,
    router: router,
  );
}

void syncMusicPlayerRouteStateForWidget(WidgetRef ref, GoRouter router) {
  _applyMusicPlayerRouteState(
    setOnPlayerPage: (value) =>
        ref.read(musicOnPlayerPageProvider.notifier).state = value,
    router: router,
  );
}

void _applyMusicPlayerRouteState({
  required void Function(bool value) setOnPlayerPage,
  required GoRouter router,
}) {
  try {
    if (router.routerDelegate.currentConfiguration.isEmpty) {
      setOnPlayerPage(false);
      return;
    }
    setOnPlayerPage(isRouterOnMusicPlayerPage(router));
  } catch (_) {
    setOnPlayerPage(false);
  }
}
