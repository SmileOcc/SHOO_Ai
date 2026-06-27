import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_models.dart';

/// 抢购关注本地缓存，登录后与服务器同步。
class SHOFlashSaleFollowStorage {
  SHOFlashSaleFollowStorage(this._prefs);

  static const _storageKey = 'flash_sale_follows_v1';

  final SharedPreferences _prefs;

  List<SHOFlashSaleFollow> readAll() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(SHOFlashSaleFollow.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> writeAll(List<SHOFlashSaleFollow> follows) async {
    final encoded = jsonEncode(follows.map((f) => f.toJson()).toList());
    await _prefs.setString(_storageKey, encoded);
  }

  Future<void> clear() => _prefs.remove(_storageKey);
}
