import 'package:freezed_annotation/freezed_annotation.dart';

part 'hos_category.freezed.dart';
part 'hos_category.g.dart';

@freezed
class SHOCategoryItem with _$SHOCategoryItem {
  const factory SHOCategoryItem({
    required String id,
    required String name,
    @Default('🏷️') String icon,
  }) = _SHOCategoryItem;

  factory SHOCategoryItem.fromJson(Map<String, dynamic> json) =>
      _$SHOCategoryItemFromJson(json);
}
