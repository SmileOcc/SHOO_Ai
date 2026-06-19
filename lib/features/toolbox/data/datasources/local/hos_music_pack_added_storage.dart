import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shoo/core/storage/key_value/hos_local_storage.dart';
import 'package:shoo/features/toolbox/data/datasources/local/hos_music_storage_keys.dart';

final musicPackAddedTasksProvider =
    NotifierProvider<SHOMusicPackAddedTasksNotifier, Set<String>>(
  SHOMusicPackAddedTasksNotifier.new,
);

class SHOMusicPackAddedTasksNotifier extends Notifier<Set<String>> {
  late final SharedPreferences _prefs;

  @override
  Set<String> build() {
    _prefs = ref.read(sharedPreferencesProvider);
    final raw = _prefs.getStringList(SHOMusicStorageKeys.addedMusicPackTasks);
    return raw?.toSet() ?? {};
  }

  bool contains(String taskId) => state.contains(taskId);

  Future<void> add(String taskId) async {
    if (state.contains(taskId)) return;
    final next = {...state, taskId};
    state = next;
    await _prefs.setStringList(
      SHOMusicStorageKeys.addedMusicPackTasks,
      next.toList(),
    );
  }

  Future<void> remove(String taskId) async {
    if (!state.contains(taskId)) return;
    final next = {...state}..remove(taskId);
    state = next;
    await _prefs.setStringList(
      SHOMusicStorageKeys.addedMusicPackTasks,
      next.toList(),
    );
  }
}
