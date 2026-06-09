import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/hos_download_task.dart';
import 'hos_download_controller.dart';

IconData downloadFileTypeIcon(SHODownloadFileType type) {
  return switch (type) {
    SHODownloadFileType.doc => Icons.description_outlined,
    SHODownloadFileType.pdf => Icons.picture_as_pdf_outlined,
    SHODownloadFileType.excel => Icons.table_chart_outlined,
    SHODownloadFileType.zip => Icons.folder_zip_outlined,
    SHODownloadFileType.video => Icons.videocam_outlined,
    SHODownloadFileType.other => Icons.insert_drive_file_outlined,
  };
}

String downloadFileTypeLabel(AppLocalizations l10n, SHODownloadFileType type) {
  return switch (type) {
    SHODownloadFileType.doc => l10n.downloadTypeDoc,
    SHODownloadFileType.pdf => l10n.downloadTypePdf,
    SHODownloadFileType.excel => l10n.downloadTypeExcel,
    SHODownloadFileType.zip => l10n.downloadTypeZip,
    SHODownloadFileType.video => l10n.downloadTypeVideo,
    SHODownloadFileType.other => l10n.downloadTypeOther,
  };
}

String downloadStatusLabel(AppLocalizations l10n, SHODownloadStatus status) {
  return switch (status) {
    SHODownloadStatus.downloading => l10n.downloadStatusDownloading,
    SHODownloadStatus.paused => l10n.downloadStatusPaused,
    SHODownloadStatus.completed => l10n.downloadStatusCompleted,
  };
}

extension SHODownloadListTabX on SHODownloadListTab {
  String label(AppLocalizations l10n) => switch (this) {
        SHODownloadListTab.all => l10n.downloadTabAll,
        SHODownloadListTab.downloading => l10n.downloadTabDownloading,
        SHODownloadListTab.paused => l10n.downloadTabPaused,
        SHODownloadListTab.completed => l10n.downloadTabCompleted,
      };
}
