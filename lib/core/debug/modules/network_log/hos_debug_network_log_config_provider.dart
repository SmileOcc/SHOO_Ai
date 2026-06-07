import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/hos_debug_config_repository.dart';
import 'hos_debug_network_log_config.dart';
import 'hos_debug_network_log_config_bridge.dart';

final debugNetworkLogConfigProvider =
    StateNotifierProvider<SHODebugNetworkLogConfigNotifier, SHODebugNetworkLogConfig>(
  (ref) {
    return SHODebugNetworkLogConfigNotifier(ref.watch(debugConfigRepositoryProvider));
  },
);

class SHODebugNetworkLogConfigNotifier extends StateNotifier<SHODebugNetworkLogConfig> {
  SHODebugNetworkLogConfigNotifier(this._repo)
      : super(const SHODebugNetworkLogConfig()) {
    restore();
  }

  final SHODebugConfigRepository _repo;

  Future<void> restore() async {
    state = await _repo.loadNetworkLogConfig();
    SHODebugNetworkLogConfigBridge.update(state);
  }

  Future<void> save(SHODebugNetworkLogConfig config) async {
    state = config;
    SHODebugNetworkLogConfigBridge.update(config);
    await _repo.saveNetworkLogConfig(config);
  }
}
