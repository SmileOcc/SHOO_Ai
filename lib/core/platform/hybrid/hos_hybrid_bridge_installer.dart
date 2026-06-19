import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/platform/hybrid/hos_hybrid_bridge.dart';
import 'package:shoo/core/platform/hybrid/hos_hybrid_native_overlay_provider.dart';

/// 在应用根部挂载，确保 [SHOHybridBridge] 宿主通道已注册。
class SHOHybridBridgeInstaller extends ConsumerStatefulWidget {
  const SHOHybridBridgeInstaller({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SHOHybridBridgeInstaller> createState() =>
      _SHOHybridBridgeInstallerState();
}

class _SHOHybridBridgeInstallerState
    extends ConsumerState<SHOHybridBridgeInstaller> {
  @override
  void initState() {
    super.initState();
    SHOHybridBridge.install();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(hybridOverlayRouteListenerProvider);
    return widget.child;
  }
}
