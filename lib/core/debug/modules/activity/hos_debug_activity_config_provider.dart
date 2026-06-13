import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../marketing/hos_activity_prefetch_service.dart';
import '../../core/hos_debug_config_repository.dart';
import 'hos_debug_activity_config.dart';

final debugActivityConfigProvider =
    NotifierProvider<SHODebugActivityConfigNotifier, SHODebugActivityConfig>(
  SHODebugActivityConfigNotifier.new,
);

class SHODebugActivityConfigNotifier extends Notifier<SHODebugActivityConfig> {
  late final SHODebugConfigRepository _repo;

  @override
  SHODebugActivityConfig build() {
    _repo = ref.read(debugConfigRepositoryProvider);
    Future.microtask(_restore);
    return const SHODebugActivityConfig();
  }

  Future<void> _restore() async {
    state = await _repo.loadActivityConfig();
  }

  void update(SHODebugActivityConfig config) => state = config;

  Future<void> save(SHODebugActivityConfig config) async {
    state = config;
    await _repo.saveActivityConfig(config);
    if (config.prefetchEnabled && config.overrideEnabled) {
      await ref.read(activityPrefetchServiceProvider).prefetchFromDebug(config);
    }
  }
}
