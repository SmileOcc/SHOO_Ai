// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hos_address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SHOAddressImpl _$$SHOAddressImplFromJson(Map<String, dynamic> json) =>
    _$SHOAddressImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      line1: json['line1'] as String,
      line2: json['line2'] as String? ?? '',
      city: json['city'] as String,
      region: json['region'] as String,
      postalCode: json['postalCode'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
    );

Map<String, dynamic> _$$SHOAddressImplToJson(_$SHOAddressImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'line1': instance.line1,
      'line2': instance.line2,
      'city': instance.city,
      'region': instance.region,
      'postalCode': instance.postalCode,
      'isDefault': instance.isDefault,
    };
