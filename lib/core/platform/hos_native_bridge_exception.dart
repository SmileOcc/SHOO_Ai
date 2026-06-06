/// Platform Channel 统一异常。
final class SHONativeBridgeException implements Exception {
  const SHONativeBridgeException({
    required this.channel,
    required this.method,
    required this.message,
    this.code,
    this.details,
  });

  final String channel;
  final String method;
  final String message;
  final String? code;
  final dynamic details;

  bool get isNotImplemented => code == 'not_implemented';

  @override
  String toString() =>
      '[SHONativeBridge] $channel.$method failed: $message (code: $code)';
}
