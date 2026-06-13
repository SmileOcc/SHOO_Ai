import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/hos_bookshelf_storage.dart';
import '../domain/hos_bookshelf_entry.dart';
import '../domain/hos_download_task.dart';
import 'hos_download_controller.dart';

final bookshelfEntriesProvider =
    NotifierProvider<SHOBookshelfNotifier, List<SHOBookshelfEntry>>(
  SHOBookshelfNotifier.new,
);

class SHOBookshelfListItem {
  const SHOBookshelfListItem({
    required this.entry,
    required this.task,
  });

  final SHOBookshelfEntry entry;
  final SHODownloadTask? task;
}

final bookshelfListItemsProvider = Provider<List<SHOBookshelfListItem>>((ref) {
  final entries = ref.watch(bookshelfEntriesProvider);
  final downloads = ref.watch(downloadTasksProvider);
  final byId = {for (final task in downloads) task.id: task};
  return [
    for (final entry in entries)
      SHOBookshelfListItem(entry: entry, task: byId[entry.taskId]),
  ];
});

class SHOBookshelfNotifier extends Notifier<List<SHOBookshelfEntry>> {
  late final SHOBookshelfStorage _storage;

  @override
  List<SHOBookshelfEntry> build() {
    _storage = ref.read(bookshelfStorageProvider);
    return _storage.read();
  }

  bool contains(String taskId) {
    return state.any((entry) => entry.taskId == taskId);
  }

  Future<void> add(String taskId) async {
    if (contains(taskId)) return;
    state = [
      SHOBookshelfEntry(taskId: taskId, addedAt: DateTime.now()),
      ...state,
    ];
    await _storage.write(state);
  }

  Future<void> remove(String taskId) async {
    state = [
      for (final entry in state)
        if (entry.taskId != taskId) entry,
    ];
    await _storage.write(state);
  }

  Future<int> removeOrphans(Set<String> validTaskIds) async {
    final before = state.length;
    state = [
      for (final entry in state)
        if (validTaskIds.contains(entry.taskId)) entry,
    ];
    if (state.length == before) return 0;
    await _storage.write(state);
    return before - state.length;
  }
}
