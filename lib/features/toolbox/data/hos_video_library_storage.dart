import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/hos_local_storage.dart';
import '../domain/hos_video_library_entry.dart';
import 'hos_video_storage_keys.dart';

final videoLibraryStorageProvider = Provider<SHOVideoLibraryStorage>((ref) {
  return SHOVideoLibraryStorage(ref.watch(sharedPreferencesProvider));
});

class SHOVideoLibraryStorage {
  SHOVideoLibraryStorage(this._prefs);

  final SharedPreferences _prefs;

  List<SHOVideoLibraryEntry> readEntries() {
    final raw = _prefs.getString(SHOVideoStorageKeys.library);
    if (raw == null || raw.isEmpty) return const [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => SHOVideoLibraryEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> writeEntries(List<SHOVideoLibraryEntry> entries) async {
    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await _prefs.setString(SHOVideoStorageKeys.library, encoded);
  }

  Set<String> readDismissedLocalTaskIds() {
    final raw = _prefs.getString(SHOVideoStorageKeys.dismissedLocalTasks);
    if (raw == null || raw.isEmpty) return {};
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => e as String).toSet();
  }

  Future<void> writeDismissedLocalTaskIds(Set<String> ids) async {
    await _prefs.setString(
      SHOVideoStorageKeys.dismissedLocalTasks,
      jsonEncode(ids.toList()),
    );
  }
}
