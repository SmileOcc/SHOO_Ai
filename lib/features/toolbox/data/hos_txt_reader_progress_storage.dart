import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/hos_local_storage.dart';
import '../domain/hos_txt_novel_models.dart';

final txtReaderProgressStorageProvider =
    Provider<SHOTxtReaderProgressStorage>((ref) {
  return SHOTxtReaderProgressStorage(ref.watch(sharedPreferencesProvider));
});

class SHOTxtReaderProgressStorage {
  SHOTxtReaderProgressStorage(this._prefs);

  final SharedPreferences _prefs;

  String _key(String taskId) => 'txt_reader_progress_$taskId';

  SHOTxtReaderProgress? read(String taskId) {
    final raw = _prefs.getString(_key(taskId));
    if (raw == null || raw.isEmpty) return null;
    return SHOTxtReaderProgress.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> write(String taskId, SHOTxtReaderProgress progress) async {
    await _prefs.setString(_key(taskId), jsonEncode(progress.toJson()));
  }

  Future<void> remove(String taskId) async {
    await _prefs.remove(_key(taskId));
  }
}
