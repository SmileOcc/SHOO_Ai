import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/hos_constants.dart';
import '../../../core/storage/hos_local_storage.dart';
import '../domain/hos_address.dart';
import 'hos_address_api.dart';

final addressRepositoryProvider = Provider<SHOAddressRepository>((ref) {
  return SHOAddressRepository(
    ref.watch(addressApiProvider),
    ref.watch(localStorageProvider),
  );
});

class SHOAddressRepository {
  SHOAddressRepository(this._api, this._storage);

  final SHOAddressApi _api;
  final SHOLocalStorage _storage;

  Future<List<SHOAddress>> getAddresses() => _api.fetchAddresses();

  Future<String?> getSelectedAddressId() =>
      _storage.read<String>(SHOAppConstants.selectedAddressIdKey);

  Future<void> setSelectedAddressId(String id) =>
      _storage.write(SHOAppConstants.selectedAddressIdKey, id);
}
