import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/hos_constants.dart';
import '../../../core/storage/hos_local_storage.dart';
import '../domain/hos_address.dart';
import 'hos_address_api.dart';
import 'hos_address_storage.dart';

final addressRepositoryProvider = Provider<SHOAddressRepository>((ref) {
  return SHOAddressRepository(
    ref.watch(addressApiProvider),
    ref.watch(localStorageProvider),
    ref.watch(addressStorageProvider),
  );
});

class SHOAddressRepository {
  SHOAddressRepository(this._api, this._selectionStorage, this._addressStorage);

  final SHOAddressApi _api;
  final SHOLocalStorage _selectionStorage;
  final SHOAddressStorage _addressStorage;

  Future<List<SHOAddress>> getAddresses() async {
    final cached = _addressStorage.read();
    if (cached != null && cached.isNotEmpty) return cached;

    final remote = await _api.fetchAddresses();
    await _addressStorage.write(remote);
    return remote;
  }

  Future<void> upsertAddress(SHOAddress address) async {
    final list = List<SHOAddress>.from(await getAddresses());
    final index = list.indexWhere((item) => item.id == address.id);

    if (index >= 0) {
      list[index] = address;
    } else {
      list.add(address);
    }

    final normalized = address.isDefault ? _normalizeDefault(list, address) : list;
    await _addressStorage.write(normalized);
  }

  Future<void> deleteAddress(String id) async {
    final list = List<SHOAddress>.from(await getAddresses())
      ..removeWhere((item) => item.id == id);

    if (list.isEmpty) {
      await _addressStorage.write(const []);
      await _selectionStorage.remove(SHOAppConstants.selectedAddressIdKey);
      return;
    }

    if (!list.any((item) => item.isDefault)) {
      list[0] = list.first.copyWith(isDefault: true);
    }

    await _addressStorage.write(list);

    final selectedId =
        await _selectionStorage.read<String>(SHOAppConstants.selectedAddressIdKey);
    if (selectedId == id) {
      final fallback = list.firstWhere(
        (item) => item.isDefault,
        orElse: () => list.first,
      );
      await _selectionStorage.write(
        SHOAppConstants.selectedAddressIdKey,
        fallback.id,
      );
    }
  }

  Future<String?> getSelectedAddressId() =>
      _selectionStorage.read<String>(SHOAppConstants.selectedAddressIdKey);

  Future<void> setSelectedAddressId(String id) =>
      _selectionStorage.write(SHOAppConstants.selectedAddressIdKey, id);

  List<SHOAddress> _normalizeDefault(
    List<SHOAddress> list,
    SHOAddress incoming,
  ) {
    if (!incoming.isDefault) return list;
    return [
      for (final item in list)
        item.copyWith(isDefault: item.id == incoming.id),
    ];
  }
}
