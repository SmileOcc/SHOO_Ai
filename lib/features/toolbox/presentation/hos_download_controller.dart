import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/hos_bookshelf_storage.dart';
import '../data/hos_bundled_library_service.dart';
import '../data/hos_download_engine.dart';
import '../data/hos_download_paths.dart';
import '../data/hos_download_storage.dart';
import '../data/hos_txt_reader_progress_storage.dart';
import '../domain/hos_download_task.dart';
import 'hos_bookshelf_controller.dart';

final downloadTasksProvider =
    NotifierProvider<SHODownloadTasksNotifier, List<SHODownloadTask>>(
  SHODownloadTasksNotifier.new,
);

/// 用户主动下载的任务（排除内置 book/video）。
final userDownloadTasksProvider = Provider<List<SHODownloadTask>>((ref) {
  final tasks = ref.watch(downloadTasksProvider);
  return [
    for (final task in tasks)
      if (!isBundledDownloadTask(task)) task,
  ];
});

class SHODownloadTasksNotifier extends Notifier<List<SHODownloadTask>> {
  late final SHODownloadStorage _storage;
  late final SHOBookshelfStorage _bookshelfStorage;
  late final SHOTxtReaderProgressStorage _progressStorage;
  SHODownloadEngine? _engine;
  var _ready = false;

  @override
  List<SHODownloadTask> build() {
    _storage = ref.read(downloadStorageProvider);
    _bookshelfStorage = ref.read(bookshelfStorageProvider);
    _progressStorage = ref.read(txtReaderProgressStorageProvider);
    ref.onDispose(() => _engine?.dispose());
    unawaited(_bootstrap());
    return const [];
  }

  SHODownloadEngine get engine {
    return _engine ??= SHODownloadEngine(
      resolveTask: (id) {
        for (final task in state) {
          if (task.id == id) return task;
        }
        return null;
      },
      updateTask: _updateTask,
    );
  }

  Future<void> _bootstrap() async {
    final saved = _storage.read();
    final normalized = <SHODownloadTask>[];
    for (final task in saved) {
      normalized.add(await SHODownloadPaths.reconcileTask(task));
    }

    final importResult = await ref
        .read(bundledLibraryServiceProvider)
        .importAll(existing: normalized);

    state = importResult.tasks;
    await _storage.write(state);
    if (importResult.addedBookTaskIds.isNotEmpty) {
      ref.invalidate(bookshelfEntriesProvider);
    }
    _ready = true;
  }

  Future<void> _persist() => _storage.write(state);

  Future<void> _updateTask(SHODownloadTask task) async {
    state = [
      for (final item in state)
        if (item.id == task.id) task else item,
    ];
    await _persist();
  }

  SHODownloadTask? taskById(String id) {
    for (final task in state) {
      if (task.id == id) return task;
    }
    return null;
  }

  List<SHODownloadTask> tasksForTab(SHODownloadListTab tab) {
    final visible = [
      for (final task in state)
        if (!isBundledDownloadTask(task)) task,
    ];
    return switch (tab) {
      SHODownloadListTab.all => visible,
      SHODownloadListTab.downloading => visible
          .where((t) => t.status == SHODownloadStatus.downloading)
          .toList(),
      SHODownloadListTab.paused =>
        visible.where((t) => t.status == SHODownloadStatus.paused).toList(),
      SHODownloadListTab.completed => visible
          .where((t) => t.status == SHODownloadStatus.completed)
          .toList(),
    };
  }

  Future<void> addTask({
    required String url,
    String? fileName,
    bool priority = false,
  }) async {
    if (!_ready) await _bootstrap();

    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty) return;

    final name = inferDownloadFileName(url: trimmedUrl, custom: fileName);
    final localPath = await SHODownloadPaths.filePathFor(name);
    final id = 'dl_${DateTime.now().millisecondsSinceEpoch}';

    var downloadedBytes = 0;
    final existing = File(localPath);
    if (await existing.exists()) {
      downloadedBytes = await existing.length();
    }

    final task = SHODownloadTask(
      id: id,
      url: trimmedUrl,
      fileName: name,
      fileType: detectDownloadFileType(name),
      status: SHODownloadStatus.downloading,
      downloadedBytes: downloadedBytes,
      totalBytes: null,
      priority: priority,
      createdAt: DateTime.now(),
      localPath: localPath,
    );

    state = [...state, task];
    await _persist();
    engine.enqueue(id, front: priority);
  }

  Future<void> addTasks({
    required List<String> urls,
    bool priority = false,
  }) async {
    for (final url in urls) {
      await addTask(url: url, priority: priority);
    }
  }

  Future<void> pauseTask(String id) => engine.pause(id);

  Future<void> resumeTask(String id) => engine.resume(id);

  Future<void> deleteTask(String id) async {
    final task = taskById(id);
    if (task != null && isBundledDownloadTask(task)) return;
    await engine.pause(id);
    state = state.where((item) => item.id != id).toList();
    await _persist();
    await _bookshelfStorage.removeByTaskId(id);
    await _progressStorage.remove(id);
    if (task != null) {
      final path = await SHODownloadPaths.resolveExistingFilePath(task);
      if (path != null) {
        try {
          await File(path).delete();
        } catch (_) {}
      }
    }
  }
}

enum SHODownloadListTab {
  all,
  downloading,
  paused,
  completed,
}
