import 'package:dio/dio.dart';

import 'hos_exception.dart';

SHOAppException mapDioError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const SHONetworkException('Connection timed out');
    case DioExceptionType.connectionError:
      return const SHONetworkException('No internet connection');
    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode;
      final message = error.response?.data is Map
          ? (error.response!.data as Map)['message']?.toString()
          : null;
      return SHOServerException(
        message ?? 'Server error',
        code: statusCode,
      );
    case DioExceptionType.cancel:
      return const SHONetworkException('Request cancelled');
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return SHOUnknownException(error.message ?? 'Unexpected network error');
  }
}

String userFacingMessage(SHOAppException error) {
  return switch (error) {
    SHONetworkException() => 'Network issue. Please check your connection.',
    SHOServerException() => error.message,
    SHOCacheException() => 'Local storage error. Please retry.',
    SHOUnknownException() => 'Something went wrong. Please try again.',
  };
}
