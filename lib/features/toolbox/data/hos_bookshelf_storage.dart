import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/hos_local_storage.dart';
import '../domain/hos_bookshelf_entry.dart';

import 'hos_reading_storage_keys.dart';

const _storageKey = SHOReadingStorageKeys.bookshelf;

final bookshelfStorageProvider = Provider<SHOBookshelfStorage>((ref) {
  return SHOBookshelfStorage(ref.watch(sharedPreferencesProvider));
});

class SHOBookshelfStorage {
  SHOBookshelfStorage(this._prefs);

  final SharedPreferences _prefs;

  List<SHOBookshelfEntry> read() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => SHOBookshelfEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> write(List<SHOBookshelfEntry> entries) async {
    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await _prefs.setString(_storageKey, encoded);
  }

  Future<void> removeByTaskId(String taskId) async {
    final entries = read();
    final filtered = [
      for (final entry in entries)
        if (entry.taskId != taskId) entry,
    ];
    if (filtered.length == entries.length) return;
    await write(filtered);
  }
}
