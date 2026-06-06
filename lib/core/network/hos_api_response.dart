class SHOApiResponse<T> {
  const SHOApiResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  final int code;
  final String message;
  final T data;

  bool get isSuccess => code == 0;

  factory SHOApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    return SHOApiResponse<T>(
      code: json['code'] as int? ?? -1,
      message: json['message'] as String? ?? '',
      data: fromJsonT(json['data']),
    );
  }
}
