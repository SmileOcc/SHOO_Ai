import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/hos_local_storage.dart';
import '../domain/hos_video_playback_progress.dart';
import 'hos_video_storage_keys.dart';

final videoPlaybackStorageProvider = Provider<SHOVideoPlaybackStorage>((ref) {
  return SHOVideoPlaybackStorage(ref.watch(sharedPreferencesProvider));
});

class SHOVideoPlaybackStorage {
  SHOVideoPlaybackStorage(this._prefs);

  final SharedPreferences _prefs;

  String _key(String entryId) => '${SHOVideoStorageKeys.progressPrefix}$entryId';

  SHOVideoPlaybackProgress? read(String entryId) {
    final raw = _prefs.getString(_key(entryId));
    if (raw == null || raw.isEmpty) return null;
    return SHOVideoPlaybackProgress.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> write(SHOVideoPlaybackProgress progress) async {
    await _prefs.setString(
      _key(progress.entryId),
      jsonEncode(progress.toJson()),
    );
  }

  Future<void> remove(String entryId) async {
    await _prefs.remove(_key(entryId));
  }
}
