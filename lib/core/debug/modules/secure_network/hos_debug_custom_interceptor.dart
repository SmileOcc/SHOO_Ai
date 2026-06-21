import 'package:dio/dio.dart';

import 'package:shoo/core/debug/modules/secure_network/hos_debug_network_lab_config.dart';

typedef SHODebugInterceptorEvent = void Function(String message);

/// Debug 用：可配置 Header / 延迟的自定义拦截器。
class SHODebugCustomInterceptor extends Interceptor {
  SHODebugCustomInterceptor({
    required SHODebugNetworkLabConfig config,
    required SHODebugInterceptorEvent onEvent,
  })  : _config = config,
        _onEvent = onEvent;

  final SHODebugNetworkLabConfig _config;
  final SHODebugInterceptorEvent _onEvent;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_config.customHeaderKey.trim().isNotEmpty) {
      options.headers[_config.customHeaderKey.trim()] =
          _config.customHeaderValue;
    }
    options.extra['debug_custom_interceptor'] = true;
    _onEvent(
      '[Custom:onRequest] ${_config.customInsertBeforeAuth ? "prepend" : "append"} '
      '${options.method} ${options.path}',
    );

    if (_config.customDelayMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: _config.customDelayMs));
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _onEvent(
      '[Custom:onResponse] ${response.statusCode} ${response.requestOptions.path}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _onEvent(
      '[Custom:onError] ${err.type.name} ${err.requestOptions.path}',
    );
    handler.next(err);
  }
}
