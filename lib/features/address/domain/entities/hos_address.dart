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
    @Default('') String countryCode,
    @Default('') String countryName,
    @Default('') String regionL2Code,
    @Default('') String regionL2Name,
    @Default('') String regionL3Code,
    @Default('') String regionL3Name,
    @Default('') String regionL4Code,
    @Default('') String regionL4Name,
    @Default('') String city,
    @Default('') String region,
    @Default('') String postalCode,
    @Default(false) bool isDefault,
    @Default(false) bool needsRegionReselect,
  }) = _SHOAddress;

  factory SHOAddress.fromJson(Map<String, dynamic> json) =>
      _$SHOAddressFromJson(json);

  String get regionSummary {
    final parts = <String>[
      if (countryName.isNotEmpty) countryName,
      if (regionL2Name.isNotEmpty) regionL2Name,
      if (regionL3Name.isNotEmpty) regionL3Name,
      if (regionL4Name.isNotEmpty) regionL4Name,
    ];
    if (parts.isNotEmpty) return parts.join(' ');
    if (city.isNotEmpty || region.isNotEmpty) {
      return [region, city].where((s) => s.isNotEmpty).join(' ');
    }
    return '';
  }

  String get fullLine => [
    if (regionSummary.isNotEmpty) regionSummary,
    line1,
    if (line2.isNotEmpty) line2,
    if (postalCode.isNotEmpty) postalCode,
  ].join(', ');

  SHOAddress normalized() {
    if (countryCode.isNotEmpty) return this;
    return copyWith(
      countryCode: 'US',
      regionL2Name: region,
      regionL3Name: city,
      needsRegionReselect: region.isEmpty || city.isEmpty,
    );
  }
}
