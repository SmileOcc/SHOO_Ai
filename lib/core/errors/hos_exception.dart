sealed class SHOAppException implements Exception {
  const SHOAppException(this.message, {this.code});

  final String message;
  final int? code;

  @override
  String toString() => 'SHOAppException($code): $message';
}

final class SHONetworkException extends SHOAppException {
  const SHONetworkException(super.message, {super.code});
}

final class SHOServerException extends SHOAppException {
  const SHOServerException(super.message, {super.code});
}

final class SHOCacheException extends SHOAppException {
  const SHOCacheException(super.message, {super.code});
}

final class SHOUnknownException extends SHOAppException {
  const SHOUnknownException([super.message = 'Unknown error occurred']);
}
