import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// 本地日志缓存与导出（开发包缓存全部级别；正式包不缓存 DEBUG）。
class SHOAppLogManager {
  SHOAppLogManager._();

  static final SHOAppLogManager instance = SHOAppLogManager._();

  static const _fileName = 'shoo_app_logs.txt';
  static const _maxBytes = 5 * 1024 * 1024;

  File? _file;
  bool _ready = false;

  Future<void> init() async {
    final dir = await getApplicationSupportDirectory();
    final logDir = Directory('${dir.path}/app_logs');
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }
    _file = File('${logDir.path}/$_fileName');
    _ready = true;
  }

  bool shouldCacheLevel(String level) {
    if (kReleaseMode && level == 'DEBUG') return false;
    return true;
  }

  Future<void> append(String level, String message) async {
    if (!_ready || _file == null || !shouldCacheLevel(level)) return;
    try {
      final line =
          '${DateTime.now().toIso8601String()} [$level] $message\n';
      await _rotateIfNeeded(line.length);
      await _file!.writeAsString(line, mode: FileMode.append, flush: false);
    } catch (_) {}
  }

  Future<void> _rotateIfNeeded(int incomingBytes) async {
    if (_file == null || !await _file!.exists()) return;
    final size = await _file!.length();
    if (size + incomingBytes <= _maxBytes) return;
    final backup = File('${_file!.path}.1');
    if (await backup.exists()) await backup.delete();
    await _file!.rename(backup.path);
    _file = File(_file!.path);
  }

  Future<int> cachedByteSize() async {
    if (_file == null || !await _file!.exists()) return 0;
    var total = await _file!.length();
    final backup = File('${_file!.path}.1');
    if (await backup.exists()) total += await backup.length();
    return total;
  }

  Future<File?> exportFile() async {
    if (_file == null || !await _file!.exists()) return null;
    return _file;
  }

  Future<void> clear() async {
    if (_file == null) return;
    if (await _file!.exists()) await _file!.delete();
    final backup = File('${_file!.path}.1');
    if (await backup.exists()) await backup.delete();
  }

  static String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
