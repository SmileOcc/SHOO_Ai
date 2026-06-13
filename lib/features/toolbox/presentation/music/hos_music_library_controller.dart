import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/storage/hos_local_storage.dart';
import '../../data/hos_download_paths.dart';
import '../../data/hos_music_cache_paths.dart';
import '../../data/hos_music_bundle_service.dart';
import '../../data/hos_music_catalog.dart';
import '../../data/hos_music_pack_added_storage.dart';
import '../../data/hos_music_pack_service.dart';
import '../../data/hos_music_playback_storage.dart';
import '../../data/hos_music_stats_storage.dart';
import '../../data/hos_music_storage_keys.dart';
import '../../domain/hos_download_task.dart';
import '../../domain/hos_music_color_utils.dart';
import '../../domain/hos_music_song_key.dart';
import '../../domain/hos_music_track.dart';
import '../../domain/hos_music_track_stats.dart';
import '../hos_download_controller.dart';

enum SHOMusicLibrarySort {
  recent,
  liked,
}

class SHOMusicLibraryListItem {
  const SHOMusicLibraryListItem({
    required this.track,
    required this.lastPosition,
    required this.stats,
    required this.isOnline,
    required this.isLocalCached,
    required this.canDeleteCache,
  });

  final SHOMusicTrack track;
  final Duration? lastPosition;
  final SHOMusicTrackStats stats;
  final bool isOnline;
  final bool isLocalCached;
  final bool canDeleteCache;
}

final musicLibrarySortProvider =
    StateProvider<SHOMusicLibrarySort>((ref) => SHOMusicLibrarySort.recent);

final musicLibraryRevisionProvider = StateProvider<int>((ref) => 0);

final musicLibraryListProvider =
    FutureProvider<List<SHOMusicLibraryListItem>>((ref) async {
  ref.watch(musicLibraryRevisionProvider);
  final sort = ref.watch(musicLibrarySortProvider);
  final tasks = ref.watch(downloadTasksProvider);
  final progressStorage = ref.watch(musicPlaybackStorageProvider);
  final statsStorage = ref.watch(musicStatsStorageProvider);
  final dismissed = ref.watch(musicDismissedTasksProvider);
  final removedCached = ref.watch(musicRemovedCachedProvider);
  final dismissedTracks = ref.watch(musicDismissedTrackIdsProvider);
  final addedPackIds = ref.watch(musicPackAddedTasksProvider);
  final packService = ref.watch(musicPackServiceProvider);
  final bundleService = ref.watch(musicBundleServiceProvider);

  final items = <SHOMusicLibraryListItem>[];
  final seenSongKeys = <String>{};

  final bundledTracks = await bundleService.loadBundledTracks(
    dismissedTrackIds: dismissedTracks,
    seenSongKeys: seenSongKeys,
  );
  for (final track in bundledTracks) {
    items.add(
      SHOMusicLibraryListItem(
        track: track,
        lastPosition: progressStorage.readPosition(track.id),
        stats: statsStorage.read(track.id),
        isOnline: false,
        isLocalCached: true,
        canDeleteCache: true,
      ),
    );
  }

  for (final packTaskId in addedPackIds) {
    SHODownloadTask? packTask;
    for (final task in tasks) {
      if (task.id == packTaskId) {
        packTask = task;
        break;
      }
    }
    if (packTask == null ||
        !packService.isMusicPackZip(packTask) ||
        packTask.status != SHODownloadStatus.completed) {
      continue;
    }

    final zipPath =
        await SHODownloadPaths.resolveExistingFilePath(packTask);
    if (zipPath == null) continue;

    final songs = await packService.discoverSongsInPack(zipPath);
    for (final song in songs) {
      final trackId = SHOMusicTrack.packTrackId(packTaskId, song.songKey);
      if (dismissedTracks.contains(trackId)) continue;

      final assets = await packService.resolveSongAssets(
        title: song.displayTitle,
        downloadTasks: tasks,
        allowedPackTaskIds: {packTaskId},
      );
      if (!assets.hasAudio) continue;
      seenSongKeys.add(song.songKey);

      items.add(
        SHOMusicLibraryListItem(
          track: SHOMusicTrack(
            id: trackId,
            title: song.displayTitle,
            artist: '本地音乐',
            songKey: song.songKey,
            source: SHOMusicSource.cached,
            localPath: assets.audioPath,
            coverPath: assets.coverPath,
            bgPath: assets.bgPath,
            lrc: assets.lyricsText,
            coverColor: SHOMusicColorUtils.colorForKey(song.songKey, salt: 11),
            bgColor: SHOMusicColorUtils.colorForKey(song.songKey, salt: 29),
            packTaskId: packTaskId,
            isCachedLocally: true,
          ),
          lastPosition: progressStorage.readPosition(trackId),
          stats: statsStorage.read(trackId),
          isOnline: false,
          isLocalCached: true,
          canDeleteCache: true,
        ),
      );
    }
  }

  if (bundledTracks.isEmpty && addedPackIds.isEmpty) {
    for (final track in SHOMusicCatalog.demoTracks) {
      if (dismissedTracks.contains(track.id)) continue;
      final songKey = SHOMusicSongKey.fromTitle(track.title);
      final assets = await packService.readCachedAssets(track.title);
      if (assets.isCached && assets.hasAudio) {
        items.add(
          SHOMusicLibraryListItem(
            track: track.copyWith(
              songKey: songKey,
              source: SHOMusicSource.cached,
              localPath: assets.audioPath,
              coverPath: assets.coverPath,
              bgPath: assets.bgPath,
              lrc: assets.lyricsText ?? track.lrc,
              coverColor: SHOMusicColorUtils.colorForKey(songKey, salt: 11),
              bgColor: SHOMusicColorUtils.colorForKey(songKey, salt: 29),
              packTaskId: assets.packTaskId,
              isCachedLocally: true,
            ),
            lastPosition: progressStorage.readPosition(track.id),
            stats: statsStorage.read(track.id),
            isOnline: false,
            isLocalCached: true,
            canDeleteCache: true,
          ),
        );
      } else {
        items.add(_onlineCatalogItem(track, progressStorage, statsStorage));
      }
    }
  }

  if (bundledTracks.isEmpty && addedPackIds.isEmpty) {
    for (final task in tasks) {
      if (task.fileType != SHODownloadFileType.audio) continue;
      if (task.status != SHODownloadStatus.completed) continue;
      if (dismissed.contains(task.id)) continue;

      final songKey = SHOMusicSongKey.fromTitle(task.fileName);
      if (seenSongKeys.contains(songKey)) continue;
      seenSongKeys.add(songKey);

      final track = SHOMusicTrack.local(
        taskId: task.id,
        title: _displayNameFromFileName(task.fileName),
        artist: '本地音乐',
        localPath: task.localPath,
      );
      items.add(
        SHOMusicLibraryListItem(
          track: track,
          lastPosition: progressStorage.readPosition(track.id),
          stats: statsStorage.read(track.id),
          isOnline: false,
          isLocalCached: true,
          canDeleteCache: false,
        ),
      );
    }

    final cachedKeys = await SHOMusicCachePaths.listCachedSongKeys();
    for (final songKey in cachedKeys) {
      if (removedCached.contains(songKey)) continue;
      final cachedTrackId = SHOMusicTrack.cachedTrackId(songKey);
      if (dismissedTracks.contains(cachedTrackId)) continue;
      if (seenSongKeys.contains(songKey)) continue;
      seenSongKeys.add(songKey);

      final audio = await SHOMusicCachePaths.audioPath(songKey);
      final cover = await SHOMusicCachePaths.coverPath(songKey);
      final bg = await SHOMusicCachePaths.bgPath(songKey);
      final lyricsFile = await SHOMusicCachePaths.lyricsPath(songKey);
      String? lyricsText;
      if (lyricsFile != null) {
        lyricsText = await File(lyricsFile).readAsString();
      }

      final track = SHOMusicTrack(
        id: SHOMusicTrack.cachedTrackId(songKey),
        title: songKey,
        artist: '本地音乐',
        songKey: songKey,
        source: SHOMusicSource.cached,
        localPath: audio,
        coverPath: cover,
        bgPath: bg,
        lrc: lyricsText,
        coverColor: SHOMusicColorUtils.colorForKey(songKey, salt: 11),
        bgColor: SHOMusicColorUtils.colorForKey(songKey, salt: 29),
        isCachedLocally: true,
      );
      items.add(
        SHOMusicLibraryListItem(
          track: track,
          lastPosition: progressStorage.readPosition(track.id),
          stats: statsStorage.read(track.id),
          isOnline: false,
          isLocalCached: true,
          canDeleteCache: true,
        ),
      );
    }
  }

  final deduped = <String, SHOMusicLibraryListItem>{};
  for (final item in items) {
    final key = SHOMusicSongKey.normalize(item.track.resolvedSongKey);
    final existing = deduped[key];
    if (existing == null) {
      deduped[key] = item;
      continue;
    }
    final preferNew = (item.track.id.startsWith(SHOMusicTrack.packIdPrefix) ||
            item.track.id.startsWith(SHOMusicTrack.bundleIdPrefix)) &&
        !existing.track.id.startsWith(SHOMusicTrack.packIdPrefix) &&
        !existing.track.id.startsWith(SHOMusicTrack.bundleIdPrefix);
    if (preferNew) deduped[key] = item;
  }

  final result = deduped.values.toList();
  result.sort((a, b) => _compareItems(a, b, sort));
  return result;
});

SHOMusicLibraryListItem _onlineCatalogItem(
  SHOMusicTrack track,
  SHOMusicPlaybackStorage progressStorage,
  SHOMusicStatsStorage statsStorage,
) {
  return SHOMusicLibraryListItem(
    track: track.copyWith(
      songKey: SHOMusicSongKey.fromTitle(track.title),
      coverColor: SHOMusicColorUtils.colorForKey(track.title, salt: 11),
      bgColor: SHOMusicColorUtils.colorForKey(track.title, salt: 29),
    ),
    lastPosition: progressStorage.readPosition(track.id),
    stats: statsStorage.read(track.id),
    isOnline: true,
    isLocalCached: false,
    canDeleteCache: false,
  );
}

int _compareItems(
  SHOMusicLibraryListItem a,
  SHOMusicLibraryListItem b,
  SHOMusicLibrarySort sort,
) {
  return switch (sort) {
    SHOMusicLibrarySort.recent => _compareDate(
        a.stats.lastPlayedAt,
        b.stats.lastPlayedAt,
      ),
    SHOMusicLibrarySort.liked => _compareLiked(a, b),
  };
}

int _compareLiked(SHOMusicLibraryListItem a, SHOMusicLibraryListItem b) {
  if (a.stats.liked != b.stats.liked) {
    return a.stats.liked ? -1 : 1;
  }
  return b.stats.playCount.compareTo(a.stats.playCount);
}

int _compareDate(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return b.compareTo(a);
}

final musicDismissedTasksProvider =
    NotifierProvider<SHOMusicDismissedTasksNotifier, Set<String>>(
  SHOMusicDismissedTasksNotifier.new,
);

final musicRemovedCachedProvider =
    NotifierProvider<SHOMusicRemovedCachedNotifier, Set<String>>(
  SHOMusicRemovedCachedNotifier.new,
);

final musicDismissedTrackIdsProvider =
    NotifierProvider<SHOMusicDismissedTrackIdsNotifier, Set<String>>(
  SHOMusicDismissedTrackIdsNotifier.new,
);

class SHOMusicDismissedTrackIdsNotifier extends Notifier<Set<String>> {
  late final SharedPreferences _prefs;

  @override
  Set<String> build() {
    _prefs = ref.read(sharedPreferencesProvider);
    final raw = _prefs.getStringList(SHOMusicStorageKeys.dismissedTrackIds);
    return raw?.toSet() ?? {};
  }

  Future<void> dismiss(String trackId) async {
    if (state.contains(trackId)) return;
    final next = {...state, trackId};
    state = next;
    await _prefs.setStringList(
      SHOMusicStorageKeys.dismissedTrackIds,
      next.toList(),
    );
  }

  Future<void> undismiss(String trackId) async {
    if (!state.contains(trackId)) return;
    final next = {...state}..remove(trackId);
    state = next;
    await _prefs.setStringList(
      SHOMusicStorageKeys.dismissedTrackIds,
      next.toList(),
    );
  }

  Future<void> undismissPackTracks(String packTaskId) async {
    final prefix = '${SHOMusicTrack.packIdPrefix}$packTaskId}_';
    final targets = state.where((id) => id.startsWith(prefix)).toList();
    if (targets.isEmpty) return;
    final next = {...state};
    for (final id in targets) {
      next.remove(id);
    }
    state = next;
    await _prefs.setStringList(
      SHOMusicStorageKeys.dismissedTrackIds,
      next.toList(),
    );
  }
}

class SHOMusicDismissedTasksNotifier extends Notifier<Set<String>> {
  late final SharedPreferences _prefs;

  @override
  Set<String> build() {
    _prefs = ref.read(sharedPreferencesProvider);
    final raw = _prefs.getStringList(SHOMusicStorageKeys.dismissedLocalTasks);
    return raw?.toSet() ?? {};
  }

  Future<void> dismiss(String taskId) async {
    if (state.contains(taskId)) return;
    final next = {...state, taskId};
    state = next;
    await _prefs.setStringList(
      SHOMusicStorageKeys.dismissedLocalTasks,
      next.toList(),
    );
  }
}

class SHOMusicRemovedCachedNotifier extends Notifier<Set<String>> {
  late final SharedPreferences _prefs;

  @override
  Set<String> build() {
    _prefs = ref.read(sharedPreferencesProvider);
    final raw = _prefs.getStringList(SHOMusicStorageKeys.removedCachedSongs);
    return raw?.toSet() ?? {};
  }

  Future<void> remove(String songKey) async {
    if (state.contains(songKey)) return;
    final next = {...state, songKey};
    state = next;
    await _prefs.setStringList(
      SHOMusicStorageKeys.removedCachedSongs,
      next.toList(),
    );
  }

  Future<void> restore(String songKey) async {
    if (!state.contains(songKey)) return;
    final next = {...state}..remove(songKey);
    state = next;
    await _prefs.setStringList(
      SHOMusicStorageKeys.removedCachedSongs,
      next.toList(),
    );
  }
}

Future<void> deleteCachedSong(
  WidgetRef ref, {
  required String trackId,
  required String songKey,
  required bool isCatalogTrack,
}) async {
  await SHOMusicCachePaths.deleteSongCache(songKey);
  if (!isCatalogTrack) {
    await ref.read(musicRemovedCachedProvider.notifier).remove(songKey);
    await ref.read(musicPlaybackStorageProvider).remove(trackId);
    await ref.read(musicStatsStorageProvider).remove(trackId);
  }
  ref.read(musicLibraryRevisionProvider.notifier).state++;
}

Future<void> removeTrackFromLibrary(
  WidgetRef ref, {
  required SHOMusicLibraryListItem item,
}) async {
  final track = item.track;
  if (item.canDeleteCache) {
    await SHOMusicCachePaths.deleteSongCache(track.resolvedSongKey);
  }
  await ref.read(musicDismissedTrackIdsProvider.notifier).dismiss(track.id);
  await ref.read(musicPlaybackStorageProvider).remove(track.id);
  await ref.read(musicStatsStorageProvider).remove(track.id);
  ref.read(musicLibraryRevisionProvider.notifier).state++;
  await syncMusicPackAddedAfterRemove(ref, track.packTaskId);
}

Future<void> syncMusicPackAddedAfterRemove(
  WidgetRef ref,
  String? packTaskId,
) async {
  if (packTaskId == null || packTaskId.startsWith('bundle_')) return;
  ref.invalidate(musicLibraryListProvider);
  final items = await ref.read(musicLibraryListProvider.future);
  final hasPack = items.any((item) => item.track.packTaskId == packTaskId);
  if (!hasPack) {
    await ref.read(musicPackAddedTasksProvider.notifier).remove(packTaskId);
  }
}

Future<void> reconcileStaleMusicPackAddedTasks(WidgetRef ref) async {
  final addedIds = ref.read(musicPackAddedTasksProvider);
  if (addedIds.isEmpty) return;

  final items = await ref.read(musicLibraryListProvider.future);
  for (final packId in addedIds.toList()) {
    final hasVisible =
        musicPackItemsInLibrary(items, packId).isNotEmpty;
    if (!hasVisible) {
      await ref.read(musicPackAddedTasksProvider.notifier).remove(packId);
    }
  }
}

Future<({List<SHOMusicLibraryListItem> items, List<String> extractedPaths})>
    ensurePackInLibrary(
  WidgetRef ref, {
  required SHODownloadTask packTask,
  required SHOMusicPackService packService,
}) async {
  await ref.read(musicPackAddedTasksProvider.notifier).add(packTask.id);
  await restorePackForLibrary(
    ref,
    packTask: packTask,
    packService: packService,
  );
  final extractedPaths = await packService.importPackToLibrary(
    packTask: packTask,
    downloadTasks: ref.read(downloadTasksProvider),
  );
  ref.invalidate(musicLibraryListProvider);
  ref.read(musicLibraryRevisionProvider.notifier).state++;
  await ref.read(musicLibraryListProvider.future);
  await syncMusicPackAddedAfterRemove(ref, packTask.id);
  final syncedItems = await ref.read(musicLibraryListProvider.future);
  return (items: syncedItems, extractedPaths: extractedPaths);
}

Future<List<String>> ensurePackCached(
  WidgetRef ref, {
  required SHODownloadTask packTask,
  required SHOMusicPackService packService,
}) async {
  final extractedPaths = await packService.importPackToLibrary(
    packTask: packTask,
    downloadTasks: ref.read(downloadTasksProvider),
  );
  ref.invalidate(musicLibraryListProvider);
  ref.read(musicLibraryRevisionProvider.notifier).state++;
  return extractedPaths;
}

Future<void> restorePackForLibrary(
  WidgetRef ref, {
  required SHODownloadTask packTask,
  required SHOMusicPackService packService,
}) async {
  await ref
      .read(musicDismissedTrackIdsProvider.notifier)
      .undismissPackTracks(packTask.id);

  final zipPath = await SHODownloadPaths.resolveExistingFilePath(packTask);
  if (zipPath == null) return;

  final songs = await packService.discoverSongsInPack(zipPath);
  final dismissed = ref.read(musicDismissedTrackIdsProvider.notifier);
  final removedCached = ref.read(musicRemovedCachedProvider.notifier);
  for (final song in songs) {
    await dismissed.undismiss(SHOMusicTrack.cachedTrackId(song.songKey));
    await removedCached.restore(song.songKey);
  }
}

List<SHOMusicLibraryListItem> musicPackItemsInLibrary(
  List<SHOMusicLibraryListItem> items,
  String packTaskId,
) {
  return items.where((item) => item.track.packTaskId == packTaskId).toList();
}

Future<bool> isMusicTrackPlayable(SHOMusicTrack track) async {
  if (track.isOnlineSource) return true;

  final path = await resolveMusicLocalPath(track);
  return path != null && File(path).existsSync();
}

Future<String?> resolveMusicLocalPath(SHOMusicTrack track) async {
  if (track.localPath != null && File(track.localPath!).existsSync()) {
    return track.localPath;
  }

  if (track.source == SHOMusicSource.cached) {
    return SHOMusicCachePaths.audioPath(track.resolvedSongKey);
  }

  if (track.source != SHOMusicSource.local) return null;
  final taskId = track.taskId;
  if (taskId == null) return track.localPath;

  final task = SHODownloadTask(
    id: taskId,
    url: '',
    fileName: track.title,
    fileType: SHODownloadFileType.audio,
    status: SHODownloadStatus.completed,
    downloadedBytes: 0,
    createdAt: DateTime.now(),
    localPath: track.localPath ?? '',
  );
  return SHODownloadPaths.resolveExistingFilePath(task);
}

String _displayNameFromFileName(String fileName) {
  if (!fileName.contains('.')) return fileName;
  return fileName.substring(0, fileName.lastIndexOf('.'));
}
