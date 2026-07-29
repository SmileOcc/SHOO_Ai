import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

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

  Future<void> _ensureReady() async {
    if (_ready && _file != null) return;
    await init();
  }

  bool shouldCacheLevel(String level) {
    if (kReleaseMode && level == 'DEBUG') return false;
    return true;
  }

  Future<void> append(String level, String message) async {
    await _ensureReady();
    if (_file == null || !shouldCacheLevel(level)) return;
    try {
      final line = '${DateTime.now().toIso8601String()} [$level] $message\n';
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
    await _ensureReady();
    if (_file == null || !await _file!.exists()) return 0;
    var total = await _file!.length();
    final backup = File('${_file!.path}.1');
    if (await backup.exists()) total += await backup.length();
    return total;
  }

  /// 导出到临时目录副本，避免直接分享应用沙盒内正在写入的文件。
  Future<File?> exportFile() async {
    await _ensureReady();
    if (_file == null || !await _file!.exists()) return null;

    final tempDir = await getTemporaryDirectory();
    final stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final out = File('${tempDir.path}/shoo_app_logs_$stamp.txt');

    final sink = out.openWrite();
    try {
      final backup = File('${_file!.path}.1');
      if (await backup.exists()) {
        await sink.addStream(backup.openRead());
        sink.writeln();
        sink.writeln('----- rotated backup above / current below -----');
        sink.writeln();
      }
      await sink.addStream(_file!.openRead());
    } finally {
      await sink.close();
    }

    if (!await out.exists() || await out.length() == 0) return null;
    return out;
  }

  Future<void> clear() async {
    await _ensureReady();
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
