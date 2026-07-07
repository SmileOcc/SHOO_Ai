// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hos_flash_sale_calendar.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SHOFlashSaleCalendarImpl _$$SHOFlashSaleCalendarImplFromJson(
  Map<String, dynamic> json,
) => _$SHOFlashSaleCalendarImpl(
  serverTime: json['serverTime'] as String,
  days: (json['days'] as List<dynamic>)
      .map((e) => SHOFlashSaleDay.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$SHOFlashSaleCalendarImplToJson(
  _$SHOFlashSaleCalendarImpl instance,
) => <String, dynamic>{
  'serverTime': instance.serverTime,
  'days': instance.days,
};

_$SHOFlashSaleDayImpl _$$SHOFlashSaleDayImplFromJson(
  Map<String, dynamic> json,
) => _$SHOFlashSaleDayImpl(
  date: json['date'] as String,
  label: json['label'] as String,
  weekday: json['weekday'] as String,
  status:
      $enumDecodeNullable(_$SHOFlashSaleDayStatusEnumMap, json['status']) ??
      SHOFlashSaleDayStatus.notStarted,
  sessionCount: (json['sessionCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$SHOFlashSaleDayImplToJson(
  _$SHOFlashSaleDayImpl instance,
) => <String, dynamic>{
  'date': instance.date,
  'label': instance.label,
  'weekday': instance.weekday,
  'status': _$SHOFlashSaleDayStatusEnumMap[instance.status]!,
  'sessionCount': instance.sessionCount,
};

const _$SHOFlashSaleDayStatusEnumMap = {
  SHOFlashSaleDayStatus.notStarted: 'not_started',
  SHOFlashSaleDayStatus.ongoing: 'ongoing',
  SHOFlashSaleDayStatus.ending: 'ending',
  SHOFlashSaleDayStatus.ended: 'ended',
};

_$SHOFlashSaleSessionImpl _$$SHOFlashSaleSessionImplFromJson(
  Map<String, dynamic> json,
) => _$SHOFlashSaleSessionImpl(
  id: json['id'] as String,
  label: json['label'] as String,
  startAt: json['startAt'] as String,
  endAt: json['endAt'] as String,
  claimStartAt: json['claimStartAt'] as String,
  claimEndAt: json['claimEndAt'] as String,
  status:
      $enumDecodeNullable(_$SHOFlashSaleDayStatusEnumMap, json['status']) ??
      SHOFlashSaleDayStatus.notStarted,
);

Map<String, dynamic> _$$SHOFlashSaleSessionImplToJson(
  _$SHOFlashSaleSessionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'startAt': instance.startAt,
  'endAt': instance.endAt,
  'claimStartAt': instance.claimStartAt,
  'claimEndAt': instance.claimEndAt,
  'status': _$SHOFlashSaleDayStatusEnumMap[instance.status]!,
};
