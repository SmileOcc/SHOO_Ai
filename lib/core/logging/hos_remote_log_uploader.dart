import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/hos_config.dart';
import 'hos_logger.dart';
import 'hos_remote_log_client.dart';

/// 将调试日志 POST 到本地/远程 server（真实接口）。
abstract final class SHORemoteLogUploader {
  static const analyticsPath = '/analytics/events';
  static const networkLogPath = '/debug/network-logs';

  static bool _localServerWarned = false;

  static Future<void> uploadAnalytics({
    required String eventKey,
    required Map<String, Object?> params,
  }) async {
    await _post(analyticsPath, {
      'event': eventKey,
      'params': params,
      'ts': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> uploadNetworkLog({
    required String kind,
    required String message,
    Map<String, Object?>? extra,
  }) async {
    await _post(networkLogPath, {
      'kind': kind,
      'message': message,
      if (extra != null) ...extra,
      'ts': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> _post(String path, Map<String, dynamic> body) async {
    if (!SHOAppConfig.instance.isDebugPanelEnabled) return;
    try {
      await SHORemoteLogClient.instance.post<dynamic>(path, data: body);
    } on DioException catch (error, stack) {
      final status = error.response?.statusCode;
      if (status == 404) {
        SHOAppLogger.warn(
          'Remote log upload 404: $path — restart local server (cd server && npm run dev)',
        );
        return;
      }
      if (error.type == DioExceptionType.connectionError) {
        _warnLocalServerOnce();
        return;
      }
      SHOAppLogger.warn('Remote log upload failed: $path', error.message);
      if (kDebugMode) {
        SHOAppLogger.debug('Remote log upload stack', stack);
      }
    } catch (error, stack) {
      SHOAppLogger.error('Remote log upload failed: $path', error, stack);
    }
  }

  static void _warnLocalServerOnce() {
    if (_localServerWarned) return;
    _localServerWarned = true;
    SHOAppLogger.warn(
      'Local server unreachable — skip remote log upload. '
      'Start: cd server && npm run dev',
    );
  }

  static void resetWarnings() {
    _localServerWarned = false;
  }
}
