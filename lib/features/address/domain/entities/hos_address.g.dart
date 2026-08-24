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
      countryCode: json['countryCode'] as String? ?? '',
      countryName: json['countryName'] as String? ?? '',
      regionL2Code: json['regionL2Code'] as String? ?? '',
      regionL2Name: json['regionL2Name'] as String? ?? '',
      regionL3Code: json['regionL3Code'] as String? ?? '',
      regionL3Name: json['regionL3Name'] as String? ?? '',
      regionL4Code: json['regionL4Code'] as String? ?? '',
      regionL4Name: json['regionL4Name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      region: json['region'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
      needsRegionReselect: json['needsRegionReselect'] as bool? ?? false,
    );

Map<String, dynamic> _$$SHOAddressImplToJson(_$SHOAddressImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'line1': instance.line1,
      'line2': instance.line2,
      'countryCode': instance.countryCode,
      'countryName': instance.countryName,
      'regionL2Code': instance.regionL2Code,
      'regionL2Name': instance.regionL2Name,
      'regionL3Code': instance.regionL3Code,
      'regionL3Name': instance.regionL3Name,
      'regionL4Code': instance.regionL4Code,
      'regionL4Name': instance.regionL4Name,
      'city': instance.city,
      'region': instance.region,
      'postalCode': instance.postalCode,
      'isDefault': instance.isDefault,
      'needsRegionReselect': instance.needsRegionReselect,
    };
