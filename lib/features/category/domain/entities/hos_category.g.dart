// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hos_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SHOCategoryLeafImpl _$$SHOCategoryLeafImplFromJson(
  Map<String, dynamic> json,
) => _$SHOCategoryLeafImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  icon: json['icon'] as String? ?? '',
);

Map<String, dynamic> _$$SHOCategoryLeafImplToJson(
  _$SHOCategoryLeafImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'icon': instance.icon,
};

_$SHOCategoryGroupImpl _$$SHOCategoryGroupImplFromJson(
  Map<String, dynamic> json,
) => _$SHOCategoryGroupImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  children: json['children'] == null
      ? const []
      : categoryLeavesFromJson(json['children']),
);

Map<String, dynamic> _$$SHOCategoryGroupImplToJson(
  _$SHOCategoryGroupImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'children': instance.children,
};

_$SHOCategoryItemImpl _$$SHOCategoryItemImplFromJson(
  Map<String, dynamic> json,
) => _$SHOCategoryItemImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  icon: json['icon'] as String? ?? '🏷️',
  groups: json['groups'] == null
      ? const []
      : categoryGroupsFromJson(json['groups']),
);

Map<String, dynamic> _$$SHOCategoryItemImplToJson(
  _$SHOCategoryItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'icon': instance.icon,
  'groups': instance.groups,
};
