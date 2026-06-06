import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/hos_config.dart';
import '../../app/router/hos_routes.dart';

/// 连点 5 次进入 Debug 面板（仅非 Release 包生效）。
///
/// 使用 [SHODebugTapAppBar] 包裹顶部导航栏，或 [SHODebugTapDetector] 包裹任意区域。
/// 采用透明 Listener 计数，不拦截子组件点击。
class SHODebugTapDetector extends StatefulWidget {
  const SHODebugTapDetector({super.key, required this.child});

  final Widget child;

  @override
  State<SHODebugTapDetector> createState() => _SHODebugTapDetectorState();
}

class _SHODebugTapDetectorState extends State<SHODebugTapDetector> {
  int _tapCount = 0;
  DateTime? _firstTap;

  void _registerTap() {
    if (!SHOAppConfig.instance.isDebugPanelEnabled) return;

    final now = DateTime.now();
    if (_firstTap == null || now.difference(_firstTap!) > const Duration(seconds: 3)) {
      _tapCount = 0;
      _firstTap = now;
    }
    _tapCount++;
    if (_tapCount >= 5) {
      _tapCount = 0;
      _firstTap = null;
      context.push(SHOAppRoutes.debug);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!SHOAppConfig.instance.isDebugPanelEnabled) return widget.child;

    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => _registerTap(),
          ),
        ),
      ],
    );
  }
}

/// AppBar 专用包装：在顶部导航栏任意位置连点 5 次进入 Debug。
class SHODebugTapAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SHODebugTapAppBar({super.key, required this.appBar});

  final PreferredSizeWidget appBar;

  @override
  Size get preferredSize => appBar.preferredSize;

  @override
  Widget build(BuildContext context) {
    return SHODebugTapDetector(child: appBar);
  }
}
