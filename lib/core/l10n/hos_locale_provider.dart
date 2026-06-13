import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/hos_local_storage.dart';

const supportedLocaleCodes = ['en', 'zh'];

final localeProvider = NotifierProvider<SHOLocaleNotifier, Locale?>(
  SHOLocaleNotifier.new,
);

class SHOLocaleNotifier extends Notifier<Locale?> {
  late final SHOLocalStorage _storage;

  @override
  Locale? build() {
    _storage = ref.read(localStorageProvider);
    final code = _storage.getLocaleCode();
    if (code != null && supportedLocaleCodes.contains(code)) {
      return Locale(code);
    }
    return null;
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
