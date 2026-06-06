// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hos_page_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SHOPageResultImpl<T> _$$SHOPageResultImplFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => _$SHOPageResultImpl<T>(
  items: (json['items'] as List<dynamic>).map(fromJsonT).toList(),
  page: (json['page'] as num?)?.toInt() ?? 1,
  pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
  total: (json['total'] as num?)?.toInt() ?? 0,
  hasMore: json['hasMore'] as bool? ?? false,
);

Map<String, dynamic> _$$SHOPageResultImplToJson<T>(
  _$SHOPageResultImpl<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'items': instance.items.map(toJsonT).toList(),
  'page': instance.page,
  'pageSize': instance.pageSize,
  'total': instance.total,
  'hasMore': instance.hasMore,
};
