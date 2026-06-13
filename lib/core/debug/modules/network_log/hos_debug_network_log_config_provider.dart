import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/hos_debug_config_repository.dart';
import 'hos_debug_network_log_config.dart';
import 'hos_debug_network_log_config_bridge.dart';

final debugNetworkLogConfigProvider =
    NotifierProvider<SHODebugNetworkLogConfigNotifier, SHODebugNetworkLogConfig>(
  SHODebugNetworkLogConfigNotifier.new,
);

class SHODebugNetworkLogConfigNotifier extends Notifier<SHODebugNetworkLogConfig> {
  late final SHODebugConfigRepository _repo;

  @override
  SHODebugNetworkLogConfig build() {
    _repo = ref.read(debugConfigRepositoryProvider);
    Future.microtask(restore);
    return const SHODebugNetworkLogConfig();
  }

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
