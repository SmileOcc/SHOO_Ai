import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/hos_local_storage.dart';
import 'hos_music_storage_keys.dart';

final musicPackAddedTasksProvider =
    StateNotifierProvider<SHOMusicPackAddedTasksNotifier, Set<String>>((ref) {
  return SHOMusicPackAddedTasksNotifier(ref.watch(sharedPreferencesProvider));
});

class SHOMusicPackAddedTasksNotifier extends StateNotifier<Set<String>> {
  SHOMusicPackAddedTasksNotifier(this._prefs) : super(_readAdded(_prefs));

  final SharedPreferences _prefs;

  static Set<String> _readAdded(SharedPreferences prefs) {
    final raw = prefs.getStringList(SHOMusicStorageKeys.addedMusicPackTasks);
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
