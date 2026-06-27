import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/foundation.dart';

import 'package:shoo/core/config/hos_environment.dart';
import 'package:shoo/core/storage/key_value/hos_local_storage.dart';
import 'package:shoo/app/root/hos_app_restart.dart';
import 'package:shoo/core/debug/core/hos_debug_prefs.dart';
import 'package:shoo/core/logging/hos_logger.dart';

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

final consoleLogEnabledProvider =
    NotifierProvider<SHOConsoleLogEnabledNotifier, bool>(
  SHOConsoleLogEnabledNotifier.new,
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

class SHOConsoleLogEnabledNotifier extends Notifier<bool> {
  late final SHODebugPrefs _prefs;

  @override
  bool build() {
    _prefs = ref.read(debugPrefsProvider);
    if (!_debugPanelActive) return true;
    final enabled = _prefs.readConsoleLogEnabled();
    SHOAppLogger.setConsolePrintEnabled(enabled);
    return enabled;
  }

  Future<void> setEnabled(bool value) async {
    if (!_debugPanelActive) return;
    state = value;
    SHOAppLogger.setConsolePrintEnabled(value);
    await _prefs.writeConsoleLogEnabled(value);
  }
}

bool get _debugPanelActive {
  const forceDisable =
      bool.fromEnvironment('DISABLE_DEBUG_PANEL', defaultValue: false);
  return !kReleaseMode && !forceDisable;
}
