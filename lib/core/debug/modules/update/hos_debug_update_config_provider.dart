import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/hos_debug_config_repository.dart';
import 'hos_debug_update_config.dart';

final debugUpdateConfigProvider =
    NotifierProvider<SHODebugUpdateConfigNotifier, SHODebugUpdateConfig>(
  SHODebugUpdateConfigNotifier.new,
);

class SHODebugUpdateConfigNotifier extends Notifier<SHODebugUpdateConfig> {
  late final SHODebugConfigRepository _repo;

  @override
  SHODebugUpdateConfig build() {
    _repo = ref.read(debugConfigRepositoryProvider);
    Future.microtask(restore);
    return const SHODebugUpdateConfig();
  }

  Future<void> restore() async {
    state = await _repo.loadUpdateConfig();
  }

  void update(SHODebugUpdateConfig config) => state = config;

  Future<void> save(SHODebugUpdateConfig config) async {
    state = config;
    await _repo.saveUpdateConfig(config);
  }
}
