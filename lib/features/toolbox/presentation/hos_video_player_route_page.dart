import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/hos_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../data/hos_download_paths.dart';
import '../domain/hos_download_task.dart';
import '../domain/hos_video_library_entry.dart';
import 'hos_download_controller.dart';
import 'hos_video_player_page.dart';
import 'video/hos_video_library_controller.dart';

class SHOVideoPlayerRoutePage extends ConsumerWidget {
  const SHOVideoPlayerRoutePage({
    super.key,
    this.entryId = '',
    this.taskId = '',
  });

  final String entryId;
  final String taskId;

  SHOVideoLibraryEntry? _findEntry(List<SHOVideoLibraryEntry> entries) {
    if (entryId.isNotEmpty) {
      for (final item in entries) {
        if (item.id == entryId) return item;
      }

      final parsedTaskId = SHOVideoLibraryEntry.taskIdFromEntryId(entryId);
      if (parsedTaskId != null) {
        for (final item in entries) {
          if (item.taskId == parsedTaskId) return item;
        }
      }
    }

    final lookupTaskId = taskId.isNotEmpty
        ? taskId
        : (entryId.isNotEmpty
            ? SHOVideoLibraryEntry.taskIdFromEntryId(entryId)
            : null);
    if (lookupTaskId != null) {
      for (final item in entries) {
        if (item.taskId == lookupTaskId) return item;
      }
    }

    return null;
  }

  SHODownloadTask? _findTask(List<SHODownloadTask> tasks, String? lookupTaskId) {
    if (lookupTaskId == null) return null;
    for (final item in tasks) {
      if (item.id == lookupTaskId) return item;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entries = ref.watch(videoLibraryEntriesProvider);
    final tasks = ref.watch(downloadTasksProvider);

    var entry = _findEntry(entries);

    final lookupTaskId = taskId.isNotEmpty
        ? taskId
        : (entryId.isNotEmpty
            ? SHOVideoLibraryEntry.taskIdFromEntryId(entryId)
            : entry?.taskId);

    final task = _findTask(tasks, lookupTaskId);

    if (entry == null && task != null && task.fileType == SHODownloadFileType.video) {
      entry = SHOVideoLibraryEntry.local(
        taskId: task.id,
        displayName: task.fileName,
      );
    }

    if (entry == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(SHOAppSpacing.xxxl),
            child: Text(
              l10n.txtReaderTaskMissing,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final resolvedTask =
        resolveDownloadTaskForEntry(entry, tasks) ?? task ?? _findTask(tasks, entry.taskId);

    if (entry.isNetwork) {
      if (resolvedTask != null &&
          resolvedTask.status == SHODownloadStatus.completed) {
        return _LocalVideoPlayerLoader(entry: entry, task: resolvedTask);
      }
      return SHOVideoPlayerPage(entry: entry);
    }

    if (resolvedTask == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(SHOAppSpacing.xxxl),
            child: Text(
              l10n.txtReaderTaskMissing,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return _LocalVideoPlayerLoader(entry: entry, task: resolvedTask);
  }
}

class _LocalVideoPlayerLoader extends StatefulWidget {
  const _LocalVideoPlayerLoader({
    required this.entry,
    required this.task,
  });

  final SHOVideoLibraryEntry entry;
  final SHODownloadTask task;

  @override
  State<_LocalVideoPlayerLoader> createState() => _LocalVideoPlayerLoaderState();
}

class _LocalVideoPlayerLoaderState extends State<_LocalVideoPlayerLoader> {
  late Future<String?> _pathFuture;

  @override
  void initState() {
    super.initState();
    _pathFuture = SHODownloadPaths.resolveExistingFilePath(widget.task);
  }

  @override
  void didUpdateWidget(covariant _LocalVideoPlayerLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.id != widget.task.id) {
      _pathFuture = SHODownloadPaths.resolveExistingFilePath(widget.task);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<String?>(
      future: _pathFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SHOVideoPlayerPage.loadingShell(title: l10n.videoLibraryTitle);
        }

        final path = snapshot.data;
        if (path == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(SHOAppSpacing.xxxl),
                child: Text(
                  l10n.videoLibraryFileMissing,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return SHOVideoPlayerPage(entry: widget.entry, filePath: path);
      },
    );
  }
}
