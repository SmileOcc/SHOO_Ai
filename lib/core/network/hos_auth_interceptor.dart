import 'package:dio/dio.dart';

/// 自动注入 Authorization Bearer Token。
class SHOAuthInterceptor extends Interceptor {
  SHOAuthInterceptor(this._tokenReader);

  final String? Function() _tokenReader;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenReader();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
