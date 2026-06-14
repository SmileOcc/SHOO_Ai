import 'dart:io';
import 'dart:math' as math;

import 'hos_download_task.dart';
import 'hos_txt_novel_parser.dart';
import '../data/hos_download_paths.dart';

/// 打开前预检结果。
class SHODownloadPreviewAssessment {
  const SHODownloadPreviewAssessment._({
    required this.canOpen,
    this.dialogTitle,
    this.dialogMessage,
  });

  final bool canOpen;
  final String? dialogTitle;
  final String? dialogMessage;

  factory SHODownloadPreviewAssessment.ok() =>
      const SHODownloadPreviewAssessment._(canOpen: true);

  factory SHODownloadPreviewAssessment.blocked({
    required String title,
    String? message,
  }) =>
      SHODownloadPreviewAssessment._(
        canOpen: false,
        dialogTitle: title,
        dialogMessage: message,
      );
}

/// 书库 / 下载项点击打开前的统一预检（避免不支持格式进入阅读器卡死）。
Future<SHODownloadPreviewAssessment> assessDownloadTaskPreview(
  SHODownloadTask task, {
  required String unsupportedTitle,
  required String notCompletedTitle,
  required String failedTitle,
  required String encodingUnsupportedTitle,
  String? encodingUnsupportedMessage,
}) async {
  if (task.status != SHODownloadStatus.completed) {
    return SHODownloadPreviewAssessment.blocked(title: notCompletedTitle);
  }

  final localPath = await SHODownloadPaths.resolveExistingFilePath(task);
  if (localPath == null) {
    return SHODownloadPreviewAssessment.blocked(title: failedTitle);
  }

  final file = File(localPath);
  if (!await file.exists()) {
    return SHODownloadPreviewAssessment.blocked(title: failedTitle);
  }

  if (isTxtNovelFile(task.fileName)) {
    final readable = await _isTxtReadable(file);
    if (!readable) {
      return SHODownloadPreviewAssessment.blocked(
        title: encodingUnsupportedTitle,
        message: encodingUnsupportedMessage,
      );
    }
    return SHODownloadPreviewAssessment.ok();
  }

  if (task.fileType == SHODownloadFileType.video ||
      previewKindForFileName(task.fileName) == SHODownloadPreviewKind.video) {
    final len = await file.length();
    if (len <= 0) {
      return SHODownloadPreviewAssessment.blocked(title: failedTitle);
    }
    return SHODownloadPreviewAssessment.ok();
  }

  final kind = previewKindForFileName(task.fileName);
  if (kind == null) {
    return SHODownloadPreviewAssessment.blocked(title: unsupportedTitle);
  }

  return switch (kind) {
    SHODownloadPreviewKind.pdf => await _assessPdf(file, failedTitle),
    SHODownloadPreviewKind.text => await _assessPlainText(
        file,
        failedTitle: failedTitle,
        encodingUnsupportedTitle: encodingUnsupportedTitle,
        encodingUnsupportedMessage: encodingUnsupportedMessage,
      ),
    SHODownloadPreviewKind.image => SHODownloadPreviewAssessment.ok(),
    SHODownloadPreviewKind.video => SHODownloadPreviewAssessment.ok(),
  };
}

Future<SHODownloadPreviewAssessment> _assessPdf(
  File file,
  String failedTitle,
) async {
  final len = await file.length();
  if (len < 5) {
    return SHODownloadPreviewAssessment.blocked(title: failedTitle);
  }
  final raf = await file.open();
  try {
    final header = await raf.read(5);
    final text = String.fromCharCodes(header);
    if (!text.startsWith('%PDF')) {
      return SHODownloadPreviewAssessment.blocked(title: failedTitle);
    }
  } finally {
    await raf.close();
  }
  return SHODownloadPreviewAssessment.ok();
}

Future<SHODownloadPreviewAssessment> _assessPlainText(
  File file, {
  required String failedTitle,
  required String encodingUnsupportedTitle,
  String? encodingUnsupportedMessage,
}) async {
  final readable = await _isTxtReadable(file);
  if (!readable) {
    return SHODownloadPreviewAssessment.blocked(
      title: encodingUnsupportedTitle,
      message: encodingUnsupportedMessage,
    );
  }
  return SHODownloadPreviewAssessment.ok();
}

Future<bool> _isTxtReadable(File file) async {
  final len = await file.length();
  if (len <= 0) return false;

  const maxSample = 128 * 1024;
  final sampleLen = math.min(maxSample, len);
  final raf = await file.open();
  try {
    final bytes = await raf.read(sampleLen);
    if (bytes.isEmpty) return false;
    final expectCjk = bytes.any((b) => b >= 0x80);
    final text = decodeTxtBytes(bytes);
    return text.trim().isNotEmpty &&
        !looksLikeGarbledText(text, expectCjk: expectCjk);
  } finally {
    await raf.close();
  }
}

Future<bool> isLocalTxtReadable(File file) => _isTxtReadable(file);

/// 是否属于书库可阅读格式（txt / pdf）。
bool isBookshelfReadableFile(String fileName) {
  if (isTxtNovelFile(fileName)) return true;
  return previewKindForFileName(fileName) == SHODownloadPreviewKind.pdf;
}
