import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/hos_constants.dart';
import '../../../core/storage/hos_local_storage.dart';
import '../domain/hos_address.dart';

final addressStorageProvider = Provider<SHOAddressStorage>((ref) {
  return SHOAddressStorage(ref.watch(sharedPreferencesProvider));
});

class SHOAddressStorage {
  SHOAddressStorage(this._prefs);

  final SharedPreferences _prefs;

  List<SHOAddress>? read() {
    final raw = _prefs.getString(SHOAppConstants.addressesStorageKey);
    if (raw == null || raw.isEmpty) return null;
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => SHOAddress.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> write(List<SHOAddress> addresses) async {
    final encoded = jsonEncode(addresses.map((a) => a.toJson()).toList());
    await _prefs.setString(SHOAppConstants.addressesStorageKey, encoded);
  }
}
