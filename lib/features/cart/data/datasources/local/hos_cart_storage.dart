import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/constants/hos_constants.dart';
import 'package:shoo/core/storage/key_value/hos_local_storage.dart';
import 'package:shoo/features/cart/domain/entities/hos_cart.dart';

final cartStorageProvider = Provider<SHOCartStorage>((ref) {
  return SHOCartStorage(ref.watch(localStorageProvider));
});

class SHOCartStorage {
  SHOCartStorage(this._storage);

  final SHOLocalStorage _storage;

  Future<SHOCartSnapshot> load() async {
    final raw = await _storage.read<String>(SHOAppConstants.cartStorageKey);
    if (raw == null || raw.isEmpty) return const SHOCartSnapshot();
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return SHOCartSnapshot.fromJson(json);
    } catch (_) {
      return const SHOCartSnapshot();
    }
  }

  Future<void> save(SHOCartSnapshot snapshot) async {
    await _storage.write(
      SHOAppConstants.cartStorageKey,
      jsonEncode(snapshot.toJson()),
    );
  }

  Future<void> clear() =>
      _storage.write<String>(SHOAppConstants.cartStorageKey, '');
}
