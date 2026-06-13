import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/hos_local_storage.dart';

final themeModeProvider = NotifierProvider<SHOThemeModeNotifier, ThemeMode>(
  SHOThemeModeNotifier.new,
);

class SHOThemeModeNotifier extends Notifier<ThemeMode> {
  late final SHOLocalStorage _storage;

  @override
  ThemeMode build() {
    _storage = ref.read(localStorageProvider);
    final saved = _storage.getThemeMode();
    return switch (saved) {
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
