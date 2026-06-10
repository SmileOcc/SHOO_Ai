/// 阅读相关 SharedPreferences 键，清理「应用偏好」时需保留。
abstract final class SHOReadingStorageKeys {
  static const bookshelf = 'novel_bookshelf_v1';
  static const downloadTasks = 'download_tasks_v1';
  static const progressPrefix = 'txt_reader_progress_';

  static bool preserveOnPreferencesClear(String key) {
    return key == bookshelf ||
        key == downloadTasks ||
        key.startsWith(progressPrefix);
  }
}
