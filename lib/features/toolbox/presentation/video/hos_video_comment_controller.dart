import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/hos_video_comment_storage.dart';
import '../../domain/hos_video_comment.dart';

final videoCommentsProvider = StateNotifierProvider.family<
    SHOVideoCommentsNotifier, List<SHOVideoComment>, String>(
  (ref, videoId) => SHOVideoCommentsNotifier(
    ref.watch(videoCommentStorageProvider),
    videoId,
  ),
);

class SHOVideoCommentsNotifier extends StateNotifier<List<SHOVideoComment>> {
  SHOVideoCommentsNotifier(this._storage, this._videoId)
      : super(_storage.read(_videoId));

  final SHOVideoCommentStorage _storage;
  final String _videoId;

  Future<SHOVideoComment?> add(String content, {required String authorName}) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return null;

    final comment = SHOVideoComment(
      id: 'vc_${DateTime.now().millisecondsSinceEpoch}',
      videoId: _videoId,
      content: trimmed,
      createdAt: DateTime.now(),
      authorName: authorName,
    );
    state = [...state, comment];
    await _storage.append(comment);
    return comment;
  }
}
