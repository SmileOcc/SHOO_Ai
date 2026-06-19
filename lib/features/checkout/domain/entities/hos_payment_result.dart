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
}
