import 'package:freezed_annotation/freezed_annotation.dart';

enum SHOFlashSaleDayStatus {
  @JsonValue('not_started')
  notStarted,
  @JsonValue('ongoing')
  ongoing,
  @JsonValue('ending')
  ending,
  @JsonValue('ended')
  ended,
}

enum SHOFlashSaleCouponStatus {
  @JsonValue('not_started')
  notStarted,
  @JsonValue('claimable')
  claimable,
  @JsonValue('claimed')
  claimed,
  @JsonValue('sold_out')
  soldOut,
  @JsonValue('expired')
  expired,
}

enum SHOFlashSaleProductStatus {
  @JsonValue('not_started')
  notStarted,
  @JsonValue('ongoing')
  ongoing,
  @JsonValue('ended')
  ended,
  @JsonValue('sold_out')
  soldOut,
}

enum SHOFlashSaleSort {
  hot,
  @JsonValue('price_asc')
  priceAsc,
  @JsonValue('price_desc')
  priceDesc,
  newest,
}

enum SHOFlashSaleClaimPhase {
  @JsonValue('before_claim')
  beforeClaim,
  @JsonValue('claiming')
  claiming,
  @JsonValue('after_claim')
  afterClaim,
}