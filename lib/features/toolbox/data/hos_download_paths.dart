import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../domain/hos_download_task.dart';

/// 下载文件统一落在 Documents/shoo_downloads/{fileName}，避免持久化绝对路径失效。
abstract final class SHODownloadPaths {
  static const _folderName = 'shoo_downloads';

  static Future<String> downloadsDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/$_folderName');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return folder.path;
  }

  static Future<String> filePathFor(String fileName) async {
    final dir = await downloadsDirectory();
    return '$dir/$fileName';
  }

  static Future<String> resolveLocalPath(SHODownloadTask task) async {
    return filePathFor(task.fileName);
  }

  static Future<String?> resolveExistingFilePath(SHODownloadTask task) async {
    final canonical = await filePathFor(task.fileName);
    if (await File(canonical).exists()) return canonical;

    final legacy = task.localPath.trim();
    if (legacy.isNotEmpty && legacy != canonical && await File(legacy).exists()) {
      return legacy;
    }
    return null;
  }

  /// 启动时将旧路径文件迁移到 canonical 目录，并返回更新后的任务。
  static Future<SHODownloadTask> reconcileTask(SHODownloadTask task) async {
    final canonical = await filePathFor(task.fileName);
    final file = File(canonical);
    var next = task.copyWith(localPath: canonical);

    if (next.status == SHODownloadStatus.downloading) {
      next = next.copyWith(status: SHODownloadStatus.paused);
    }

    final legacyPath = task.localPath.trim();
    if (!await file.exists() &&
        legacyPath.isNotEmpty &&
        legacyPath != canonical) {
      final legacy = File(legacyPath);
      if (await legacy.exists()) {
        await file.parent.create(recursive: true);
        await legacy.copy(canonical);
      }
    }

    if (await file.exists()) {
      final len = await file.length();
      if (next.status == SHODownloadStatus.completed) {
        next = next.copyWith(
          downloadedBytes: len,
          totalBytes: () => next.totalBytes ?? len,
        );
      } else if (len > 0) {
        next = next.copyWith(downloadedBytes: len);
      }
    } else if (next.status == SHODownloadStatus.completed) {
      next = next.copyWith(
        status: SHODownloadStatus.paused,
        downloadedBytes: 0,
        totalBytes: () => null,
      );
    }

    return next;
  }
}
