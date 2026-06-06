import 'dart:io' as io;

import 'package:file/file.dart' hide FileSystem;
import 'package:file/local.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const _cacheKey = 'shoo_image_cache';

/// 统一图片磁盘缓存：文件与 SQLite 均落在 Application Support，避免 tmp 被系统清理后
/// 出现 `attempt to write a readonly database` (SQLITE_READONLY_DBMOVED / 1032)。
class SHOImageCacheManager extends CacheManager with ImageCacheManager {
  SHOImageCacheManager._()
      : super(
          Config(
            _cacheKey,
            stalePeriod: const Duration(days: 14),
            maxNrOfCacheObjects: 300,
            repo: CacheObjectProvider(databaseName: _cacheKey),
            fileSystem: SHOPersistentImageFileSystem(_cacheKey),
          ),
        );

  static final SHOImageCacheManager instance = SHOImageCacheManager._();

  static bool isReadonlyDbError(Object error) {
    final msg = error.toString().toLowerCase();
    return msg.contains('readonly') || msg.contains('1032');
  }

  /// 启动时打开缓存库；若已损坏则清空并重建。
  static Future<void> ensureReady() async {
    try {
      await instance.config.repo.open();
    } catch (e) {
      if (isReadonlyDbError(e)) {
        await _reset();
      } else {
        rethrow;
      }
    }
  }

  static Future<void> recoverFromReadonlyError() => _reset();

  static Future<void> _reset() async {
    try {
      await instance.emptyCache();
      await instance.dispose();
    } catch (_) {}

    try {
      final supportDir = await getApplicationSupportDirectory();
      final cacheDir = io.Directory(p.join(supportDir.path, _cacheKey));
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }

      await _deleteDbArtifacts(p.join(supportDir.path, '$_cacheKey.db'));
    } catch (_) {}
  }

  static Future<void> _deleteDbArtifacts(String dbPath) async {
    for (final path in [
      dbPath,
      '$dbPath-wal',
      '$dbPath-shm',
      '$dbPath-journal',
    ]) {
      final file = io.File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}

/// 图片文件存 Application Support，不与 tmp 目录生命周期脱节。
class SHOPersistentImageFileSystem implements FileSystem {
  SHOPersistentImageFileSystem(this._cacheKey);

  final String _cacheKey;
  Future<Directory>? _dirFuture;

  static const LocalFileSystem _fs = LocalFileSystem();

  Future<Directory> _directory() {
    _dirFuture ??= _createDirectory();
    return _dirFuture!;
  }

  Future<Directory> _createDirectory() async {
    final base = await getApplicationSupportDirectory();
    final path = p.join(base.path, _cacheKey, 'files');
    final directory = _fs.directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  @override
  Future<File> createFile(String name) async {
    final directory = await _directory();
    if (!await directory.exists()) {
      _dirFuture = null;
      final refreshed = await _directory();
      return refreshed.childFile(name);
    }
    return directory.childFile(name);
  }
}
