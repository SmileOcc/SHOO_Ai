import 'package:freezed_annotation/freezed_annotation.dart';

part 'hos_order.freezed.dart';
part 'hos_order.g.dart';

enum SHOOrderStatus {
  @JsonValue('pending_payment')
  pendingPayment,
  @JsonValue('paid')
  paid,
  @JsonValue('shipped')
  shipped,
  @JsonValue('delivered')
  delivered,
  @JsonValue('cancelled')
  cancelled,
}

@freezed
class SHOOrderItem with _$SHOOrderItem {
  const factory SHOOrderItem({
    required String productId,
    required String title,
    required String imageUrl,
    required int price,
    @Default(1) int quantity,
    @Default('') String variantLabel,
  }) = _SHOOrderItem;

  factory SHOOrderItem.fromJson(Map<String, dynamic> json) =>
      _$SHOOrderItemFromJson(json);
}

@freezed
class SHOOrderSummary with _$SHOOrderSummary {
  const factory SHOOrderSummary({
    required String id,
    required String orderNo,
    required SHOOrderStatus status,
    required int totalCents,
    required String createdAt,
    @Default(<SHOOrderItem>[]) List<SHOOrderItem> items,
  }) = _SHOOrderSummary;

  factory SHOOrderSummary.fromJson(Map<String, dynamic> json) =>
      _$SHOOrderSummaryFromJson(json);
}

@freezed
class SHOOrderDetail with _$SHOOrderDetail {
  const factory SHOOrderDetail({
    required String id,
    required String orderNo,
    required SHOOrderStatus status,
    required int totalCents,
    required String createdAt,
    @Default('') String shippingAddress,
    @Default(<SHOOrderItem>[]) List<SHOOrderItem> items,
    @Default(false) bool hasLogistics,
  }) = _SHOOrderDetail;

  factory SHOOrderDetail.fromJson(Map<String, dynamic> json) =>
      _$SHOOrderDetailFromJson(json);
}

@freezed
class SHOLogisticsEvent with _$SHOLogisticsEvent {
  const factory SHOLogisticsEvent({
    required String time,
    required String status,
    required String description,
    @Default(false) bool isActive,
  }) = _SHOLogisticsEvent;

  factory SHOLogisticsEvent.fromJson(Map<String, dynamic> json) =>
      _$SHOLogisticsEventFromJson(json);
}

@freezed
class SHOLogisticsTrack with _$SHOLogisticsTrack {
  const factory SHOLogisticsTrack({
    required String orderId,
    required String carrier,
    required String trackingNumber,
    @Default(<SHOLogisticsEvent>[]) List<SHOLogisticsEvent> events,
  }) = _SHOLogisticsTrack;

  factory SHOLogisticsTrack.fromJson(Map<String, dynamic> json) =>
      _$SHOLogisticsTrackFromJson(json);
}
