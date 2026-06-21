import 'package:dio/dio.dart';

/// Debug 用：模拟 503 失败，配合 [SHORetryInterceptor] 验证重试。
class SHODebugFailInterceptor extends Interceptor {
  static const failUntilSuccessExtraKey = 'debug_fail_until_success';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final failUntil = options.extra[failUntilSuccessExtraKey] as int?;
    if (failUntil == null || failUntil <= 0) {
      handler.next(options);
      return;
    }

    final attempt = options.extra['retry_attempt'] as int? ?? 0;
    if (attempt < failUntil) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: options,
            statusCode: 503,
            data: {
              'code': 503,
              'message': 'Debug simulated 503 (attempt ${attempt + 1})',
            },
          ),
          message: 'Debug simulated 503 before retry success',
        ),
      );
      return;
    }

    handler.next(options);
  }
}
