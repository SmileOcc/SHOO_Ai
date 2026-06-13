import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/foundation.dart';

import '../../config/hos_environment.dart';
import '../../storage/hos_local_storage.dart';
import 'hos_app_restart.dart';
import 'hos_debug_prefs.dart';

final debugPrefsProvider = Provider<SHODebugPrefs>((ref) {
  return SHODebugPrefs(ref.watch(sharedPreferencesProvider));
});

final runtimeEnvOverrideProvider =
    NotifierProvider<SHORuntimeEnvOverrideNotifier, SHOAppEnvironment?>(
  SHORuntimeEnvOverrideNotifier.new,
);

final showEnvBadgeProvider = NotifierProvider<SHOShowEnvBadgeNotifier, bool>(
  SHOShowEnvBadgeNotifier.new,
);

class SHORuntimeEnvOverrideNotifier extends Notifier<SHOAppEnvironment?> {
  late final SHODebugPrefs _prefs;

  @override
  SHOAppEnvironment? build() {
    _prefs = ref.read(debugPrefsProvider);
    if (!_debugPanelActive) return null;
    return _prefs.readEnvOverride();
  }

  Future<void> setOverride(SHOAppEnvironment env) async {
    if (!_debugPanelActive) return;
    if (state == env) return;
    state = env;
    await _prefs.writeEnvOverride(env);
    SHOAppRestart.requestRestart();
  }

  Future<void> resetOverride() async {
    if (!_debugPanelActive) return;
    if (state == null) return;
    state = null;
    await _prefs.writeEnvOverride(null);
    SHOAppRestart.requestRestart();
  }
}

class SHOShowEnvBadgeNotifier extends Notifier<bool> {
  late final SHODebugPrefs _prefs;

  @override
  bool build() {
    _prefs = ref.read(debugPrefsProvider);
    if (!_debugPanelActive) return false;
    return _prefs.readShowEnvBadge();
  }

  Future<void> setEnabled(bool value) async {
    if (!_debugPanelActive) return;
    state = value;
    await _prefs.writeShowEnvBadge(value);
  }
}

bool get _debugPanelActive {
  const forceDisable =
      bool.fromEnvironment('DISABLE_DEBUG_PANEL', defaultValue: false);
  return !kReleaseMode && !forceDisable;
}
