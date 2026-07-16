import 'package:freezed_annotation/freezed_annotation.dart';

part 'hos_cart.freezed.dart';
part 'hos_cart.g.dart';

/// 购物车行默认库存上限（商品侧未给库存时的兜底）。
const kSHOCartDefaultStock = 99;

@freezed
class SHOCartItem with _$SHOCartItem {
  const SHOCartItem._();

  const factory SHOCartItem({
    required String id,
    required String productId,
    required String title,
    required String imageUrl,
    /// 当前成交单价（可能是活动价）。
    required int price,
    @Default(1) int quantity,
    @Default('') String variantLabel,
    @Default(true) bool selected,
    @Default(false) bool unavailable,
    @Default(false) bool priceChanged,
    /// 当前可购库存（对账/加购写入）。
    @Default(kSHOCartDefaultStock) int stock,
    /// 吊牌/原价，用于划线展示；0 表示无划线。
    @Default(0) int listPrice,
    /// 闪购等活动场次；空表示普通行。
    @Default('') String sessionId,
    /// 活动结束时间 ISO8601；空表示不自动过期。
    @Default('') String sessionEndAt,
  }) = _SHOCartItem;

  factory SHOCartItem.fromJson(Map<String, dynamic> json) =>
      _$SHOCartItemFromJson(json);

  bool get hasActivity => sessionId.isNotEmpty;

  bool get isActivityExpired {
    if (!hasActivity || sessionEndAt.isEmpty) return false;
    final end = DateTime.tryParse(sessionEndAt);
    if (end == null) return false;
    return DateTime.now().toUtc().isAfter(end.toUtc());
  }

  /// 结算/合计用单价：活动过期则回落到吊牌价。
  int get effectiveUnitCents {
    if (hasActivity && isActivityExpired && listPrice > 0) {
      return listPrice;
    }
    return price;
  }

  bool get showStrikeListPrice =>
      listPrice > effectiveUnitCents && !unavailable;
}

@freezed
class SHOCartSnapshot with _$SHOCartSnapshot {
  const SHOCartSnapshot._();

  const factory SHOCartSnapshot({
    @Default(<SHOCartItem>[]) List<SHOCartItem> items,
  }) = _SHOCartSnapshot;

  factory SHOCartSnapshot.fromJson(Map<String, dynamic> json) =>
      _$SHOCartSnapshotFromJson(json);

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  /// 可购买商品数量（排除已下架/失效行）。
  int get availableItemCount =>
      items.where((i) => !i.unavailable).fold(0, (sum, i) => sum + i.quantity);

  List<SHOCartItem> get availableItems =>
      items.where((i) => !i.unavailable).toList();

  List<SHOCartItem> get unavailableItems =>
      items.where((i) => i.unavailable).toList();

  /// 可结算勾选件数（失效行不计入，即使曾被勾选）。
  int get selectedCount => items
      .where((i) => i.selected && !i.unavailable)
      .fold(0, (sum, i) => sum + i.quantity);

  /// 可结算勾选小计（分）— 使用有效成交单价。
  int get selectedTotalCents => items
      .where((i) => i.selected && !i.unavailable)
      .fold(0, (sum, i) => sum + i.effectiveUnitCents * i.quantity);

  /// 活动已省金额（展示用）。
  int get selectedActivitySavedCents => items
      .where((i) => i.selected && !i.unavailable && i.showStrikeListPrice)
      .fold(
        0,
        (sum, i) =>
            sum + (i.listPrice - i.effectiveUnitCents) * i.quantity,
      );

  /// 可结算勾选行。
  List<SHOCartItem> get selectedItems =>
      items.where((i) => i.selected && !i.unavailable).toList();

  bool get hasUnavailable => items.any((i) => i.unavailable);

  /// 全选：仅针对可购买行。
  bool get allSelected {
    final available = availableItems;
    return available.isNotEmpty && available.every((i) => i.selected);
  }
}
