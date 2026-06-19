import 'package:freezed_annotation/freezed_annotation.dart';

part 'hos_after_sale.freezed.dart';
part 'hos_after_sale.g.dart';

enum SHOAfterSaleType {
  @JsonValue('refund')
  refund,
  @JsonValue('return_refund')
  returnRefund,
}

enum SHOAfterSaleStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
  @JsonValue('completed')
  completed,
}

@freezed
class SHOAfterSaleRequest with _$SHOAfterSaleRequest {
  const factory SHOAfterSaleRequest({
    required String id,
    required String orderId,
    required String orderNo,
    required SHOAfterSaleType type,
    required SHOAfterSaleStatus status,
    required String reason,
    required String createdAt,
    @Default('') String productTitle,
  }) = _SHOAfterSaleRequest;

  factory SHOAfterSaleRequest.fromJson(Map<String, dynamic> json) =>
      _$SHOAfterSaleRequestFromJson(json);
}

@freezed
class SHOAfterSaleCreateRequest with _$SHOAfterSaleCreateRequest {
  const factory SHOAfterSaleCreateRequest({
    required String orderId,
    required SHOAfterSaleType type,
    required String reason,
    @Default([]) List<String> imageUrls,
  }) = _SHOAfterSaleCreateRequest;

  factory SHOAfterSaleCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$SHOAfterSaleCreateRequestFromJson(json);
}
