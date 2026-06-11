import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/hos_routes.dart';

final musicOnPlayerPageProvider = StateProvider<bool>((ref) => false);

final musicOpenPlayerGuardProvider = StateProvider<bool>((ref) => false);

bool isMusicPlayerRoutePath(String path) {
  return path == SHOAppRoutes.toolboxMusicPlayer ||
      path.startsWith('${SHOAppRoutes.toolboxMusicPlayer}?');
}

void syncMusicPlayerRouteState(Ref ref, GoRouter router) {
  try {
    if (router.routerDelegate.currentConfiguration.isEmpty) {
      ref.read(musicOnPlayerPageProvider.notifier).state = false;
      return;
    }
    final path = router.state.uri.path;
    ref.read(musicOnPlayerPageProvider.notifier).state =
        isMusicPlayerRoutePath(path);
  } catch (_) {
    ref.read(musicOnPlayerPageProvider.notifier).state = false;
  }
}
