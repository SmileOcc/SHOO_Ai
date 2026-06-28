import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoo/core/widgets/hos_promo_badge.dart';

part 'hos_flash_sale_models.freezed.dart';
part 'hos_flash_sale_models.g.dart';

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

@freezed
class SHOFlashSalePromoTag with _$SHOFlashSalePromoTag {
  const SHOFlashSalePromoTag._();

  const factory SHOFlashSalePromoTag({
    required String type,
    required String label,
    @Default(true) bool enabled,
  }) = _SHOFlashSalePromoTag;

  factory SHOFlashSalePromoTag.fromJson(Map<String, dynamic> json) =>
      _$SHOFlashSalePromoTagFromJson(json);

  SHOPromoBadgeTagData toBadgeData() => SHOPromoBadgeTagData(
    type: SHOPromoBadgeTypeX.fromApi(type),
    label: label,
    enabled: enabled,
  );
}

@freezed
class SHOFlashSaleCalendar with _$SHOFlashSaleCalendar {
  const factory SHOFlashSaleCalendar({
    required String serverTime,
    required List<SHOFlashSaleDay> days,
  }) = _SHOFlashSaleCalendar;

  factory SHOFlashSaleCalendar.fromJson(Map<String, dynamic> json) =>
      _$SHOFlashSaleCalendarFromJson(json);
}

@freezed
class SHOFlashSaleDay with _$SHOFlashSaleDay {
  const factory SHOFlashSaleDay({
    required String date,
    required String label,
    required String weekday,
    @Default(SHOFlashSaleDayStatus.notStarted) SHOFlashSaleDayStatus status,
    @Default(0) int sessionCount,
  }) = _SHOFlashSaleDay;

  factory SHOFlashSaleDay.fromJson(Map<String, dynamic> json) =>
      _$SHOFlashSaleDayFromJson(json);
}

@freezed
class SHOFlashSaleSession with _$SHOFlashSaleSession {
  const factory SHOFlashSaleSession({
    required String id,
    required String label,
    required String startAt,
    required String endAt,
    required String claimStartAt,
    required String claimEndAt,
    @Default(SHOFlashSaleDayStatus.notStarted) SHOFlashSaleDayStatus status,
  }) = _SHOFlashSaleSession;

  factory SHOFlashSaleSession.fromJson(Map<String, dynamic> json) =>
      _$SHOFlashSaleSessionFromJson(json);
}

@freezed
class SHOFlashSalePromoEntry with _$SHOFlashSalePromoEntry {
  const factory SHOFlashSalePromoEntry({
    required String id,
    required String title,
    required String iconUrl,
    required String deeplink,
  }) = _SHOFlashSalePromoEntry;

  factory SHOFlashSalePromoEntry.fromJson(Map<String, dynamic> json) =>
      _$SHOFlashSalePromoEntryFromJson(json);
}

@freezed
class SHOFlashSaleCoupon with _$SHOFlashSaleCoupon {
  const factory SHOFlashSaleCoupon({
    required String id,
    required String title,
    required String description,
    @Default(SHOFlashSaleCouponStatus.notStarted)
    SHOFlashSaleCouponStatus status,
  }) = _SHOFlashSaleCoupon;

  factory SHOFlashSaleCoupon.fromJson(Map<String, dynamic> json) =>
      _$SHOFlashSaleCouponFromJson(json);
}

@freezed
class SHOFlashSaleProduct with _$SHOFlashSaleProduct {
  const SHOFlashSaleProduct._();

  const factory SHOFlashSaleProduct({
    required String id,
    required String sessionId,
    required String title,
    required String imageUrl,
    required int originalPrice,
    required int activityPrice,
    @Default([]) List<String> skuAttributes,
    @Default([]) List<SHOFlashSalePromoTag> promoTags,
    String? primaryPromoType,
    String? primaryPromoLabel,
    @Default(SHOFlashSaleProductStatus.notStarted)
    SHOFlashSaleProductStatus status,
    @Default(0) int stock,
    @Default(0) int soldCount,
    @Default(false) bool isFollowed,
    String? createdAt,
  }) = _SHOFlashSaleProduct;

  factory SHOFlashSaleProduct.fromJson(Map<String, dynamic> json) =>
      _$SHOFlashSaleProductFromJson(json);

  SHOPromoBadgeType? get primaryBadgeType => primaryPromoType != null
      ? SHOPromoBadgeTypeX.fromApi(primaryPromoType)
      : null;

  List<SHOPromoBadgeTagData> get badgeTags =>
      promoTags.map((t) => t.toBadgeData()).toList();

  int get displayPrice {
    if (status == SHOFlashSaleProductStatus.ongoing && stock > 0) {
      return activityPrice;
    }
    return originalPrice;
  }

  /// 场次进行中且有库存时可购买。
  bool get canPurchase =>
      status == SHOFlashSaleProductStatus.ongoing && stock > 0;

  /// 仅未开始活动可关注。
  bool get canFollow => status == SHOFlashSaleProductStatus.notStarted;
}

@freezed
class SHOFlashSalePageData with _$SHOFlashSalePageData {
  const factory SHOFlashSalePageData({
    required String serverTime,
    required String date,
    required String sessionId,
    required SHOFlashSaleClaimPhase claimPhase,
    String? claimCountdownTarget,
    @Default([]) List<SHOFlashSaleSession> sessions,
    @Default([]) List<SHOFlashSalePromoEntry> promoEntries,
    @Default([]) List<SHOFlashSaleCoupon> coupons,
    @Default([]) List<SHOFlashSaleProduct> products,
    @Default(1) int page,
    @Default(10) int pageSize,
    @Default(0) int total,
    @Default(false) bool hasMore,
  }) = _SHOFlashSalePageData;

  factory SHOFlashSalePageData.fromJson(Map<String, dynamic> json) =>
      _$SHOFlashSalePageDataFromJson(json);
}

@freezed
class SHOFlashSaleProductActivity with _$SHOFlashSaleProductActivity {
  const SHOFlashSaleProductActivity._();

  const factory SHOFlashSaleProductActivity({
    required String sessionId,
    required SHOFlashSaleProductStatus status,
    required int originalPrice,
    required int activityPrice,
    @Default([]) List<SHOFlashSalePromoTag> promoTags,
    String? primaryPromoType,
    String? primaryPromoLabel,
    String? sessionStartAt,
    String? sessionEndAt,
    String? overlayLabel,
    @Default(false) bool isFollowed,
    @Default(0) int stock,
  }) = _SHOFlashSaleProductActivity;

  factory SHOFlashSaleProductActivity.fromJson(Map<String, dynamic> json) =>
      _$SHOFlashSaleProductActivityFromJson(json);

  SHOPromoBadgeType? get primaryBadgeType => primaryPromoType != null
      ? SHOPromoBadgeTypeX.fromApi(primaryPromoType)
      : null;

  int get displayPrice {
    if (status == SHOFlashSaleProductStatus.ongoing && stock > 0) {
      return activityPrice;
    }
    return originalPrice;
  }

  bool get showActivityPrice =>
      status == SHOFlashSaleProductStatus.ongoing && stock > 0;
}

@freezed
class SHOFlashSaleFollow with _$SHOFlashSaleFollow {
  const factory SHOFlashSaleFollow({
    required String id,
    required String sessionId,
    required String productId,
    required String title,
    required String imageUrl,
    required String sessionStartAt,
    @Default(SHOFlashSaleProductStatus.notStarted)
    SHOFlashSaleProductStatus status,
  }) = _SHOFlashSaleFollow;

  factory SHOFlashSaleFollow.fromJson(Map<String, dynamic> json) =>
      _$SHOFlashSaleFollowFromJson(json);
}
