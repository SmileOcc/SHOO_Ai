abstract final class SHOVideoStorageKeys {
  static const library = 'video_library_v1';
  static const dismissedLocalTasks = 'video_library_dismissed_v1';
  static const progressPrefix = 'video_playback_progress_';

  static bool preserveOnPreferencesClear(String key) {
    return key == library ||
        key == dismissedLocalTasks ||
        key.startsWith(progressPrefix);
  }
}
