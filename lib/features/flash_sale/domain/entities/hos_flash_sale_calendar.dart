import 'package:freezed_annotation/freezed_annotation.dart';

import 'hos_flash_sale_enums.dart';

part 'hos_flash_sale_calendar.freezed.dart';
part 'hos_flash_sale_calendar.g.dart';

@freezed
class SHOFlashSaleCalendar with _$SHOFlashSaleCalendar {
  const factory SHOFlashSaleCalendar({
    required String serverTime,
    required List<SHOFlashSaleDay> days,
  }) = _SHOFlashSaleCalendar;

  factory SHOFlashSaleCalendar.fromJson(Map<String, dynamic> json) =>
      _$SHOFlashSaleCalendarFromJson(json);
}

@freezed
class SHOFlashSaleDay with _$SHOFlashSaleDay {
  const factory SHOFlashSaleDay({
    required String date,
    required String label,
    required String weekday,
    @Default(SHOFlashSaleDayStatus.notStarted) SHOFlashSaleDayStatus status,
    @Default(0) int sessionCount,
  }) = _SHOFlashSaleDay;

  factory SHOFlashSaleDay.fromJson(Map<String, dynamic> json) =>
      _$SHOFlashSaleDayFromJson(json);
}

@freezed
class SHOFlashSaleSession with _$SHOFlashSaleSession {
  const factory SHOFlashSaleSession({
    required String id,
    required String label,
    required String startAt,
    required String endAt,
    required String claimStartAt,
    required String claimEndAt,
    @Default(SHOFlashSaleDayStatus.notStarted) SHOFlashSaleDayStatus status,
  }) = _SHOFlashSaleSession;

  factory SHOFlashSaleSession.fromJson(Map<String, dynamic> json) =>
      _$SHOFlashSaleSessionFromJson(json);
}