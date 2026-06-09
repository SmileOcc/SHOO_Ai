import 'package:flutter/material.dart';

import '../../../core/dialogs/hos_confirm_card_dialog.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/hos_download_task.dart';
import '../domain/hos_txt_novel_parser.dart';
import 'hos_download_preview_page.dart';
import 'hos_txt_reader_page.dart';

Future<void> handleDownloadTaskTap(
  BuildContext context,
  SHODownloadTask task,
) async {
  final l10n = AppLocalizations.of(context);
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

  final opened = await SHODownloadPreviewPage.open(context: context, task: task);
  if (!opened && context.mounted) {
    await SHOConfirmCardDialog.show(
      context,
      title: l10n.downloadPreviewFailed,
      confirmLabel: l10n.downloadPreviewOk,
    );
  }
}
