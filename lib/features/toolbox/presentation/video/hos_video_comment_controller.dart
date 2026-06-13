import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/hos_video_comment_storage.dart';
import '../../domain/hos_video_comment.dart';

final videoCommentsProvider = NotifierProvider.family<
    SHOVideoCommentsNotifier, List<SHOVideoComment>, String>(
  SHOVideoCommentsNotifier.new,
);

class SHOVideoCommentsNotifier
    extends FamilyNotifier<List<SHOVideoComment>, String> {
  late final SHOVideoCommentStorage _storage;

  @override
  List<SHOVideoComment> build(String videoId) {
    _storage = ref.read(videoCommentStorageProvider);
    return _storage.read(videoId);
  }

  Future<SHOVideoComment?> add(String content, {required String authorName}) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return null;

    final comment = SHOVideoComment(
      id: 'vc_${DateTime.now().millisecondsSinceEpoch}',
      videoId: arg,
      content: trimmed,
      createdAt: DateTime.now(),
      authorName: authorName,
    );
    state = [...state, comment];
    await _storage.append(comment);
    return comment;
  }
}
