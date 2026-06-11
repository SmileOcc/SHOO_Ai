abstract final class SHOMusicStorageKeys {
  static const progressPrefix = 'music_playback_progress_';
  static const statsPrefix = 'music_stats_';
  static const dismissedLocalTasks = 'music_library_dismissed_v1';
  static const removedCachedSongs = 'music_removed_cached_v1';
  static const addedMusicPackTasks = 'music_pack_added_tasks_v1';
  static const dismissedTrackIds = 'music_dismissed_tracks_v1';
  static const miniPlayerOffsetDx = 'music_mini_player_offset_dx_v1';
  static const miniPlayerOffsetDy = 'music_mini_player_offset_dy_v1';

  static bool preserveOnPreferencesClear(String key) {
    return key == dismissedLocalTasks ||
        key == removedCachedSongs ||
        key == addedMusicPackTasks ||
        key == dismissedTrackIds ||
        key.startsWith(progressPrefix) ||
        key.startsWith(statsPrefix);
  }
}
