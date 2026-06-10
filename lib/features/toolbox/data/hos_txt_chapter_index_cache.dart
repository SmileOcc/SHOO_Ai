import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../domain/hos_txt_novel_models.dart';
import '../domain/hos_txt_novel_parser.dart';

/// 章节索引磁盘缓存：以文件绝对路径定位缓存文件，以文件大小 + 修改时间校验有效性。
abstract final class SHOTxtChapterIndexCache {
  static const _folderName = 'txt_chapter_index_cache';
  static const _cacheVersion = 1;

  static Future<String> _cacheDirectory() async {
    final dir = await getApplicationSupportDirectory();
    final folder = Directory('${dir.path}/$_folderName');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return folder.path;
  }

  static String _cacheFileName(String absolutePath) {
    final hash = absolutePath.hashCode.toUnsigned(32).toRadixString(16);
    return 'idx_$hash.json';
  }

  static Future<File> _cacheFileFor(String absolutePath) async {
    final dir = await _cacheDirectory();
    return File('$dir/${_cacheFileName(absolutePath)}');
  }

  static Future<List<SHONovelChapterMeta>?> readIfValid(File file) async {
    if (!await file.exists()) return null;

    final stat = await file.stat();
    final absolutePath = file.absolute.path;
    final cacheFile = await _cacheFileFor(absolutePath);
    if (!await cacheFile.exists()) return null;

    try {
      final raw = await cacheFile.readAsString();
      final json = jsonDecode(raw) as Map<String, dynamic>;
      if (json['version'] != _cacheVersion) return null;
      if (json['filePath'] != absolutePath) return null;
      if (json['fileSize'] != stat.size) return null;
      if (json['modifiedAtMs'] != stat.modified.millisecondsSinceEpoch) {
        return null;
      }

      final chapters = (json['chapters'] as List<dynamic>)
          .map(
            (item) =>
                SHONovelChapterMeta.fromJson(item as Map<String, dynamic>),
          )
          .toList();
      if (chapters.isEmpty) return null;
      return chapters;
    } catch (_) {
      try {
        await cacheFile.delete();
      } catch (_) {}
      return null;
    }
  }

  static Future<void> write({
    required File file,
    required List<SHONovelChapterMeta> chapters,
  }) async {
    if (chapters.isEmpty) return;

    final stat = await file.stat();
    final absolutePath = file.absolute.path;
    final cacheFile = await _cacheFileFor(absolutePath);
    final payload = jsonEncode({
      'version': _cacheVersion,
      'filePath': absolutePath,
      'fileSize': stat.size,
      'modifiedAtMs': stat.modified.millisecondsSinceEpoch,
      'chapters': chapters.map((meta) => meta.toJson()).toList(),
    });
    await cacheFile.writeAsString(payload);
  }
}

/// 优先读取磁盘缓存，未命中时再流式扫描并回写缓存。
Future<List<SHONovelChapterMeta>> scanChapterMetasWithCache(
  File file,
  void Function(double progress) onProgress,
) async {
  final cached = await SHOTxtChapterIndexCache.readIfValid(file);
  if (cached != null) {
    onProgress(1);
    return cached;
  }

  final metas = await scanChapterMetas(file, onProgress);
  await SHOTxtChapterIndexCache.write(file: file, chapters: metas);
  return metas;
}
