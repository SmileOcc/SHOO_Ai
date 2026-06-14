import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../domain/hos_bookshelf_entry.dart';
import '../domain/hos_download_task.dart';
import '../domain/hos_download_preview_support.dart';
import '../domain/hos_txt_novel_parser.dart';
import 'hos_bookshelf_storage.dart';
import 'hos_download_paths.dart';

const _bookAssetPrefix = 'assets/book/';
const _videoAssetPrefix = 'assets/video/';
const _bundledUrlPrefix = bundledDownloadUrlPrefix;

const _bookExtensions = {'.txt', '.pdf'};
const _videoExtensions = {
  '.mp4',
  '.mov',
  '.avi',
  '.mkv',
  '.webm',
};

final bundledLibraryServiceProvider = Provider<SHOBundledLibraryService>((ref) {
  return SHOBundledLibraryService(ref.watch(bookshelfStorageProvider));
});

class SHOBundledImportResult {
  const SHOBundledImportResult({
    required this.tasks,
    required this.addedBookTaskIds,
  });

  final List<SHODownloadTask> tasks;
  final List<String> addedBookTaskIds;
}

/// 将 `assets/book`、`assets/video` 内置资源复制到本地下载目录并注册任务。
class SHOBundledLibraryService {
  SHOBundledLibraryService(this._bookshelfStorage);

  final SHOBookshelfStorage _bookshelfStorage;

  Future<SHOBundledImportResult> importAll({
    required List<SHODownloadTask> existing,
  }) async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest.listAssets()..sort();

    var tasks = [...existing];
    final addedBookTaskIds = <String>[];

    for (final assetPath in assets) {
      if (assetPath.startsWith(_bookAssetPrefix)) {
        final task = await _importAsset(
          assetPath: assetPath,
          tasks: tasks,
          allowedExtensions: _bookExtensions,
        );
        if (task == null) continue;
        tasks = _upsertTask(tasks, task);
        final fileName = task.fileName;
        if (_isBookshelfAsset(assetPath) &&
            isBookshelfReadableFile(fileName)) {
          if (isTxtNovelFile(fileName)) {
            final readable = await isLocalTxtReadable(File(task.localPath));
            if (!readable) continue;
          }
          final added = await _ensureBookshelf(task.id);
          if (added) addedBookTaskIds.add(task.id);
        }
        continue;
      }

      if (assetPath.startsWith(_videoAssetPrefix)) {
        final task = await _importAsset(
          assetPath: assetPath,
          tasks: tasks,
          allowedExtensions: _videoExtensions,
        );
        if (task == null) continue;
        tasks = _upsertTask(tasks, task);
      }
    }

    return SHOBundledImportResult(
      tasks: tasks,
      addedBookTaskIds: addedBookTaskIds,
    );
  }

  bool _isBookshelfAsset(String assetPath) {
    final ext = p.extension(assetPath).toLowerCase();
    return _bookExtensions.contains(ext);
  }

  List<SHODownloadTask> _upsertTask(
    List<SHODownloadTask> tasks,
    SHODownloadTask task,
  ) {
    final index = tasks.indexWhere((item) => item.id == task.id);
    if (index < 0) return [...tasks, task];
    final next = [...tasks];
    next[index] = task;
    return next;
  }

  Future<SHODownloadTask?> _importAsset({
    required String assetPath,
    required List<SHODownloadTask> tasks,
    required Set<String> allowedExtensions,
  }) async {
    if (assetPath.endsWith('/')) return null;

    final ext = p.extension(assetPath).toLowerCase();
    if (!allowedExtensions.contains(ext)) return null;

    final fileName = p.basename(assetPath);
    final bundledUrl = '$_bundledUrlPrefix$assetPath';
    final taskId = _taskIdFor(assetPath);

    final existing = _findExistingTask(
      tasks: tasks,
      taskId: taskId,
      bundledUrl: bundledUrl,
      fileName: fileName,
    );

    final localPath = await SHODownloadPaths.filePathFor(fileName);
    await _copyAssetIfNeeded(assetPath: assetPath, localPath: localPath);

    final file = File(localPath);
    if (!await file.exists()) return existing;

    final bytes = await file.length();
    final createdAt = existing?.createdAt ?? DateTime.now();

    return SHODownloadTask(
      id: existing?.id ?? taskId,
      url: bundledUrl,
      fileName: fileName,
      fileType: detectDownloadFileType(fileName),
      status: SHODownloadStatus.completed,
      downloadedBytes: bytes,
      totalBytes: bytes,
      createdAt: createdAt,
      localPath: localPath,
    );
  }

  Future<void> _copyAssetIfNeeded({
    required String assetPath,
    required String localPath,
  }) async {
    final file = File(localPath);
    final bundleBytes = (await rootBundle.load(assetPath)).buffer.asUint8List();

    if (await file.exists()) {
      final existingLen = await file.length();
      if (existingLen == bundleBytes.length) return;
    }

    await file.parent.create(recursive: true);
    await file.writeAsBytes(bundleBytes, flush: true);
  }

  Future<bool> _ensureBookshelf(String taskId) async {
    final entries = _bookshelfStorage.read();
    if (entries.any((entry) => entry.taskId == taskId)) return false;
    await _bookshelfStorage.write([
      SHOBookshelfEntry(taskId: taskId, addedAt: DateTime.now()),
      ...entries,
    ]);
    return true;
  }

  SHODownloadTask? _findExistingTask({
    required List<SHODownloadTask> tasks,
    required String taskId,
    required String bundledUrl,
    required String fileName,
  }) {
    for (final task in tasks) {
      if (task.id == taskId) return task;
      if (task.url == bundledUrl) return task;
      if (task.fileName == fileName && task.url.startsWith(_bundledUrlPrefix)) {
        return task;
      }
    }
    return null;
  }

  String _taskIdFor(String assetPath) {
    return 'bundle_${assetPath.replaceAll('/', '_')}';
  }
}
