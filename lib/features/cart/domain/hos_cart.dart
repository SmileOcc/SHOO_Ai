import 'package:freezed_annotation/freezed_annotation.dart';

part 'hos_cart.freezed.dart';
part 'hos_cart.g.dart';

@freezed
class SHOCartItem with _$SHOCartItem {
  const factory SHOCartItem({
    required String id,
    required String productId,
    required String title,
    required String imageUrl,
    required int price,
    @Default(1) int quantity,
    @Default('') String variantLabel,
    @Default(true) bool selected,
  }) = _SHOCartItem;

  factory SHOCartItem.fromJson(Map<String, dynamic> json) =>
      _$SHOCartItemFromJson(json);
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

  int get selectedCount =>
      items.where((i) => i.selected).fold(0, (sum, i) => sum + i.quantity);

  int get selectedTotalCents => items
      .where((i) => i.selected)
      .fold(0, (sum, i) => sum + i.price * i.quantity);

  List<SHOCartItem> get selectedItems =>
      items.where((i) => i.selected).toList();

  bool get allSelected => items.isNotEmpty && items.every((i) => i.selected);
}
