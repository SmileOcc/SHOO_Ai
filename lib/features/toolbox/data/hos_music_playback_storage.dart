import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/hos_local_storage.dart';
import 'hos_music_storage_keys.dart';

final musicPlaybackStorageProvider = Provider<SHOMusicPlaybackStorage>((ref) {
  return SHOMusicPlaybackStorage(ref.watch(sharedPreferencesProvider));
});

class SHOMusicPlaybackStorage {
  SHOMusicPlaybackStorage(this._prefs);

  final SharedPreferences _prefs;

  String _key(String trackId) =>
      '${SHOMusicStorageKeys.progressPrefix}$trackId';

  Duration? readPosition(String trackId) {
    final ms = _prefs.getInt(_key(trackId));
    if (ms == null || ms <= 0) return null;
    return Duration(milliseconds: ms);
  }

  Future<void> writePosition(String trackId, Duration position) async {
    await _prefs.setInt(_key(trackId), position.inMilliseconds);
  }

  Future<void> remove(String trackId) async {
    await _prefs.remove(_key(trackId));
  }
}
