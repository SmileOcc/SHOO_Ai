import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/hos_address_repository.dart';
import '../domain/hos_address.dart';

/// 全局地址列表；checkout / 表单与列表页共享，离开列表页不销毁。
final addressesProvider =
    AsyncNotifierProvider<SHOAddressesNotifier, List<SHOAddress>>(
  SHOAddressesNotifier.new,
);

// AsyncNotifier 自动处理加载、错误、数据状态
class SHOAddressesNotifier extends AsyncNotifier<List<SHOAddress>> {
  SHOAddressRepository get _repo => ref.read(addressRepositoryProvider);

  @override
  Future<List<SHOAddress>> build() => _repo.getAddresses();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _repo.getAddresses());
  }

  Future<void> save(SHOAddress address) async {
    await _repo.upsertAddress(address);
    state = AsyncData(await _repo.getAddresses());
  }

  Future<void> delete(String id) async {
    await _repo.deleteAddress(id);
    await ref.read(selectedAddressIdProvider.notifier).restore();
    state = AsyncData(await _repo.getAddresses());
  }
}

/// 地址列表页删除模式，页面离开后自动重置。
final addressListDeleteModeProvider = StateProvider.autoDispose<bool>((ref) => false);

final selectedAddressIdProvider =
    NotifierProvider<SHOSelectedAddressNotifier, String?>(
  SHOSelectedAddressNotifier.new,
);

class SHOSelectedAddressNotifier extends Notifier<String?> {
  late final SHOAddressRepository _repo;

  @override
  String? build() {
    _repo = ref.read(addressRepositoryProvider);
    Future.microtask(restore);
    return null;
  }

  Future<void> restore() async {
    state = await _repo.getSelectedAddressId();
  }

  Future<void> select(String id) async {
    state = id;
    await _repo.setSelectedAddressId(id);
  }
}

//全局 Provider 全局持久状态
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

/// 按 ID 查询地址，编辑页与 checkout 派生展示共用。
final addressByIdProvider =
    Provider.family<AsyncValue<SHOAddress?>, String>((ref, id) {
  final addressesAsync = ref.watch(addressesProvider);
  return addressesAsync.whenData((list) {
    final matches = list.where((a) => a.id == id);
    return matches.isEmpty ? null : matches.first;
  });
});
