import 'package:dio/dio.dart';

import 'package:shoo/core/errors/hos_error_mapper.dart';

/// 统一网络错误映射。
class SHOErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: mapDioError(err),
        message: err.message,
        stackTrace: err.stackTrace,
      ),
    );
  }
}
