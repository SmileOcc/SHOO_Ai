import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/dialogs/hos_confirm_card_dialog.dart';
import '../../../core/feedback/hos_overlay_loading.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/hos_download_task.dart';
import '../domain/hos_music_track.dart';
import '../domain/hos_txt_novel_parser.dart';
import 'hos_download_preview_page.dart';
import 'hos_download_controller.dart';
import 'hos_txt_reader_page.dart';
import 'hos_video_player_page.dart';
import '../data/hos_music_pack_service.dart';
import 'hos_download_click_reporter.dart';
import 'hos_download_task_status.dart';
import 'music/hos_music_library_controller.dart';
import 'music/hos_music_mini_player_controller.dart';
import 'hos_bookshelf_controller.dart';

Future<void> handleDownloadTaskTap(
  BuildContext context,
  WidgetRef ref,
  SHODownloadTask task,
) async {
  final l10n = AppLocalizations.of(context);
  unawaited(SHODownloadClickReporter.reportClick(task));

  if (task.fileType == SHODownloadFileType.zip &&
      const SHOMusicPackService().isMusicPackZip(task)) {
    if (task.status != SHODownloadStatus.completed) {
      await SHOConfirmCardDialog.show(
        context,
        title: l10n.downloadPreviewNotCompleted,
        confirmLabel: l10n.downloadPreviewOk,
      );
      return;
    }
    if (!context.mounted) return;

    await _handleMusicPackTap(context, ref, task, l10n);
    return;
  }

  final previewable = isDownloadTaskPreviewable(task);

  if (!previewable) {
    await SHOConfirmCardDialog.show(
      context,
      title: l10n.downloadPreviewUnsupported,
      confirmLabel: l10n.downloadPreviewOk,
    );
    return;
  }

  if (task.status != SHODownloadStatus.completed) {
    await SHOConfirmCardDialog.show(
      context,
      title: l10n.downloadPreviewNotCompleted,
      confirmLabel: l10n.downloadPreviewOk,
    );
    return;
  }

  if (isTxtNovelFile(task.fileName)) {
    if (!context.mounted) return;
    await SHOTxtReaderPage.open(context: context, task: task);
    return;
  }

  if (task.fileType == SHODownloadFileType.video) {
    if (!context.mounted) return;
    await SHOVideoPlayerPage.openWithTask(context: context, taskId: task.id);
    return;
  }

  final opened = await SHODownloadPreviewPage.open(context: context, task: task);
  if (!opened && context.mounted) {
    await SHOConfirmCardDialog.show(
      context,
      title: l10n.downloadPreviewFailed,
      confirmLabel: l10n.downloadPreviewOk,
    );
  }
}

Future<void> _handleMusicPackTap(
  BuildContext context,
  WidgetRef ref,
  SHODownloadTask task,
  AppLocalizations l10n,
) async {
  final packService = ref.read(musicPackServiceProvider);
  final allTasks = ref.read(downloadTasksProvider);

  var libraryItems = await ref.read(musicLibraryListProvider.future);
  if (!context.mounted) return;

  var packItems = musicPackItemsInLibrary(libraryItems, task.id);
  final inList = packItems.isNotEmpty;
  var hasCache = await packService.hasCachedSongsForPack(task);
  if (!hasCache && inList && _packItemsArePlayable(packItems)) {
    hasCache = true;
  }

  if (inList && !hasCache) {
    await _runMusicPackExtract(ref, task, l10n, () async {
      return ensurePackCached(
        ref,
        packTask: task,
        packService: packService,
      );
    });
    if (!context.mounted) return;
    libraryItems = await ref.read(musicLibraryListProvider.future);
    packItems = musicPackItemsInLibrary(libraryItems, task.id);
    if (!context.mounted) return;
    if (packItems.isNotEmpty) {
      await _openPackPlayback(ref, packItems);
    }
    return;
  }

  if (!inList && hasCache) {
    await _reportMusicAlreadyExtracted(task, packService);
    if (!context.mounted) return;
    final opened = await _playCachedPackTracks(ref, task, allTasks, packService);
    if (!opened && context.mounted) {
      await SHOConfirmCardDialog.show(
        context,
        title: l10n.musicInvalidTitle,
        message: l10n.musicInvalidMessage,
        confirmLabel: l10n.downloadPreviewOk,
      );
      return;
    }
    if (!context.mounted) return;
    unawaited(
      ensurePackInLibrary(
        ref,
        packTask: task,
        packService: packService,
      ),
    );
    return;
  }

  if (inList) {
    unawaited(_reportMusicAlreadyExtracted(task, packService));
    await _openPackPlayback(ref, packItems);
    return;
  }

  if (!context.mounted) return;
  final ok = await SHOConfirmCardDialog.show(
    context,
    title: l10n.musicPackAddToLibraryTitle,
    message: l10n.musicPackAddToLibraryMessage,
    confirmLabel: l10n.musicPackAddToLibraryConfirm,
  );
  if (!ok || !context.mounted) return;

  await _runMusicPackExtract(ref, task, l10n, () async {
    final result = await ensurePackInLibrary(
      ref,
      packTask: task,
      packService: packService,
    );
    libraryItems = result.items;
    return result.extractedPaths;
  });
  if (!context.mounted) return;
  context.push(SHOAppRoutes.profileMusicLibraryFromDownload());
}

Future<List<String>> _runMusicPackExtract(
  WidgetRef ref,
  SHODownloadTask task,
  AppLocalizations l10n,
  Future<List<String>> Function() extractTask,
) async {
  List<String> extractedPaths = const [];
  await _runMusicPackLoading(ref, l10n.musicPackImporting, () async {
    extractedPaths = await extractTask();
  });
  await SHODownloadClickReporter.reportMusicExtract(
    task: task,
    extractPaths: extractedPaths,
  );
  return extractedPaths;
}

Future<void> _reportMusicAlreadyExtracted(
  SHODownloadTask task,
  SHOMusicPackService packService,
) async {
  final extractPaths = await packService.collectPackCachePaths(task);
  await SHODownloadClickReporter.reportMusicAlreadyExtracted(
    task: task,
    extractPaths: extractPaths,
  );
}

bool _packItemsArePlayable(List<SHOMusicLibraryListItem> packItems) {
  return packItems.any((item) {
    final track = item.track;
    return track.isCachedLocally ||
        (track.localPath != null && track.localPath!.isNotEmpty);
  });
}

Future<void> _openMusicPlayer(
  WidgetRef ref, {
  required List<SHOMusicTrack> playlist,
  int startIndex = 0,
}) async {
  if (playlist.isEmpty) return;

  final index = startIndex.clamp(0, playlist.length - 1);
  await openMusicPlayerPage(
    ref,
    trackId: playlist[index].id,
    index: index,
    fromDownloadPack: true,
  );
}

Future<bool> _playCachedPackTracks(
  WidgetRef ref,
  SHODownloadTask task,
  List<SHODownloadTask> allTasks,
  SHOMusicPackService packService,
) async {
  final cachedTracks = await packService.buildCachedPackTracks(
    packTask: task,
    downloadTasks: allTasks,
  );
  if (cachedTracks.isEmpty) return false;
  await openMusicPlayerPage(
    ref,
    trackId: cachedTracks.first.id,
    fromDownloadPack: true,
  );
  return true;
}

Future<void> _openPackPlayback(
  WidgetRef ref,
  List<SHOMusicLibraryListItem> packItems,
) async {
  final playlist = packItems.map((item) => item.track).toList();
  await _openMusicPlayer(ref, playlist: playlist);
}

Future<void> addDownloadTaskToBookshelf(
  BuildContext context,
  WidgetRef ref,
  SHODownloadTask task,
) async {
  if (task.status != SHODownloadStatus.completed) return;
  if (!isTxtNovelFile(task.fileName)) return;
  if (isDownloadInBookshelf(ref, task.id)) return;

  await ref.read(bookshelfEntriesProvider.notifier).add(task.id);
  if (!context.mounted) return;
  final l10n = AppLocalizations.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(l10n.txtReaderAddedBookshelf)),
  );
}

Future<void> addDownloadMusicPackToLibrary(
  BuildContext context,
  WidgetRef ref,
  SHODownloadTask task,
) async {
  if (task.status != SHODownloadStatus.completed) return;
  final packService = ref.read(musicPackServiceProvider);
  if (!packService.isMusicPackZip(task)) return;

  final l10n = AppLocalizations.of(context);
  if (await isMusicPackInLibrary(ref, task.id)) return;

  final hasCache = await packService.hasCachedSongsForPack(task);

  if (!hasCache) {
    await _runMusicPackExtract(ref, task, l10n, () async {
      final result = await ensurePackInLibrary(
        ref,
        packTask: task,
        packService: packService,
      );
      return result.extractedPaths;
    });
  } else {
    await ensurePackInLibrary(
      ref,
      packTask: task,
      packService: packService,
    );
  }

  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(l10n.downloadAddedToMusicLibrary)),
  );
}

Future<void> _runMusicPackLoading(
  WidgetRef ref,
  String message,
  Future<void> Function() task,
) async {
  ref.read(overlayLoadingMessageProvider.notifier).state = message;
  try {
    await ref.read(overlayLoadingProvider.notifier).run(task);
  } finally {
    ref.read(overlayLoadingMessageProvider.notifier).state = null;
  }
}
