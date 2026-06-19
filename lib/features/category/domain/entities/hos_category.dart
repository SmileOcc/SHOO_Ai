import 'package:freezed_annotation/freezed_annotation.dart';

part 'hos_category.freezed.dart';
part 'hos_category.g.dart';

List<SHOCategoryLeaf> categoryLeavesFromJson(dynamic json) {
  if (json is! List) return const [];
  return [
    for (final entry in json)
      if (entry is Map<String, dynamic>) SHOCategoryLeaf.fromJson(entry),
  ];
}

List<SHOCategoryGroup> categoryGroupsFromJson(dynamic json) {
  if (json is! List) return const [];
  return [
    for (final entry in json)
      if (entry is Map<String, dynamic>) SHOCategoryGroup.fromJson(entry),
  ];
}

Map<String, dynamic> normalizeCategoryJson(Map<String, dynamic> raw) {
  final map = Map<String, dynamic>.from(raw);
  final groups = map['groups'];
  if (groups is! List) {
    map['groups'] = const <dynamic>[];
    return map;
  }

  map['groups'] = [
    for (final group in groups)
      if (group is Map)
        {
          ...Map<String, dynamic>.from(group),
          'children': group['children'] is List ? group['children'] : <dynamic>[],
        },
  ];
  return map;
}

SHOCategoryItem parseCategoryItemFromJson(Map<String, dynamic> raw) {
  return SHOCategoryItem.fromJson(normalizeCategoryJson(raw));
}

List<SHOCategoryLeaf> safeCategoryLeaves(SHOCategoryGroup group) {
  try {
    return List<SHOCategoryLeaf>.from(group.children);
  } catch (_) {
    return const [];
  }
}

List<SHOCategoryGroup> safeCategoryGroups(SHOCategoryItem item) {
  try {
    return List<SHOCategoryGroup>.from(item.groups);
  } catch (_) {
    return const [];
  }
}

SHOCategoryGroup normalizeCategoryGroup(SHOCategoryGroup group) {
  return SHOCategoryGroup(
    id: group.id,
    name: group.name,
    children: safeCategoryLeaves(group),
  );
}

SHOCategoryItem normalizeCategoryItem(SHOCategoryItem item) {
  return SHOCategoryItem(
    id: item.id,
    name: item.name,
    icon: item.icon,
    groups: safeCategoryGroups(item).map(normalizeCategoryGroup).toList(),
  );
}

List<SHOCategoryItem> normalizeCategoryItems(List<SHOCategoryItem> items) {
  return items.map(normalizeCategoryItem).toList();
}

/// 三级分类叶子节点。
@freezed
class SHOCategoryLeaf with _$SHOCategoryLeaf {
  const factory SHOCategoryLeaf({
    required String id,
    required String name,
    @Default('') String icon,
  }) = _SHOCategoryLeaf;

  factory SHOCategoryLeaf.fromJson(Map<String, dynamic> json) =>
      _$SHOCategoryLeafFromJson(json);
}

/// 二级分类分组。
@freezed
class SHOCategoryGroup with _$SHOCategoryGroup {
  const factory SHOCategoryGroup({
    required String id,
    required String name,
    @JsonKey(fromJson: categoryLeavesFromJson)
    @Default([])
    List<SHOCategoryLeaf> children,
  }) = _SHOCategoryGroup;

  factory SHOCategoryGroup.fromJson(Map<String, dynamic> json) =>
      _$SHOCategoryGroupFromJson(json);
}

/// 一级分类（可含二、三级分组）。
@freezed
class SHOCategoryItem with _$SHOCategoryItem {
  const factory SHOCategoryItem({
    required String id,
    required String name,
    @Default('🏷️') String icon,
    @JsonKey(fromJson: categoryGroupsFromJson)
    @Default([])
    List<SHOCategoryGroup> groups,
  }) = _SHOCategoryItem;

  factory SHOCategoryItem.fromJson(Map<String, dynamic> json) =>
      _$SHOCategoryItemFromJson(json);
}
