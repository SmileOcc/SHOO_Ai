import 'package:freezed_annotation/freezed_annotation.dart';

part 'hos_address.freezed.dart';
part 'hos_address.g.dart';

@freezed
class SHOAddress with _$SHOAddress {
  const SHOAddress._();

  const factory SHOAddress({
    required String id,
    required String name,
    required String phone,
    required String line1,
    @Default('') String line2,
    required String city,
    required String region,
    @Default('') String postalCode,
    @Default(false) bool isDefault,
  }) = _SHOAddress;

  factory SHOAddress.fromJson(Map<String, dynamic> json) =>
      _$SHOAddressFromJson(json);

  String get fullLine => [
        line1,
        if (line2.isNotEmpty) line2,
        '$city, $region $postalCode',
      ].join(', ');
}
