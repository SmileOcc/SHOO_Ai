// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hos_region_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SHORegionNodeImpl _$$SHORegionNodeImplFromJson(Map<String, dynamic> json) =>
    _$SHORegionNodeImpl(
      code: json['code'] as String,
      name: json['name'] as String,
      nameEn: json['nameEn'] as String? ?? '',
      level: (json['level'] as num).toInt(),
      countryCode: json['countryCode'] as String,
      parentCode: json['parentCode'] as String? ?? '',
      hasChildren: json['hasChildren'] as bool? ?? false,
    );

Map<String, dynamic> _$$SHORegionNodeImplToJson(_$SHORegionNodeImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'nameEn': instance.nameEn,
      'level': instance.level,
      'countryCode': instance.countryCode,
      'parentCode': instance.parentCode,
      'hasChildren': instance.hasChildren,
    };

_$SHORegionCountryConfigImpl _$$SHORegionCountryConfigImplFromJson(
  Map<String, dynamic> json,
) => _$SHORegionCountryConfigImpl(
  countryCode: json['countryCode'] as String,
  name: json['name'] as String,
  nameEn: json['nameEn'] as String? ?? '',
  maxLevel: (json['maxLevel'] as num?)?.toInt() ?? 4,
  requiredLevels:
      (json['requiredLevels'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const <int>[],
  labels:
      (json['labels'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
);

Map<String, dynamic> _$$SHORegionCountryConfigImplToJson(
  _$SHORegionCountryConfigImpl instance,
) => <String, dynamic>{
  'countryCode': instance.countryCode,
  'name': instance.name,
  'nameEn': instance.nameEn,
  'maxLevel': instance.maxLevel,
  'requiredLevels': instance.requiredLevels,
  'labels': instance.labels,
};

_$SHORegionChildrenResultImpl _$$SHORegionChildrenResultImplFromJson(
  Map<String, dynamic> json,
) => _$SHORegionChildrenResultImpl(
  countryCode: json['countryCode'] as String,
  parentCode: json['parentCode'] as String? ?? '',
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => SHORegionNode.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SHORegionNode>[],
);

Map<String, dynamic> _$$SHORegionChildrenResultImplToJson(
  _$SHORegionChildrenResultImpl instance,
) => <String, dynamic>{
  'countryCode': instance.countryCode,
  'parentCode': instance.parentCode,
  'items': instance.items,
};
