/// 抢购活动 Mock 活动 ID 与默认路由参数。
abstract final class SHOFlashSaleActivities {
  static const flash = 'activity_flash_001';
  static const discount = 'activity_discount_001';
  static const common = 'activity_common_000';

  static const defaults = common;

  static String titleFor(String activityId) {
    switch (activityId) {
      case flash:
        return '抢购活动';
      case discount:
        return '折扣活动';
      case common:
        return '活动专区';
      default:
        return '限时抢购';
    }
  }
}
