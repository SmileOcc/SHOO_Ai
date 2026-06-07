import 'dart:convert';

import 'package:dio/dio.dart';

import '../debug/modules/network_log/hos_debug_network_log_config.dart';
import '../logging/hos_logger.dart';
import '../logging/hos_remote_log_uploader.dart';

/// 可配置的网络请求/响应日志拦截器（Debug 日志面板控制）。
class SHONetworkLogInterceptor extends Interceptor {
  SHONetworkLogInterceptor(this._readConfig);

  final SHODebugNetworkLogConfig Function() _readConfig;

  static const _border =
      '──────────────────── SHOO HTTP LOG ────────────────────';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final config = _readConfig();
    if (!_shouldLog(options.uri.path, config)) {
      handler.next(options);
      return;
    }

    final buffer = StringBuffer()
      ..writeln(_border)
      ..writeln('[HTTP REQUEST] ${options.method} ${options.uri}');

    if (config.logRequestParams) {
      if (options.queryParameters.isNotEmpty) {
        buffer.writeln('query: ${_formatData(options.queryParameters)}');
      }
      if (options.data != null) {
        buffer.writeln('body: ${_formatData(options.data)}');
      }
    } else {
      buffer.writeln('(request params logging disabled)');
    }
    buffer.writeln(_border);

    final text = buffer.toString();
    SHOAppLogger.debug(text);
    _uploadRemote(config, kind: 'request', message: text);
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final config = _readConfig();
    if (!_shouldLog(response.requestOptions.uri.path, config)) {
      handler.next(response);
      return;
    }

    final buffer = StringBuffer()
      ..writeln(_border)
      ..writeln(
        '[HTTP RESPONSE] ${response.requestOptions.method} '
        '${response.requestOptions.uri} → ${response.statusCode}',
      );

    if (config.logResponseParams) {
      buffer.writeln('data: ${_formatData(response.data)}');
    } else {
      buffer.writeln('(response body logging disabled)');
    }
    buffer.writeln(_border);

    final text = buffer.toString();
    SHOAppLogger.debug(text);
    _uploadRemote(config, kind: 'response', message: text);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final config = _readConfig();
    if (_shouldLog(err.requestOptions.uri.path, config)) {
      final text =
          '[HTTP ERROR] ${err.requestOptions.method} ${err.requestOptions.uri} | ${err.message}';
      SHOAppLogger.warn(text);
      _uploadRemote(config, kind: 'error', message: text);
    }
    handler.next(err);
  }

  void _uploadRemote(
    SHODebugNetworkLogConfig config, {
    required String kind,
    required String message,
  }) {
    if (config.useMockRemoteLog) return;
    SHORemoteLogUploader.uploadNetworkLog(kind: kind, message: message);
  }

  bool _shouldLog(String path, SHODebugNetworkLogConfig config) {
    if (!config.enabled) return false;
    if (!config.filterPathsEnabled) return true;

    final filters = config.parsedPathFilters;
    if (filters.isEmpty) return false;
    return filters.any((filter) => path.contains(filter));
  }

  String _formatData(Object? data) {
    if (data == null) return 'null';
    if (data is Map || data is List) {
      try {
        return const JsonEncoder.withIndent('  ').convert(data);
      } catch (_) {
        return data.toString();
      }
    }
    if (data is FormData) return '<FormData>';
    return data.toString();
  }
}
