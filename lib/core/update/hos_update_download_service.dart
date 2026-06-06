import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../platform/hos_native_business_event.dart';
import '../platform/hos_native_business_event_service.dart';

final appUpdateDownloadServiceProvider =
    Provider<SHOAppUpdateDownloadService>((ref) {
  return SHOAppUpdateDownloadService(ref.watch(nativeBusinessEventServiceProvider));
});

class SHOAppUpdateDownloadState {
  const SHOAppUpdateDownloadState({
    required this.progress,
    required this.status,
    this.message,
  });

  final double progress;
  final String status;
  final String? message;

  bool get isCompleted => status == 'completed' || progress >= 1.0;
}

/// App 更新包下载进度（EventChannel 原生 Mock + 可用于真实 APK 下载对接）。
class SHOAppUpdateDownloadService {
  SHOAppUpdateDownloadService(this._events);

  final SHONativeBusinessEventService _events;
  static const defaultTaskId = 'app_update';

  Stream<SHOAppUpdateDownloadState> watchProgress({
    String taskId = defaultTaskId,
  }) {
    return _events.watchDownload(taskId: taskId).map(_mapEvent);
  }

  SHOAppUpdateDownloadState _mapEvent(SHONativeBusinessEvent event) {
    return SHOAppUpdateDownloadState(
      progress: event.progress ?? 0,
      status: event.status ?? 'running',
      message: event.message,
    );
  }
}
