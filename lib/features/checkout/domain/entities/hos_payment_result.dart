import 'package:freezed_annotation/freezed_annotation.dart';

part 'hos_payment_result.freezed.dart';
part 'hos_payment_result.g.dart';

@freezed
class SHOPaymentResult with _$SHOPaymentResult {
  const factory SHOPaymentResult({
    required String orderId,
    required String status,
    required String paidAt,
    @Default('') String message,
  }) = _SHOPaymentResult;

  factory SHOPaymentResult.fromJson(Map<String, dynamic> json) =>
      _$SHOPaymentResultFromJson(json);

  /// 兼容 Mock 扁平结构与 Platform API 历史 `{ order: {...} }` 响应。
  factory SHOPaymentResult.fromResponse(Map<String, dynamic> json) {
    final orderId = json['orderId'];
    if (orderId is String && orderId.isNotEmpty) {
      return SHOPaymentResult.fromJson(json);
    }

    final order = json['order'];
    if (order is Map<String, dynamic>) {
      final id = order['id'];
      if (id is! String || id.isEmpty) {
        throw FormatException('Invalid payment response: missing order.id', json);
      }
      return SHOPaymentResult(
        orderId: id,
        status: order['status'] as String? ?? 'paid',
        paidAt: order['createdAt'] as String? ?? '',
        message: json['message'] as String? ?? 'Payment successful',
      );
    }

    throw FormatException('Invalid payment response', json);
  }
}
