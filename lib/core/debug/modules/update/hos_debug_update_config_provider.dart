import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/hos_debug_config_repository.dart';
import 'hos_debug_update_config.dart';

final debugUpdateConfigProvider =
    StateNotifierProvider<SHODebugUpdateConfigNotifier, SHODebugUpdateConfig>((ref) {
  return SHODebugUpdateConfigNotifier(ref.watch(debugConfigRepositoryProvider));
});

class SHODebugUpdateConfigNotifier extends StateNotifier<SHODebugUpdateConfig> {
  SHODebugUpdateConfigNotifier(this._repo) : super(const SHODebugUpdateConfig()) {
    restore();
  }

  final SHODebugConfigRepository _repo;

  Future<void> restore() async {
    state = await _repo.loadUpdateConfig();
  }

  void update(SHODebugUpdateConfig config) => state = config;

  Future<void> save(SHODebugUpdateConfig config) async {
    state = config;
    await _repo.saveUpdateConfig(config);
  }
}
