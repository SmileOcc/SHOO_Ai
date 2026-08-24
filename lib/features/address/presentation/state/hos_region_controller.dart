import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/address/data/datasources/remote/hos_region_remote_ds.dart';
import 'package:shoo/features/address/domain/entities/hos_region_node.dart';

final regionCountriesProvider = FutureProvider<List<SHORegionNode>>((ref) {
  return ref.watch(regionApiProvider).fetchCountries();
});

final regionMetaCountriesProvider =
    FutureProvider<List<SHORegionCountryConfig>>((ref) {
  return ref.watch(regionApiProvider).fetchMetaCountries();
});

final regionChildrenProvider = FutureProvider.family<
    SHORegionChildrenResult,
    ({String countryCode, String parentCode})>((ref, query) {
  return ref.watch(regionApiProvider).fetchChildren(
        countryCode: query.countryCode,
        parentCode: query.parentCode.isEmpty ? null : query.parentCode,
      );
});
