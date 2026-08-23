/// ThemeActivity 优惠券模块状态（与配置 JSON `status` 对齐）。
enum SHOThemeCouponStatus {
  claimable,
  claimed,
  soldOut,
  expired,
  unknown;

  static SHOThemeCouponStatus parse(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'claimable':
        return SHOThemeCouponStatus.claimable;
      case 'claimed':
        return SHOThemeCouponStatus.claimed;
      case 'soldout':
      case 'sold_out':
        return SHOThemeCouponStatus.soldOut;
      case 'expired':
        return SHOThemeCouponStatus.expired;
      default:
        return SHOThemeCouponStatus.unknown;
    }
  }

  String get wireValue => switch (this) {
        SHOThemeCouponStatus.claimable => 'claimable',
        SHOThemeCouponStatus.claimed => 'claimed',
        SHOThemeCouponStatus.soldOut => 'soldOut',
        SHOThemeCouponStatus.expired => 'expired',
        SHOThemeCouponStatus.unknown => 'unknown',
      };

  bool get canClaim => this == SHOThemeCouponStatus.claimable;

  bool get canUseLink => this == SHOThemeCouponStatus.claimed;

  bool get isDisabled =>
      this == SHOThemeCouponStatus.soldOut ||
      this == SHOThemeCouponStatus.expired;
}

/// 合并配置状态与页内领取记录，得到券的最终状态。
///
/// 配置里的 `status: claimed` 仅作后台预览示意，真实「已领取」以
/// [claimedCouponIds]（本次会话 + 用户钱包）为准。
SHOThemeCouponStatus resolveThemeCouponStatus({
  required Map<String, dynamic> item,
  required Set<String> claimedCouponIds,
}) {
  final couponId = item['couponId'] as String? ?? '';
  if (couponId.isNotEmpty && claimedCouponIds.contains(couponId)) {
    return SHOThemeCouponStatus.claimed;
  }
  final configStatus = SHOThemeCouponStatus.parse(item['status'] as String?);
  if (configStatus == SHOThemeCouponStatus.claimed) {
    return SHOThemeCouponStatus.claimable;
  }
  return configStatus;
}

String themeCouponButtonText(
  Map<String, dynamic> item,
  SHOThemeCouponStatus status,
) {
  switch (status) {
    case SHOThemeCouponStatus.claimable:
      return item['claimButtonText'] as String? ??
          item['buttonText'] as String? ??
          '立即领取';
    case SHOThemeCouponStatus.claimed:
      return item['claimedButtonText'] as String? ??
          item['useButtonText'] as String? ??
          (RegExp(r'去使用|use', caseSensitive: false)
                  .hasMatch(item['buttonText'] as String? ?? '')
              ? item['buttonText'] as String?
              : null) ??
          '去使用';
    case SHOThemeCouponStatus.soldOut:
      return item['soldOutButtonText'] as String? ?? '已抢光';
    case SHOThemeCouponStatus.expired:
      return item['expiredButtonText'] as String? ?? '已过期';
    case SHOThemeCouponStatus.unknown:
      return item['buttonText'] as String? ?? '';
  }
}

String themeCouponStatusLabel(SHOThemeCouponStatus status) {
  return switch (status) {
    SHOThemeCouponStatus.claimable => '可领取',
    SHOThemeCouponStatus.claimed => '已领取',
    SHOThemeCouponStatus.soldOut => '已抢光',
    SHOThemeCouponStatus.expired => '已过期',
    SHOThemeCouponStatus.unknown => '',
  };
}
