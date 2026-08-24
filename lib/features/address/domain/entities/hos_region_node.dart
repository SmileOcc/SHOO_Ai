import 'package:freezed_annotation/freezed_annotation.dart';

part 'hos_region_node.freezed.dart';
part 'hos_region_node.g.dart';

@freezed
class SHORegionNode with _$SHORegionNode {
  const factory SHORegionNode({
    required String code,
    required String name,
    @Default('') String nameEn,
    required int level,
    required String countryCode,
    @Default('') String parentCode,
    @Default(false) bool hasChildren,
  }) = _SHORegionNode;

  factory SHORegionNode.fromJson(Map<String, dynamic> json) =>
      _$SHORegionNodeFromJson(json);
}

@freezed
class SHORegionCountryConfig with _$SHORegionCountryConfig {
  const factory SHORegionCountryConfig({
    required String countryCode,
    required String name,
    @Default('') String nameEn,
    @Default(4) int maxLevel,
    @Default(<int>[]) List<int> requiredLevels,
    @Default(<String, String>{}) Map<String, String> labels,
  }) = _SHORegionCountryConfig;

  factory SHORegionCountryConfig.fromJson(Map<String, dynamic> json) =>
      _$SHORegionCountryConfigFromJson(json);
}

@freezed
class SHORegionChildrenResult with _$SHORegionChildrenResult {
  const factory SHORegionChildrenResult({
    required String countryCode,
    @Default('') String parentCode,
    @Default(<SHORegionNode>[]) List<SHORegionNode> items,
  }) = _SHORegionChildrenResult;

  factory SHORegionChildrenResult.fromJson(Map<String, dynamic> json) =>
      _$SHORegionChildrenResultFromJson(json);
}

@freezed
class SHOAddressRegionSelection with _$SHOAddressRegionSelection {
  const SHOAddressRegionSelection._();

  const factory SHOAddressRegionSelection({
    @Default('') String countryCode,
    @Default('') String countryName,
    @Default('') String regionL2Code,
    @Default('') String regionL2Name,
    @Default('') String regionL3Code,
    @Default('') String regionL3Name,
    @Default('') String regionL4Code,
    @Default('') String regionL4Name,
  }) = _SHOAddressRegionSelection;

  bool isCompleteFor(SHORegionCountryConfig config) {
    if (countryCode.isEmpty) return false;
    if (config.requiredLevels.contains(2) && regionL2Code.isEmpty) {
      return false;
    }
    if (config.requiredLevels.contains(3) && regionL3Code.isEmpty) {
      return false;
    }
    if (config.requiredLevels.contains(4) && regionL4Code.isEmpty) {
      return false;
    }
    return true;
  }

  String summary({String separator = ' '}) {
    final parts = <String>[
      if (countryName.isNotEmpty) countryName,
      if (regionL2Name.isNotEmpty) regionL2Name,
      if (regionL3Name.isNotEmpty) regionL3Name,
      if (regionL4Name.isNotEmpty) regionL4Name,
    ];
    return parts.join(separator);
  }
}