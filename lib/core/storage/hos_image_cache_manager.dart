import 'dart:async';
import 'dart:io' as io;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file/file.dart' hide FileSystem;
import 'package:file/local.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../logging/hos_logger.dart';

const _cacheKey = 'shoo_image_cache';

/// 统一图片磁盘缓存：SQLite 与文件均落在 Application Support，避免 tmp 被清理后出现
/// `attempt to write a readonly database` (SQLITE_READONLY / 1032)。
class SHOImageCacheManager extends CacheManager with ImageCacheManager {
  SHOImageCacheManager._(Config config) : super(config);

  static SHOImageCacheManager? _instance;
  static bool _recovering = false;
  static DateTime? _lastRecoveryLog;

  static SHOImageCacheManager get instance {
    _instance ??= _createDefault();
    return _instance!;
  }

  static SHOImageCacheManager _createDefault() {
    return SHOImageCacheManager._(
      Config(
        _cacheKey,
        stalePeriod: const Duration(days: 14),
        maxNrOfCacheObjects: 300,
        repo: CacheObjectProvider(databaseName: _cacheKey),
        fileSystem: SHOPersistentImageFileSystem(_cacheKey),
      ),
    );
  }

  static Future<Config> _createExplicitConfig() async {
    final supportDir = await getApplicationSupportDirectory();
    final dbPath = p.join(supportDir.path, '$_cacheKey.db');
    return Config(
      _cacheKey,
      stalePeriod: const Duration(days: 14),
      maxNrOfCacheObjects: 300,
      repo: CacheObjectProvider(path: dbPath),
      fileSystem: SHOPersistentImageFileSystem(_cacheKey),
    );
  }

  static bool isReadonlyDbError(Object error) {
    final msg = error.toString().toLowerCase();
    return msg.contains('readonly') || msg.contains('1032');
  }

  /// 启动时打开缓存库；若已损坏则清空并重建。
  static Future<void> ensureReady() async {
    try {
      await instance.config.repo.open();
    } catch (error) {
      if (isReadonlyDbError(error)) {
        await _hardReset(logError: error);
      } else {
        rethrow;
      }
    }
  }

  /// 运行时遇到只读库错误时调用：跳过 SQLite 写操作，直接删库并重建实例。
  static Future<void> recoverFromReadonlyError({Object? error}) async {
    if (_recovering) return;
    if (error != null) {
      _logRecoveryOnce(error);
    }
    await _hardReset();
  }

  static void _logRecoveryOnce(Object error) {
    final now = DateTime.now();
    if (_lastRecoveryLog != null &&
        now.difference(_lastRecoveryLog!) < const Duration(seconds: 10)) {
      return;
    }
    _lastRecoveryLog = now;
    SHOAppLogger.warn('Image cache DB readonly, resetting cache: $error');
  }

  static Future<void> _hardReset({Object? logError}) async {
    if (_recovering) return;
    _recovering = true;
    if (logError != null) {
      _logRecoveryOnce(logError);
    }

    try {
      final old = _instance;
      if (old != null) {
        try {
          await old.config.repo.close();
        } catch (_) {}
      }

      await _deleteAllCacheArtifacts();

      try {
        _instance = SHOImageCacheManager._(await _createExplicitConfig());
      } catch (_) {
        _instance = _createDefault();
      }

      await _instance!.config.repo.open();
      CachedNetworkImageProvider.defaultCacheManager = _instance!;
    } catch (error, stack) {
      SHOAppLogger.error('Image cache hard reset failed', error, stack);
      _instance ??= _createDefault();
    } finally {
      _recovering = false;
    }
  }

  static Future<void> _deleteAllCacheArtifacts() async {
    try {
      final supportDir = await getApplicationSupportDirectory();
      final dbPath = p.join(supportDir.path, '$_cacheKey.db');
      await _deleteDbArtifacts(dbPath);

      final cacheRoot = io.Directory(p.join(supportDir.path, _cacheKey));
      if (await cacheRoot.exists()) {
        await cacheRoot.delete(recursive: true);
      }
    } catch (_) {}

    try {
      final legacyDir = await getDatabasesPath();
      await _deleteDbArtifacts(p.join(legacyDir, '$_cacheKey.db'));
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
        try {
          await file.delete();
        } catch (_) {}
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
