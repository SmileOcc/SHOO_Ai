import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/constants/hos_constants.dart';
import 'package:shoo/core/storage/key_value/hos_local_storage.dart';

final securityPrefsProvider =
    NotifierProvider<SHOSecurityPrefsNotifier, SHOSecurityPrefs>(
  SHOSecurityPrefsNotifier.new,
);

class SHOSecurityPrefs {
  const SHOSecurityPrefs({this.biometricLoginEnabled = false});

  final bool biometricLoginEnabled;

  SHOSecurityPrefs copyWith({bool? biometricLoginEnabled}) {
    return SHOSecurityPrefs(
      biometricLoginEnabled:
          biometricLoginEnabled ?? this.biometricLoginEnabled,
    );
  }
}

class SHOSecurityPrefsNotifier extends Notifier<SHOSecurityPrefs> {
  late final SHOLocalStorage _storage;

  @override
  SHOSecurityPrefs build() {
    _storage = ref.read(localStorageProvider);
    return SHOSecurityPrefs(
      biometricLoginEnabled:
          _storage.readSync<bool>(SHOAppConstants.biometricLoginEnabledKey) ??
          false,
    );
  }

  Future<void> setBiometricLoginEnabled(bool value) async {
    state = state.copyWith(biometricLoginEnabled: value);
    await _storage.write(SHOAppConstants.biometricLoginEnabledKey, value);
  }
}
