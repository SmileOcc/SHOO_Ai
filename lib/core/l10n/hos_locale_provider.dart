import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/hos_local_storage.dart';

const supportedLocaleCodes = ['en', 'zh'];

final localeProvider = StateNotifierProvider<SHOLocaleNotifier, Locale?>((ref) {
  return SHOLocaleNotifier(ref.watch(localStorageProvider));
});

class SHOLocaleNotifier extends StateNotifier<Locale?> {
  SHOLocaleNotifier(this._storage) : super(null) {
    _restore();
  }

  final SHOLocalStorage _storage;

  void _restore() {
    final code = _storage.getLocaleCode();
    if (code != null && supportedLocaleCodes.contains(code)) {
      state = Locale(code);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _storage.setLocaleCode(locale.languageCode);
  }

  Future<void> clearLocale() async {
    state = null;
    await _storage.setLocaleCode('');
  }
}
