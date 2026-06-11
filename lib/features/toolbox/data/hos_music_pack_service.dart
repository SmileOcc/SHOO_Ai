import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/hos_local_api_paths.dart';
import '../domain/hos_download_task.dart';
import '../domain/hos_music_song_assets.dart';
import '../domain/hos_music_song_key.dart';
import 'hos_download_paths.dart';
import 'hos_music_cache_paths.dart';

final musicPackServiceProvider = Provider<SHOMusicPackService>((ref) {
  return const SHOMusicPackService();
});

class SHOMusicPackService {
  const SHOMusicPackService();

  bool isMusicPackZip(SHODownloadTask task) {
    if (task.fileType != SHODownloadFileType.zip) return false;
    return SHOLocalApiPaths.isMusicUrl(task.url) ||
        task.fileName.toLowerCase().contains('music');
  }

  Future<SHOMusicSongAssets> readCachedAssets(String title) async {
    final songKey = SHOMusicSongKey.fromTitle(title);
    return _readCachedAssets(songKey);
  }

  Future<SHOMusicSongAssets> resolveSongAssets({
    required String title,
    required List<SHODownloadTask> downloadTasks,
    Set<String>? allowedPackTaskIds,
  }) async {
    final songKey = SHOMusicSongKey.fromTitle(title);
    final cached = await _readCachedAssets(songKey);
    if (cached.hasAudio && !cached.needsAssetExtraction) return cached;

    for (final task in downloadTasks) {
      if (!isMusicPackZip(task)) continue;
      if (allowedPackTaskIds != null && !allowedPackTaskIds.contains(task.id)) {
        continue;
      }
      if (task.status != SHODownloadStatus.completed) continue;

      final zipPath = await SHODownloadPaths.resolveExistingFilePath(task);
      if (zipPath == null) continue;

      final extracted = await _extractSongFromZip(
        zipPath: zipPath,
        songKey: songKey,
        title: title,
        packTaskId: task.id,
      );
      if (!extracted.hasAudio) continue;

      return _mergeAssets(cached, extracted);
    }

    return cached;
  }

  Future<SHOMusicSongAssets> cacheSongFromPack({
    required String title,
    required List<SHODownloadTask> downloadTasks,
  }) {
    return resolveSongAssets(title: title, downloadTasks: downloadTasks);
  }

  SHOMusicSongAssets _mergeAssets(
    SHOMusicSongAssets cached,
    SHOMusicSongAssets extracted,
  ) {
    return SHOMusicSongAssets(
      songKey: extracted.songKey,
      audioPath: extracted.audioPath ?? cached.audioPath,
      coverPath: extracted.coverPath ?? cached.coverPath,
      bgPath: extracted.bgPath ?? cached.bgPath,
      lyricsText: extracted.lyricsText ?? cached.lyricsText,
      isCached: (extracted.audioPath ?? cached.audioPath) != null,
      packTaskId: extracted.packTaskId ?? cached.packTaskId,
    );
  }

  Future<SHOMusicSongAssets> _readCachedAssets(String songKey) async {
    final audio = await SHOMusicCachePaths.audioPath(songKey);
    final cover = await SHOMusicCachePaths.coverPath(songKey);
    final bg = await SHOMusicCachePaths.bgPath(songKey);
    final lyricsFile = await SHOMusicCachePaths.lyricsPath(songKey);
    String? lyricsText;
    if (lyricsFile != null) {
      lyricsText = await File(lyricsFile).readAsString();
    }

    return SHOMusicSongAssets(
      songKey: songKey,
      audioPath: audio,
      coverPath: cover,
      bgPath: bg,
      lyricsText: lyricsText,
      isCached: audio != null,
    );
  }

  Future<SHOMusicSongAssets> _extractSongFromZip({
    required String zipPath,
    required String songKey,
    required String title,
    required String packTaskId,
  }) async {
    final bytes = await File(zipPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    String? audioSourceName;
    String? coverSourceName;
    String? bgSourceName;
    String? lyricsSourceName;

    for (final file in archive) {
      if (file.isFile != true) continue;
      final entryName = file.name.replaceAll('\\', '/');
      if (SHOMusicCachePaths.isIgnoredZipEntry(entryName)) continue;
      if (!_entryMatchesSong(entryName, songKey, title)) continue;

      final lower = entryName.toLowerCase();
      if (SHOMusicCachePaths.isAudioEntry(entryName) && audioSourceName == null) {
        audioSourceName = entryName;
      } else if (lower.contains('song_cover/') &&
          SHOMusicCachePaths.isImageEntry(entryName)) {
        coverSourceName ??= entryName;
      } else if (lower.contains('song_bg/') &&
          SHOMusicCachePaths.isImageEntry(entryName)) {
        bgSourceName ??= entryName;
      } else if (lower.contains('song_lyrics/') &&
          SHOMusicCachePaths.isLyricsEntry(entryName)) {
        lyricsSourceName ??= entryName;
      }
    }

    if (audioSourceName == null) {
      return SHOMusicSongAssets(songKey: songKey);
    }

    Future<String?> writeEntry(String? sourceName, String targetName) async {
      if (sourceName == null) return null;
      final entry = archive.findFile(sourceName);
      if (entry == null) return null;
      return SHOMusicCachePaths.writeBytes(
        songKey: songKey,
        fileName: targetName,
        bytes: entry.content,
      );
    }

    final audioPath = await writeEntry(
      audioSourceName,
      SHOMusicCachePaths.canonicalAudioName(audioSourceName),
    );
    final coverPath = await writeEntry(
      coverSourceName,
      SHOMusicCachePaths.canonicalCoverName(coverSourceName ?? 'cover.jpg'),
    );
    final bgPath = await writeEntry(
      bgSourceName,
      SHOMusicCachePaths.canonicalBgName(bgSourceName ?? 'bg.webp'),
    );
    final lyricsPath = await writeEntry(
      lyricsSourceName,
      SHOMusicCachePaths.canonicalLyricsName(lyricsSourceName ?? 'lyrics.lrc'),
    );

    String? lyricsText;
    if (lyricsPath != null) {
      lyricsText = await File(lyricsPath).readAsString();
      if (!_looksLikeLrc(lyricsText)) {
        lyricsText = _plainTextToLrc(lyricsText);
        await File(lyricsPath).writeAsString(lyricsText);
      }
    }

    return SHOMusicSongAssets(
      songKey: songKey,
      audioPath: audioPath,
      coverPath: coverPath,
      bgPath: bgPath,
      lyricsText: lyricsText,
      isCached: audioPath != null,
      packTaskId: packTaskId,
    );
  }

  bool _entryMatchesSong(String entryPath, String songKey, String title) {
    final entryKey = _entrySongKey(entryPath);
    if (entryKey != null && SHOMusicSongKey.matches(entryKey, songKey)) {
      return true;
    }

    final normalized = entryPath.replaceAll('\\', '/').toLowerCase();
    final keys = <String>{
      songKey.toLowerCase(),
      SHOMusicSongKey.fromTitle(title).toLowerCase(),
    };
    for (final key in keys) {
      if (key.isEmpty) continue;
      if (normalized.contains('/$key/') ||
          normalized.contains('/$key.') ||
          normalized.endsWith('/$key')) {
        return true;
      }
    }
    return false;
  }

  bool _isAssetFolderAudio(String entryPath) {
    final normalized = entryPath.replaceAll('\\', '/').toLowerCase();
    return normalized.contains('song_cover/') ||
        normalized.contains('song_bg/') ||
        normalized.contains('song_lyrics/');
  }

  String? _entrySongKey(String entryPath) {
    final normalized = entryPath.replaceAll('\\', '/');
    final segments = normalized.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return null;

    for (var i = 0; i < segments.length; i++) {
      final folder = segments[i].toLowerCase();
      if (folder == 'song_cover' ||
          folder == 'song_bg' ||
          folder == 'song_lyrics') {
        if (i + 1 >= segments.length) continue;
        final next = segments[i + 1];
        if (i + 2 < segments.length &&
            !SHOMusicCachePaths.isImageEntry(next) &&
            !SHOMusicCachePaths.isLyricsEntry(next) &&
            !SHOMusicCachePaths.isAudioEntry(next)) {
          return SHOMusicSongKey.fromTitle(next);
        }
        return SHOMusicSongKey.fromTitle(next);
      }
      if (folder == 'songs' && i + 1 < segments.length) {
        return SHOMusicSongKey.fromTitle(segments[i + 1]);
      }
    }

    final file = segments.last;
    if (SHOMusicCachePaths.isAudioEntry(file) ||
        SHOMusicCachePaths.isImageEntry(file) ||
        SHOMusicCachePaths.isLyricsEntry(file)) {
      return SHOMusicSongKey.fromTitle(file);
    }
    return null;
  }

  bool _looksLikeLrc(String text) => text.contains(RegExp(r'\[\d+:\d+'));

  String _plainTextToLrc(String text) {
    final lines = const LineSplitter()
        .convert(text)
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.isEmpty) return '';
    final buffer = StringBuffer();
    for (var i = 0; i < lines.length; i++) {
      final minutes = (i * 5) ~/ 60;
      final seconds = (i * 5) % 60;
      buffer.writeln(
        '[${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}.00]${lines[i]}',
      );
    }
    return buffer.toString();
  }

  Future<List<SHOMusicPackSongRef>> discoverSongsInPack(String zipPath) async {
    final bytes = await File(zipPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final songs = <String, SHOMusicPackSongRef>{};

    for (final file in archive) {
      if (file.isFile != true) continue;
      final entryName = file.name.replaceAll('\\', '/');
      if (!SHOMusicCachePaths.isAudioEntry(entryName)) continue;
      if (_isAssetFolderAudio(entryName)) continue;

      final songKey = _entrySongKey(entryName);
      if (songKey == null || songKey.isEmpty) continue;

      final segments = entryName.split('/').where((s) => s.isNotEmpty).toList();
      final fileName = segments.last;
      final displayTitle = fileName.contains('.')
          ? fileName.substring(0, fileName.lastIndexOf('.'))
          : fileName;

      songs.putIfAbsent(
        songKey,
        () => SHOMusicPackSongRef(songKey: songKey, displayTitle: displayTitle),
      );
    }
    return songs.values.toList()
      ..sort((a, b) => a.displayTitle.compareTo(b.displayTitle));
  }

  Future<void> importPackToLibrary({
    required SHODownloadTask packTask,
    required List<SHODownloadTask> downloadTasks,
  }) async {
    final zipPath = await SHODownloadPaths.resolveExistingFilePath(packTask);
    if (zipPath == null) return;

    final songs = await discoverSongsInPack(zipPath);
    for (final song in songs) {
      await resolveSongAssets(
        title: song.displayTitle,
        downloadTasks: downloadTasks,
        allowedPackTaskIds: {packTask.id},
      );
    }
  }
}

class SHOMusicPackSongRef {
  const SHOMusicPackSongRef({
    required this.songKey,
    required this.displayTitle,
  });

  final String songKey;
  final String displayTitle;
}
