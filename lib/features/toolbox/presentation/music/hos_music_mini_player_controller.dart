import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/router/hos_router.dart';
import '../../../../app/router/hos_routes.dart';
import '../../../../core/storage/hos_local_storage.dart';
import '../../data/hos_music_storage_keys.dart';
import 'hos_music_route_state.dart';

export 'hos_music_route_state.dart';

Future<bool> openMusicPlayerPage(
  WidgetRef ref, {
  required String trackId,
  int index = 0,
  bool fromDownloadPack = false,
}) async {
  if (ref.read(musicOpenPlayerGuardProvider)) return false;

  final router = ref.read(routerProvider);
  syncMusicPlayerRouteStateForWidget(ref, router);

  if (isRouterOnMusicPlayerPage(router)) {
    return false;
  }

  ref.read(musicOpenPlayerGuardProvider.notifier).state = true;
  try {
    router.push(
      SHOAppRoutes.toolboxMusicPlayerFor(
        trackId,
        index: index,
        fromDownloadPack: fromDownloadPack,
      ),
    );
    return true;
  } finally {
    ref.read(musicOpenPlayerGuardProvider.notifier).state = false;
  }
}

final musicMiniPlayerDismissedProvider =
    NotifierProvider<SHOMusicMiniPlayerDismissedNotifier, bool>(
  SHOMusicMiniPlayerDismissedNotifier.new,
);

class SHOMusicMiniPlayerDismissedNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void show() => state = false;

  void dismiss() => state = true;
}

final musicMiniPlayerOffsetProvider =
    NotifierProvider<SHOMusicMiniPlayerOffsetNotifier, Offset?>(
  SHOMusicMiniPlayerOffsetNotifier.new,
);

class SHOMusicMiniPlayerOffsetNotifier extends Notifier<Offset?> {
  late final SharedPreferences _prefs;

  @override
  Offset? build() {
    _prefs = ref.read(sharedPreferencesProvider);
    final dx = _prefs.getDouble(SHOMusicStorageKeys.miniPlayerOffsetDx);
    final dy = _prefs.getDouble(SHOMusicStorageKeys.miniPlayerOffsetDy);
    if (dx == null || dy == null) return null;
    return Offset(dx, dy);
  }

  Future<void> save(Offset offset) async {
    state = offset;
    await _prefs.setDouble(SHOMusicStorageKeys.miniPlayerOffsetDx, offset.dx);
    await _prefs.setDouble(SHOMusicStorageKeys.miniPlayerOffsetDy, offset.dy);
  }
}
