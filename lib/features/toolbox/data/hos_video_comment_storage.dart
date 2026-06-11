import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/hos_local_storage.dart';
import '../domain/hos_video_comment.dart';

const _storageKey = 'video_comments_v1';

final videoCommentStorageProvider = Provider<SHOVideoCommentStorage>((ref) {
  return SHOVideoCommentStorage(ref.watch(sharedPreferencesProvider));
});

class SHOVideoCommentStorage {
  SHOVideoCommentStorage(this._prefs);

  final SharedPreferences _prefs;

  Map<String, List<SHOVideoComment>> _readAll() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((videoId, list) {
      final items = (list as List<dynamic>)
          .map((e) => SHOVideoComment.fromJson(e as Map<String, dynamic>))
          .toList();
      return MapEntry(videoId, items);
    });
  }

  List<SHOVideoComment> read(String videoId) {
    return _readAll()[videoId] ?? const <SHOVideoComment>[];
  }

  Future<void> append(SHOVideoComment comment) async {
    final all = _readAll();
    final previous = all[comment.videoId] ?? const <SHOVideoComment>[];
    final list = <SHOVideoComment>[...previous, comment];
    all[comment.videoId] = list;
    final encoded = jsonEncode(
      all.map(
        (key, value) => MapEntry(key, value.map((e) => e.toJson()).toList()),
      ),
    );
    await _prefs.setString(_storageKey, encoded);
  }
}
