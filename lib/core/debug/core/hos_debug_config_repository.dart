import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/hos_config.dart';
import '../../storage/hos_local_storage.dart';
import '../modules/activity/hos_debug_activity_config.dart';
import '../modules/update/hos_debug_update_config.dart';

const debugUpdateConfigKey = 'debug_update_config_v1';
const debugActivityConfigKey = 'debug_activity_config_v1';

final debugConfigRepositoryProvider = Provider<SHODebugConfigRepository>((ref) {
  return SHODebugConfigRepository(
    ref.watch(localStorageProvider),
    debugEnabled: SHOAppConfig.instance.isDebugPanelEnabled,
  );
});

/// 调试配置持久化：Release 包不读不写。
class SHODebugConfigRepository {
  SHODebugConfigRepository(this._storage, {required this.debugEnabled});

  final SHOLocalStorage _storage;
  final bool debugEnabled;

  Future<SHODebugUpdateConfig> loadUpdateConfig() async {
    if (!debugEnabled) return const SHODebugUpdateConfig();
    final raw = await _storage.read<String>(debugUpdateConfigKey);
    if (raw == null || raw.isEmpty) return const SHODebugUpdateConfig();
    try {
      return SHODebugUpdateConfig.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const SHODebugUpdateConfig();
    }
  }

  Future<void> saveUpdateConfig(SHODebugUpdateConfig config) async {
    if (!debugEnabled) return;
    await _storage.write(debugUpdateConfigKey, jsonEncode(config.toJson()));
  }

  Future<SHODebugActivityConfig> loadActivityConfig() async {
    if (!debugEnabled) return const SHODebugActivityConfig();
    final raw = await _storage.read<String>(debugActivityConfigKey);
    if (raw == null || raw.isEmpty) return const SHODebugActivityConfig();
    try {
      return SHODebugActivityConfig.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const SHODebugActivityConfig();
    }
  }

  Future<void> saveActivityConfig(SHODebugActivityConfig config) async {
    if (!debugEnabled) return;
    await _storage.write(debugActivityConfigKey, jsonEncode(config.toJson()));
  }
}
