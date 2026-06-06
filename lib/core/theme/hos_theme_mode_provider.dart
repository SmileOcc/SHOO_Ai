import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/hos_local_storage.dart';

final themeModeProvider =
    StateNotifierProvider<SHOThemeModeNotifier, ThemeMode>((ref) {
  return SHOThemeModeNotifier(ref.watch(localStorageProvider));
});

class SHOThemeModeNotifier extends StateNotifier<ThemeMode> {
  SHOThemeModeNotifier(this._storage) : super(ThemeMode.system) {
    _restore();
  }

  final SHOLocalStorage _storage;

  void _restore() {
    final saved = _storage.getThemeMode();
    state = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _storage.setThemeMode(value);
  }
}
