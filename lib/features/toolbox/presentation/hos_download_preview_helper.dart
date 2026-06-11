import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/dialogs/hos_confirm_card_dialog.dart';
import '../../../core/feedback/hos_overlay_loading.dart';
import '../../../l10n/app_localizations.dart';
import '../data/hos_music_pack_added_storage.dart';
import '../domain/hos_download_task.dart';
import '../domain/hos_txt_novel_parser.dart';
import 'hos_download_preview_page.dart';
import 'hos_txt_reader_page.dart';
import 'hos_video_player_page.dart';
import '../data/hos_music_pack_service.dart';
import 'music/hos_music_library_controller.dart';

Future<void> handleDownloadTaskTap(
  BuildContext context,
  WidgetRef ref,
  SHODownloadTask task,
) async {
  final l10n = AppLocalizations.of(context);

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

    final added = ref.read(musicPackAddedTasksProvider).contains(task.id);
    if (!added) {
      final ok = await SHOConfirmCardDialog.show(
        context,
        title: l10n.musicPackAddToLibraryTitle,
        message: l10n.musicPackAddToLibraryMessage,
        confirmLabel: l10n.musicPackAddToLibraryConfirm,
      );
      if (!ok || !context.mounted) return;
      await ref.read(musicPackAddedTasksProvider.notifier).add(task.id);
      ref.read(musicLibraryRevisionProvider.notifier).state++;
      await _runMusicPackLoading(ref, l10n.musicPackImporting, () async {
        await ref.read(musicLibraryListProvider.future);
      });
      if (!context.mounted) return;
      context.push(SHOAppRoutes.profileMusicLibraryFromDownload());
      return;
    }

    List<SHOMusicLibraryListItem> items = [];
    await _runMusicPackLoading(ref, l10n.musicPackImporting, () async {
      items = await ref.read(musicLibraryListProvider.future);
    });
    if (!context.mounted) return;
    context.push(SHOAppRoutes.profileMusicLibraryFromDownload());
    if (!context.mounted) return;
    if (items.isEmpty) return;

    context.push(SHOAppRoutes.toolboxMusicPlayerFor(items.first.track.id));
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
