import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/hos_address_repository.dart';
import '../domain/hos_address.dart';

final addressesProvider = FutureProvider<List<SHOAddress>>((ref) async {
  final repo = ref.watch(addressRepositoryProvider);
  return repo.getAddresses();
});

Future<void> refreshAddresses(WidgetRef ref) async {
  ref.invalidate(addressesProvider);
  await ref.read(addressesProvider.future);
}

Future<void> saveAddress(WidgetRef ref, SHOAddress address) async {
  await ref.read(addressRepositoryProvider).upsertAddress(address);
  await refreshAddresses(ref);
}

Future<void> deleteAddress(WidgetRef ref, String id) async {
  await ref.read(addressRepositoryProvider).deleteAddress(id);
  await refreshAddresses(ref);
  await ref.read(selectedAddressIdProvider.notifier).restore();
}

final selectedAddressIdProvider =
    StateNotifierProvider<SHOSelectedAddressNotifier, String?>((ref) {
  final notifier = SHOSelectedAddressNotifier(ref.watch(addressRepositoryProvider));
  Future.microtask(notifier.restore);
  return notifier;
});

class SHOSelectedAddressNotifier extends StateNotifier<String?> {
  SHOSelectedAddressNotifier(this._repo) : super(null);

  final SHOAddressRepository _repo;

  Future<void> restore() async {
    state = await _repo.getSelectedAddressId();
  }

  Future<void> select(String id) async {
    state = id;
    await _repo.setSelectedAddressId(id);
  }
}

final selectedAddressProvider = Provider<AsyncValue<SHOAddress?>>((ref) {
  final addressesAsync = ref.watch(addressesProvider);
  final selectedId = ref.watch(selectedAddressIdProvider);

  return addressesAsync.whenData((list) {
    if (list.isEmpty) return null;
    if (selectedId != null) {
      final match = list.where((a) => a.id == selectedId);
      if (match.isNotEmpty) return match.first;
    }
    final defaultAddr = list.where((a) => a.isDefault);
    return defaultAddr.isNotEmpty ? defaultAddr.first : list.first;
  });
});
