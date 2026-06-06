import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../marketing/hos_activity_prefetch_service.dart';
import '../../core/hos_debug_config_repository.dart';
import 'hos_debug_activity_config.dart';

final debugActivityConfigProvider =
    StateNotifierProvider<SHODebugActivityConfigNotifier, SHODebugActivityConfig>((ref) {
  return SHODebugActivityConfigNotifier(
    ref.watch(debugConfigRepositoryProvider),
    ref,
  );
});

class SHODebugActivityConfigNotifier extends StateNotifier<SHODebugActivityConfig> {
  SHODebugActivityConfigNotifier(this._repo, this._ref)
      : super(const SHODebugActivityConfig()) {
    _restore();
  }

  final SHODebugConfigRepository _repo;
  final Ref _ref;

  Future<void> _restore() async {
    state = await _repo.loadActivityConfig();
  }

  void update(SHODebugActivityConfig config) => state = config;

  Future<void> save(SHODebugActivityConfig config) async {
    state = config;
    await _repo.saveActivityConfig(config);
    if (config.prefetchEnabled && config.overrideEnabled) {
      await _ref.read(activityPrefetchServiceProvider).prefetchFromDebug(config);
    }
  }
}
