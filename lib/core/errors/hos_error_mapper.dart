import 'package:dio/dio.dart';

import '../platform/hos_native_bridge_exception.dart';
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

SHOAppException mapNativeBridgeError(SHONativeBridgeException error) {
  if (error.isNotImplemented) {
    return SHOUnknownException('Feature not available on this platform');
  }
  return SHOUnknownException(error.message);
}

String userFacingMessage(SHOAppException error) {
  return switch (error) {
    SHONetworkException() => 'Network issue. Please check your connection.',
    SHOServerException() => error.message,
    SHOCacheException() => 'Local storage error. Please retry.',
    SHOUnknownException() => 'Something went wrong. Please try again.',
  };
}

/// 将任意异常转为用户可读文案（全局错误处理统一入口）。
String messageFromAny(Object error) {
  if (error is SHOAppException) return userFacingMessage(error);
  if (error is DioException) return userFacingMessage(mapDioError(error));
  if (error is SHONativeBridgeException) {
    return userFacingMessage(mapNativeBridgeError(error));
  }
  final text = error.toString().trim();
  if (text.isEmpty) {
    return 'Something went wrong. Please try again.';
  }
  return text;
}

Object normalizeToAppException(Object error) {
  if (error is SHOAppException) return error;
  if (error is DioException) return mapDioError(error);
  if (error is SHONativeBridgeException) return mapNativeBridgeError(error);
  return SHOUnknownException(messageFromAny(error));
}
