import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/hos_music_pack_service.dart';
import '../domain/hos_download_task.dart';
import '../domain/hos_txt_novel_parser.dart';
import 'hos_bookshelf_controller.dart';
import 'hos_download_controller.dart';
import 'music/hos_music_library_controller.dart';

class SHODownloadTaskStatus {
  const SHODownloadTaskStatus({
    this.isMusicPack = false,
    this.isTxtNovel = false,
    this.isExtracted = false,
    this.inMusicLibrary = false,
    this.inBookshelf = false,
  });

  final bool isMusicPack;
  final bool isTxtNovel;
  final bool isExtracted;
  final bool inMusicLibrary;
  final bool inBookshelf;

  bool get showExtractedBadge =>
      isMusicPack && isExtracted;

  bool get showInMusicBadge =>
      isMusicPack && inMusicLibrary;

  bool get showInBookshelfBadge =>
      isTxtNovel && inBookshelf;
}

final downloadTaskStatusProvider =
    FutureProvider.family<SHODownloadTaskStatus, String>((ref, taskId) async {
  ref.watch(musicLibraryRevisionProvider);
  final tasks = ref.watch(downloadTasksProvider);
  final task = tasks.cast<SHODownloadTask?>().firstWhere(
        (item) => item?.id == taskId,
        orElse: () => null,
      );
  if (task == null) return const SHODownloadTaskStatus();

  final packService = ref.watch(musicPackServiceProvider);
  final isMusicPack = packService.isMusicPackZip(task);
  final isTxtNovel = isTxtNovelFile(task.fileName);
  final libraryItems = await ref.watch(musicLibraryListProvider.future);
  final inMusicLibrary = isMusicPack &&
      musicPackItemsInLibrary(libraryItems, taskId).isNotEmpty;
  final inBookshelf = ref
      .watch(bookshelfEntriesProvider)
      .any((entry) => entry.taskId == taskId);

  var isExtracted = false;
  if (isMusicPack && task.status == SHODownloadStatus.completed) {
    isExtracted = await packService.hasCachedSongsForPack(task);
  }

  return SHODownloadTaskStatus(
    isMusicPack: isMusicPack,
    isTxtNovel: isTxtNovel,
    isExtracted: isExtracted,
    inMusicLibrary: inMusicLibrary,
    inBookshelf: inBookshelf,
  );
});

Future<bool> isMusicPackInLibrary(WidgetRef ref, String packTaskId) async {
  final items = await ref.read(musicLibraryListProvider.future);
  return musicPackItemsInLibrary(items, packTaskId).isNotEmpty;
}

bool isDownloadInBookshelf(WidgetRef ref, String taskId) {
  return ref.read(bookshelfEntriesProvider.notifier).contains(taskId);
}
