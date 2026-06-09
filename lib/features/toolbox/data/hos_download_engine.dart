import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../domain/hos_download_task.dart';
import 'hos_download_paths.dart';

typedef DownloadTaskResolver = SHODownloadTask? Function(String id);
typedef DownloadTaskUpdater = Future<void> Function(SHODownloadTask task);

class SHODownloadEngine {
  SHODownloadEngine({
    required DownloadTaskResolver resolveTask,
    required DownloadTaskUpdater updateTask,
  })  : _resolveTask = resolveTask,
        _updateTask = updateTask,
        _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(minutes: 30),
            followRedirects: true,
            validateStatus: (status) => status != null && status < 500,
          ),
        );

  final DownloadTaskResolver _resolveTask;
  final DownloadTaskUpdater _updateTask;
  final Dio _dio;

  final _queue = <String>[];
  final _activeTokens = <String, CancelToken>{};
  final _running = <String>{};
  static const _maxConcurrent = 2;

  Future<String> downloadsDirectory() => SHODownloadPaths.downloadsDirectory();

  void enqueue(String taskId, {bool front = false}) {
    if (_queue.contains(taskId) || _running.contains(taskId)) return;
    if (front) {
      _queue.insert(0, taskId);
    } else {
      _queue.add(taskId);
    }
    _pumpQueue();
  }

  void enqueueAll(Iterable<String> ids, {bool front = false}) {
    for (final id in ids) {
      enqueue(id, front: front);
    }
  }

  Future<void> pause(String taskId) async {
    _queue.remove(taskId);
    final token = _activeTokens.remove(taskId);
    token?.cancel('paused');
    _running.remove(taskId);

    final task = _resolveTask(taskId);
    if (task == null) return;
    if (task.status == SHODownloadStatus.completed) return;
    await _updateTask(task.copyWith(status: SHODownloadStatus.paused));
    _pumpQueue();
  }

  Future<void> resume(String taskId) async {
    final task = _resolveTask(taskId);
    if (task == null || task.status == SHODownloadStatus.completed) return;
    await _updateTask(task.copyWith(status: SHODownloadStatus.downloading));
    enqueue(taskId, front: task.priority);
  }

  void dispose() {
    for (final token in _activeTokens.values) {
      token.cancel('dispose');
    }
    _activeTokens.clear();
    _queue.clear();
    _running.clear();
    _dio.close(force: true);
  }

  void _pumpQueue() {
    while (_running.length < _maxConcurrent && _queue.isNotEmpty) {
      final id = _queue.removeAt(0);
      if (_running.contains(id)) continue;
      final task = _resolveTask(id);
      if (task == null ||
          task.status == SHODownloadStatus.completed ||
          task.status == SHODownloadStatus.paused) {
        continue;
      }
      _running.add(id);
      unawaited(_runDownload(id));
    }
  }

  Future<void> _runDownload(String taskId) async {
    final initial = _resolveTask(taskId);
    if (initial == null) {
      _running.remove(taskId);
      return;
    }

    final localPath = await SHODownloadPaths.filePathFor(initial.fileName);
    final file = File(localPath);
    var downloaded = 0;
    if (await file.exists()) {
      downloaded = await file.length();
    } else {
      await file.parent.create(recursive: true);
    }

    final knownTotal = initial.totalBytes;
    if (knownTotal != null && downloaded >= knownTotal) {
      await _updateTask(
        initial.copyWith(
          localPath: localPath,
          status: SHODownloadStatus.completed,
          downloadedBytes: downloaded,
          totalBytes: () => knownTotal,
        ),
      );
      _running.remove(taskId);
      _pumpQueue();
      return;
    }

    final cancelToken = CancelToken();
    _activeTokens[taskId] = cancelToken;

    try {
      final headers = downloaded > 0
          ? <String, dynamic>{'Range': 'bytes=$downloaded-'}
          : null;

      final response = await _dio.get<ResponseBody>(
        initial.url,
        options: Options(
          responseType: ResponseType.stream,
          headers: headers,
        ),
        cancelToken: cancelToken,
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 416 && downloaded > 0) {
        await _updateTask(
          initial.copyWith(
            localPath: localPath,
            status: SHODownloadStatus.completed,
            downloadedBytes: downloaded,
            totalBytes: () => downloaded,
          ),
        );
        return;
      }
      if (statusCode >= 400) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'HTTP $statusCode',
        );
      }

      int? totalBytes = _parseTotalBytes(
        response.headers.value('content-length'),
        downloaded,
        response.statusCode,
      );

      if (totalBytes != null) {
        await _updateTask(
          initial.copyWith(
            localPath: localPath,
            status: SHODownloadStatus.downloading,
            downloadedBytes: downloaded,
            totalBytes: () => totalBytes,
          ),
        );
      } else {
        await _updateTask(
          initial.copyWith(
            localPath: localPath,
            status: SHODownloadStatus.downloading,
            downloadedBytes: downloaded,
          ),
        );
      }

      final body = response.data;
      if (body == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Empty response body',
        );
      }

      final sink = file.openWrite(mode: FileMode.append);
      try {
        await for (final chunk in body.stream) {
          if (cancelToken.isCancelled) break;
          sink.add(chunk);
          downloaded += chunk.length;
          final current = _resolveTask(taskId);
          if (current == null) break;
          await _updateTask(
            current.copyWith(
              downloadedBytes: downloaded,
              totalBytes: () => totalBytes ?? current.totalBytes,
            ),
          );
        }
      } finally {
        await sink.close();
      }

      if (cancelToken.isCancelled) return;

      final done = _resolveTask(taskId);
      if (done == null) return;
      await _updateTask(
        done.copyWith(
          localPath: localPath,
          status: SHODownloadStatus.completed,
          downloadedBytes: downloaded,
          totalBytes: () => totalBytes ?? downloaded,
        ),
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) return;
      final failed = _resolveTask(taskId);
      if (failed != null) {
        await _updateTask(failed.copyWith(status: SHODownloadStatus.paused));
      }
    } catch (_) {
      final failed = _resolveTask(taskId);
      if (failed != null) {
        await _updateTask(failed.copyWith(status: SHODownloadStatus.paused));
      }
    } finally {
      _activeTokens.remove(taskId);
      _running.remove(taskId);
      _pumpQueue();
    }
  }

  int? _parseTotalBytes(String? contentLength, int downloaded, int? statusCode) {
    final parsed = int.tryParse(contentLength ?? '');
    if (parsed == null) return null;
    if (statusCode == 206) return downloaded + parsed;
    return parsed;
  }
}
