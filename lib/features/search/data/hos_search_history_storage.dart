import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/hos_constants.dart';
import '../../../core/storage/hos_local_storage.dart';

final searchHistoryStorageProvider = Provider<SHOSearchHistoryStorage>((ref) {
  return SHOSearchHistoryStorage(ref.watch(localStorageProvider));
});

class SHOSearchHistoryStorage {
  SHOSearchHistoryStorage(this._storage);

  final SHOLocalStorage _storage;

  Future<List<String>> read() async {
    final raw = await _storage.read<String>(SHOAppConstants.searchHistoryKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> add(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return;

    final history = await read();
    final next = [
      trimmed,
      ...history.where((h) => h.toLowerCase() != trimmed.toLowerCase()),
    ].take(SHOAppConstants.searchHistoryMax).toList();

    await _storage.write(SHOAppConstants.searchHistoryKey, jsonEncode(next));
  }

  Future<void> clear() => _storage.remove(SHOAppConstants.searchHistoryKey);
}
