import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/hos_video_library_storage.dart';
import '../../data/hos_video_playback_storage.dart';
import '../../domain/hos_download_task.dart';
import '../../domain/hos_video_library_entry.dart';
import '../../domain/hos_video_playback_progress.dart';
import '../../domain/hos_video_url_utils.dart';
import '../hos_download_controller.dart';

class SHOVideoLibraryListItem {
  const SHOVideoLibraryListItem({
    required this.entry,
    required this.task,
    required this.progress,
    required this.cacheBytes,
    required this.cacheTotalBytes,
  });

  final SHOVideoLibraryEntry entry;
  final SHODownloadTask? task;
  final SHOVideoPlaybackProgress? progress;
  final int cacheBytes;
  final int? cacheTotalBytes;

  double? get cachePercent {
    if (cacheTotalBytes == null || cacheTotalBytes! <= 0) return null;
    return (cacheBytes / cacheTotalBytes! * 100).clamp(0, 100);
  }

  bool get isFullyCached =>
      task != null && task!.status == SHODownloadStatus.completed;
}

SHODownloadTask? resolveDownloadTaskForEntry(
  SHOVideoLibraryEntry entry,
  List<SHODownloadTask> tasks,
) {
  if (entry.taskId != null) {
    for (final task in tasks) {
      if (task.id == entry.taskId) return task;
    }
  }

  if (entry.linkedDownloadTaskId != null) {
    for (final task in tasks) {
      if (task.id == entry.linkedDownloadTaskId) return task;
    }
  }

  final entryUrl = entry.url;
  if (entryUrl != null) {
    final normalized = normalizeVideoUrl(entryUrl);
    for (final task in tasks) {
      if (task.fileType != SHODownloadFileType.video) continue;
      if (normalizeVideoUrl(task.url) == normalized) return task;
    }
  }

  return null;
}

final videoLibraryEntriesProvider =
    NotifierProvider<SHOVideoLibraryNotifier, List<SHOVideoLibraryEntry>>(
  SHOVideoLibraryNotifier.new,
);

final videoPlaybackRevisionProvider = StateProvider<int>((ref) => 0);

final videoLibraryListItemsProvider =
    Provider<List<SHOVideoLibraryListItem>>((ref) {
  ref.watch(videoPlaybackRevisionProvider);
  final entries = ref.watch(videoLibraryEntriesProvider);
  final tasks = ref.watch(downloadTasksProvider);
  final progressStorage = ref.watch(videoPlaybackStorageProvider);

  final items = <SHOVideoLibraryListItem>[];
  for (final entry in entries) {
    final task = resolveDownloadTaskForEntry(entry, tasks);
    items.add(
      SHOVideoLibraryListItem(
        entry: entry,
        task: task,
        progress: progressStorage.read(entry.id),
        cacheBytes: task?.downloadedBytes ?? 0,
        cacheTotalBytes: task?.totalBytes,
      ),
    );
  }
  items.sort((a, b) => b.entry.addedAt.compareTo(a.entry.addedAt));
  return items;
});

class SHOVideoLibraryNotifier extends Notifier<List<SHOVideoLibraryEntry>> {
  late final SHOVideoLibraryStorage _storage;

  @override
  List<SHOVideoLibraryEntry> build() {
    _storage = ref.read(videoLibraryStorageProvider);
    final initialTasks = ref.read(downloadTasksProvider);
    ref.listen(downloadTasksProvider, (_, tasks) {
      unawaited(syncFromDownloads(tasks));
    });
    unawaited(syncFromDownloads(initialTasks));
    return _storage.readEntries();
  }

  Future<void> syncFromDownloads(List<SHODownloadTask> tasks) async {
    await syncLocalDownloads(tasks);
    await syncNetworkDownloadLinks(tasks);
  }

  bool _entryCoversTask(SHOVideoLibraryEntry entry, SHODownloadTask task) {
    if (entry.taskId == task.id) return true;
    if (entry.linkedDownloadTaskId == task.id) return true;
    final entryUrl = entry.url;
    if (entry.isNetwork &&
        entryUrl != null &&
        normalizeVideoUrl(entryUrl) == normalizeVideoUrl(task.url)) {
      return true;
    }
    return false;
  }

  Future<void> syncNetworkDownloadLinks(List<SHODownloadTask> tasks) async {
    var changed = false;
    final next = [...state];

    for (var i = 0; i < next.length; i++) {
      final entry = next[i];
      if (!entry.isNetwork || entry.linkedDownloadTaskId != null) continue;

      final entryUrl = entry.url;
      if (entryUrl == null) continue;

      final normalized = normalizeVideoUrl(entryUrl);
      SHODownloadTask? matched;
      for (final task in tasks) {
        if (task.fileType != SHODownloadFileType.video) continue;
        if (normalizeVideoUrl(task.url) == normalized) {
          matched = task;
          break;
        }
      }

      if (matched == null) continue;
      next[i] = entry.copyWith(linkedDownloadTaskId: matched.id);
      changed = true;
    }

    if (!changed) return;
    await _storage.writeEntries(next);
    state = next;
  }

  Future<void> syncLocalDownloads(List<SHODownloadTask> tasks) async {
    final dismissed = _storage.readDismissedLocalTaskIds();

    var changed = false;
    final next = [...state];

    for (final task in tasks) {
      if (task.fileType != SHODownloadFileType.video) continue;
      if (dismissed.contains(task.id)) continue;
      if (next.any((entry) => _entryCoversTask(entry, task))) continue;

      final lower = task.fileName.toLowerCase();
      final displayName = lower.endsWith('.txt')
          ? task.fileName
          : lower.endsWith('.mp4') ||
                  lower.endsWith('.mov') ||
                  lower.endsWith('.mkv') ||
                  lower.endsWith('.webm') ||
                  lower.endsWith('.avi')
              ? _stripVideoExtension(task.fileName)
              : task.fileName;

      next.add(
        SHOVideoLibraryEntry.local(
          taskId: task.id,
          displayName: displayName,
        ),
      );
      changed = true;
    }

    if (!changed) return;
    await _storage.writeEntries(next);
    state = next;
  }

  String _stripVideoExtension(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot <= 0) return fileName;
    return fileName.substring(0, dot);
  }

  SHOVideoLibraryEntry? findById(String id) {
    for (final entry in state) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  Future<SHOVideoLibraryEntry?> addNetwork(String url) async {
    final trimmed = url.trim();
    if (!isLikelyPlayableVideoUrl(trimmed)) return null;

    final existing = state.where((entry) => entry.url == trimmed);
    if (existing.isNotEmpty) return existing.first;

    final entry = SHOVideoLibraryEntry.network(
      url: trimmed,
      displayName: inferVideoTitleFromUrl(trimmed),
    );
    state = [entry, ...state];
    await _storage.writeEntries(state);
    return entry;
  }

  Future<void> remove(String entryId) async {
    final entry = findById(entryId);
    if (entry == null) return;

    if (entry.taskId != null) {
      final dismissed = _storage.readDismissedLocalTaskIds()
        ..add(entry.taskId!);
      await _storage.writeDismissedLocalTaskIds(dismissed);
    }

    state = [
      for (final item in state)
        if (item.id != entryId) item,
    ];
    await _storage.writeEntries(state);
  }

  Future<void> linkDownloadTask({
    required String entryId,
    required String taskId,
  }) async {
    state = [
      for (final entry in state)
        if (entry.id == entryId)
          entry.copyWith(linkedDownloadTaskId: taskId)
        else
          entry,
    ];
    await _storage.writeEntries(state);
  }
}
