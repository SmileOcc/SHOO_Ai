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
    StateNotifierProvider<SHORuntimeEnvOverrideNotifier, SHOAppEnvironment?>(
  (ref) => SHORuntimeEnvOverrideNotifier(ref.watch(debugPrefsProvider)),
);

final showEnvBadgeProvider =
    StateNotifierProvider<SHOShowEnvBadgeNotifier, bool>(
  (ref) => SHOShowEnvBadgeNotifier(ref.watch(debugPrefsProvider)),
);

class SHORuntimeEnvOverrideNotifier extends StateNotifier<SHOAppEnvironment?> {
  SHORuntimeEnvOverrideNotifier(this._prefs) : super(null) {
    _restore();
  }

  final SHODebugPrefs _prefs;

  void _restore() {
    if (!_debugPanelActive) return;
    state = _prefs.readEnvOverride();
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

class SHOShowEnvBadgeNotifier extends StateNotifier<bool> {
  SHOShowEnvBadgeNotifier(this._prefs) : super(false) {
    _restore();
  }

  final SHODebugPrefs _prefs;

  void _restore() {
    if (!_debugPanelActive) return;
    state = _prefs.readShowEnvBadge();
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
