import 'package:freezed_annotation/freezed_annotation.dart';

part 'hos_message.freezed.dart';
part 'hos_message.g.dart';

@freezed
class SHOAppMessage with _$SHOAppMessage {
  const factory SHOAppMessage({
    required String id,
    required String title,
    required String body,
    required String type,
    required String createdAt,
    @Default(false) bool isRead,
  }) = _SHOAppMessage;

  factory SHOAppMessage.fromJson(Map<String, dynamic> json) =>
      _$SHOAppMessageFromJson(json);
}
