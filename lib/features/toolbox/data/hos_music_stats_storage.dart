import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/hos_local_storage.dart';
import '../domain/hos_music_track_stats.dart';
import 'hos_music_storage_keys.dart';

final musicStatsStorageProvider = Provider<SHOMusicStatsStorage>((ref) {
  return SHOMusicStatsStorage(ref.watch(sharedPreferencesProvider));
});

class SHOMusicStatsStorage {
  SHOMusicStatsStorage(this._prefs);

  final SharedPreferences _prefs;

  String _key(String trackId) => '${SHOMusicStorageKeys.statsPrefix}$trackId';

  SHOMusicTrackStats read(String trackId) {
    final raw = _prefs.getString(_key(trackId));
    if (raw == null || raw.isEmpty) return const SHOMusicTrackStats();
    return SHOMusicTrackStats.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> write(String trackId, SHOMusicTrackStats stats) async {
    await _prefs.setString(_key(trackId), jsonEncode(stats.toJson()));
  }

  Future<SHOMusicTrackStats> recordPlay(String trackId) async {
    final current = read(trackId);
    final next = current.copyWith(
      playCount: current.playCount + 1,
      lastPlayedAt: () => DateTime.now(),
    );
    await write(trackId, next);
    return next;
  }

  Future<SHOMusicTrackStats> toggleLike(String trackId) async {
    final current = read(trackId);
    final next = current.copyWith(liked: !current.liked);
    await write(trackId, next);
    return next;
  }

  Future<void> remove(String trackId) async {
    await _prefs.remove(_key(trackId));
  }
}
