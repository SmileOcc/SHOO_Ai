import 'package:shoo/features/address/domain/entities/hos_address.dart';
import 'package:shoo/features/address/domain/entities/hos_region_node.dart';

extension SHOAddressRegionSelectionX on SHOAddress {
  SHOAddressRegionSelection get regionSelection => SHOAddressRegionSelection(
        countryCode: countryCode,
        countryName: countryName,
        regionL2Code: regionL2Code,
        regionL2Name: regionL2Name.isNotEmpty ? regionL2Name : region,
        regionL3Code: regionL3Code,
        regionL3Name: regionL3Name.isNotEmpty ? regionL3Name : city,
        regionL4Code: regionL4Code,
        regionL4Name: regionL4Name,
      );
}

extension SHOAddressRegionApplyX on SHOAddressRegionSelection {
  SHOAddress applyTo(SHOAddress base) {
    return base.copyWith(
      countryCode: countryCode,
      countryName: countryName,
      regionL2Code: regionL2Code,
      regionL2Name: regionL2Name,
      regionL3Code: regionL3Code,
      regionL3Name: regionL3Name,
      regionL4Code: regionL4Code,
      regionL4Name: regionL4Name,
      city: regionL3Name,
      region: regionL2Name,
      needsRegionReselect: false,
    );
  }
}
