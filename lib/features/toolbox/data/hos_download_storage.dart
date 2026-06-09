import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/hos_local_storage.dart';
import '../domain/hos_download_task.dart';

const _storageKey = 'download_tasks_v1';

final downloadStorageProvider = Provider<SHODownloadStorage>((ref) {
  return SHODownloadStorage(ref.watch(sharedPreferencesProvider));
});

class SHODownloadStorage {
  SHODownloadStorage(this._prefs);

  final SharedPreferences _prefs;

  List<SHODownloadTask> read() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => SHODownloadTask.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> write(List<SHODownloadTask> tasks) async {
    final encoded = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await _prefs.setString(_storageKey, encoded);
  }
}
