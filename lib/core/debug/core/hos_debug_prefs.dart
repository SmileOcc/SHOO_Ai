import 'package:shared_preferences/shared_preferences.dart';

import '../../config/hos_environment.dart';
import '../../constants/hos_constants.dart';

/// Debug 面板偏好：环境覆盖、环境角标开关等。
class SHODebugPrefs {
  SHODebugPrefs(this._prefs);

  final SharedPreferences _prefs;

  SHOAppEnvironment? readEnvOverride() {
    final raw = _prefs.getString(SHOAppConstants.debugEnvOverrideKey);
    if (raw == null || raw.isEmpty) return null;
    return SHOAppEnvironment.fromString(raw);
  }

  Future<void> writeEnvOverride(SHOAppEnvironment? env) async {
    if (env == null) {
      await _prefs.remove(SHOAppConstants.debugEnvOverrideKey);
      return;
    }
    await _prefs.setString(SHOAppConstants.debugEnvOverrideKey, env.name);
  }

  bool readShowEnvBadge() =>
      _prefs.getBool(SHOAppConstants.debugShowEnvBadgeKey) ?? false;

  Future<void> writeShowEnvBadge(bool value) =>
      _prefs.setBool(SHOAppConstants.debugShowEnvBadgeKey, value);
}
