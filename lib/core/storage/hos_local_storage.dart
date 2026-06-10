import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/toolbox/data/hos_reading_storage_keys.dart';
import '../constants/hos_constants.dart';
import '../errors/hos_exception.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden at startup');
});

final localStorageProvider = Provider<SHOLocalStorage>((ref) {
  return SHOLocalStorage(ref.watch(sharedPreferencesProvider));
});

/// 非敏感偏好存储：主题、语言、搜索历史等。
class SHOLocalStorage {
  SHOLocalStorage(this._prefs);

  final SharedPreferences _prefs;

  Future<void> setThemeMode(String mode) =>
      _prefs.setString(SHOAppConstants.themeModeKey, mode);

  String? getThemeMode() => _prefs.getString(SHOAppConstants.themeModeKey);

  Future<void> setLocaleCode(String code) =>
      _prefs.setString(SHOAppConstants.localeKey, code);

  String? getLocaleCode() => _prefs.getString(SHOAppConstants.localeKey);

  Future<void> clear() async {
    final theme = getThemeMode();
    final locale = getLocaleCode();
    final envOverride = _prefs.getString(SHOAppConstants.debugEnvOverrideKey);
    final showEnvBadge = _prefs.getBool(SHOAppConstants.debugShowEnvBadgeKey);
    final preserved = <String, Object>{};
    for (final key in _prefs.getKeys()) {
      if (!SHOReadingStorageKeys.preserveOnPreferencesClear(key)) continue;
      final value = _prefs.get(key);
      if (value != null) preserved[key] = value;
    }
    await _prefs.clear();
    if (theme != null) await setThemeMode(theme);
    if (locale != null) await setLocaleCode(locale);
    if (envOverride != null) {
      await _prefs.setString(SHOAppConstants.debugEnvOverrideKey, envOverride);
    }
    if (showEnvBadge != null) {
      await _prefs.setBool(SHOAppConstants.debugShowEnvBadgeKey, showEnvBadge);
    }
    for (final entry in preserved.entries) {
      final value = entry.value;
      if (value is String) {
        await _prefs.setString(entry.key, value);
      } else if (value is bool) {
        await _prefs.setBool(entry.key, value);
      } else if (value is int) {
        await _prefs.setInt(entry.key, value);
      } else if (value is double) {
        await _prefs.setDouble(entry.key, value);
      } else if (value is List<String>) {
        await _prefs.setStringList(entry.key, value);
      }
    }
  }

  T? readSync<T>(String key) {
    if (!_prefs.containsKey(key)) return null;
    try {
      final value = _prefs.get(key);
      if (value == null) return null;
      return value as T?;
    } catch (_) {
      return null;
    }
  }

  Future<T?> read<T>(String key) async => readSync<T>(key);

  /// 估算 SharedPreferences 单条键值占用（字节，近似值）。
  int estimateKeyBytes(String key) {
    if (!_prefs.containsKey(key)) return 0;
    final value = _prefs.get(key);
    if (value == null) return key.length;
    final payload = switch (value) {
      String s => s,
      List<String> list => list.join(','),
      _ => value.toString(),
    };
    return key.length + payload.length;
  }

  Future<void> remove(String key) => _prefs.remove(key);

  Set<String> get keys => _prefs.getKeys();

  Future<void> write<T>(String key, T value) async {
    try {
      if (value is String) {
        await _prefs.setString(key, value);
      } else if (value is int) {
        await _prefs.setInt(key, value);
      } else if (value is bool) {
        await _prefs.setBool(key, value);
      } else if (value is double) {
        await _prefs.setDouble(key, value);
      } else {
        throw SHOCacheException('Unsupported type: ${value.runtimeType}');
      }
    } catch (_) {
      throw const SHOCacheException('Failed to write local data');
    }
  }
}
