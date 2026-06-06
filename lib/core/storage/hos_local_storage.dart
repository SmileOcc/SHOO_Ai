import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    await _prefs.clear();
    if (theme != null) await setThemeMode(theme);
    if (locale != null) await setLocaleCode(locale);
  }

  Future<T?> read<T>(String key) async {
    try {
      if (T == String) return _prefs.getString(key) as T?;
      if (T == int) return _prefs.getInt(key) as T?;
      if (T == bool) return _prefs.getBool(key) as T?;
      if (T == double) return _prefs.getDouble(key) as T?;
      throw SHOCacheException('Unsupported type: $T');
    } catch (_) {
      throw const SHOCacheException('Failed to read local data');
    }
  }

  Future<void> remove(String key) => _prefs.remove(key);

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
