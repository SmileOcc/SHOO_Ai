import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/hos_music_song_key.dart';

/// 音乐资源库目录（Documents/shoo_music_library），不受设置「清空缓存」影响。
abstract final class SHOMusicCachePaths {
  static const _folderName = 'shoo_music_library';

  static Future<String> libraryDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(dir.path, _folderName));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return folder.path;
  }

  static Future<String> songDirectory(String songKey) async {
    final root = await libraryDirectory();
    final folder = Directory(p.join(root, songKey));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return folder.path;
  }

  static Future<bool> isSongCached(String songKey) async {
    final audio = await audioPath(songKey);
    if (audio == null) return false;
    return File(audio).exists();
  }

  static Future<String?> audioPath(String songKey) async {
    final dir = Directory(await songDirectory(songKey));
    if (!await dir.exists()) return null;
    await for (final entity in dir.list()) {
      if (entity is! File) continue;
      final ext = p.extension(entity.path).toLowerCase();
      if (const {'.mp3', '.m4a', '.flac', '.wav', '.aac', '.ogg'}.contains(ext)) {
        return entity.path;
      }
    }
    return null;
  }

  static Future<String?> coverPath(String songKey) async {
    return _firstExisting(songKey, const ['cover.jpg', 'cover.png', 'cover.webp']);
  }

  static Future<String?> bgPath(String songKey) async {
    return _firstExisting(songKey, const ['bg.jpg', 'bg.png', 'bg.webp']);
  }

  static Future<String?> lyricsPath(String songKey) async {
    return _firstExisting(songKey, const ['lyrics.lrc', 'lyrics.txt']);
  }

  static Future<String?> _firstExisting(
    String songKey,
    List<String> names,
  ) async {
    final dir = await songDirectory(songKey);
    for (final name in names) {
      final file = File(p.join(dir, name));
      if (await file.exists()) return file.path;
    }
    return null;
  }

  static Future<List<String>> listCachedSongKeys() async {
    final root = await libraryDirectory();
    final folder = Directory(root);
    if (!await folder.exists()) return [];

    final keys = <String>[];
    await for (final entity in folder.list()) {
      if (entity is! Directory) continue;
      final key = p.basename(entity.path);
      if (key.startsWith('.')) continue;
      if (await audioPath(key) != null) keys.add(key);
    }
    return keys;
  }

  static Future<void> deleteSongCache(String songKey) async {
    final dir = Directory(p.join(await libraryDirectory(), songKey));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  static Future<String> writeBytes({
    required String songKey,
    required String fileName,
    required List<int> bytes,
  }) async {
    final dir = await songDirectory(songKey);
    final target = File(p.join(dir, fileName));
    await target.writeAsBytes(bytes, flush: true);
    return target.path;
  }

  static String canonicalAudioName(String originalName) {
    final ext = p.extension(originalName);
    return 'audio${ext.isEmpty ? '.mp3' : ext}';
  }

  static String canonicalCoverName(String originalName) {
    final ext = p.extension(originalName);
    return 'cover${ext.isEmpty ? '.jpg' : ext}';
  }

  static String canonicalBgName(String originalName) {
    final ext = p.extension(originalName);
    return 'bg${ext.isEmpty ? '.jpg' : ext}';
  }

  static String canonicalLyricsName(String originalName) {
    return p.extension(originalName).toLowerCase() == '.txt'
        ? 'lyrics.txt'
        : 'lyrics.lrc';
  }

  static bool isIgnoredZipEntry(String path) {
    final normalized = path.replaceAll('\\', '/').toLowerCase();
    if (normalized.contains('__macosx/')) return true;
    for (final segment in normalized.split('/')) {
      if (segment.isEmpty) continue;
      if (segment == '.ds_store' || segment.startsWith('._')) return true;
    }
    return false;
  }

  static bool isAudioEntry(String path) {
    if (isIgnoredZipEntry(path)) return false;
    final ext = p.extension(path).toLowerCase();
    return const {'.mp3', '.m4a', '.flac', '.wav', '.aac', '.ogg'}.contains(ext);
  }

  static bool isImageEntry(String path) {
    if (isIgnoredZipEntry(path)) return false;
    final ext = p.extension(path).toLowerCase();
    return const {'.jpg', '.jpeg', '.png', '.webp'}.contains(ext);
  }

  static bool isLyricsEntry(String path) {
    if (isIgnoredZipEntry(path)) return false;
    final ext = p.extension(path).toLowerCase();
    return const {'.lrc', '.txt'}.contains(ext);
  }

  static String? songKeyFromZipEntry(String entryPath) {
    final normalized = entryPath.replaceAll('\\', '/');
    final segments = normalized.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return null;

    if (segments.length >= 2) {
      final folder = segments.first.toLowerCase();
      if (folder == 'song_cover' ||
          folder == 'song_bg' ||
          folder == 'song_lyrics' ||
          folder == 'songs') {
        return SHOMusicSongKey.fromTitle(segments[1]);
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
}
