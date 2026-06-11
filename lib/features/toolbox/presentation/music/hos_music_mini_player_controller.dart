import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/router/hos_router.dart';
import '../../../../app/router/hos_routes.dart';
import '../../../../core/storage/hos_local_storage.dart';
import '../../data/hos_music_storage_keys.dart';
import 'hos_music_route_state.dart';

export 'hos_music_route_state.dart';

Future<void> openMusicPlayerPage(
  WidgetRef ref, {
  required String trackId,
  int index = 0,
}) async {
  if (ref.read(musicOpenPlayerGuardProvider)) return;

  final router = ref.read(routerProvider);
  if (ref.read(musicOnPlayerPageProvider)) return;

  ref.read(musicOpenPlayerGuardProvider.notifier).state = true;
  try {
    await router.push(
      SHOAppRoutes.toolboxMusicPlayerFor(trackId, index: index),
    );
  } finally {
    ref.read(musicOpenPlayerGuardProvider.notifier).state = false;
  }
}

final musicMiniPlayerDismissedProvider =
    StateNotifierProvider<SHOMusicMiniPlayerDismissedNotifier, bool>((ref) {
  return SHOMusicMiniPlayerDismissedNotifier();
});

class SHOMusicMiniPlayerDismissedNotifier extends StateNotifier<bool> {
  SHOMusicMiniPlayerDismissedNotifier() : super(true);

  void show() => state = false;

  void dismiss() => state = true;
}

final musicMiniPlayerOffsetProvider =
    StateNotifierProvider<SHOMusicMiniPlayerOffsetNotifier, Offset?>((ref) {
  return SHOMusicMiniPlayerOffsetNotifier(ref.watch(sharedPreferencesProvider));
});

class SHOMusicMiniPlayerOffsetNotifier extends StateNotifier<Offset?> {
  SHOMusicMiniPlayerOffsetNotifier(this._prefs) : super(_readOffset(_prefs));

  final SharedPreferences _prefs;

  static Offset? _readOffset(SharedPreferences prefs) {
    final dx = prefs.getDouble(SHOMusicStorageKeys.miniPlayerOffsetDx);
    final dy = prefs.getDouble(SHOMusicStorageKeys.miniPlayerOffsetDy);
    if (dx == null || dy == null) return null;
    return Offset(dx, dy);
  }

  Future<void> save(Offset offset) async {
    state = offset;
    await _prefs.setDouble(SHOMusicStorageKeys.miniPlayerOffsetDx, offset.dx);
    await _prefs.setDouble(SHOMusicStorageKeys.miniPlayerOffsetDy, offset.dy);
  }
}
