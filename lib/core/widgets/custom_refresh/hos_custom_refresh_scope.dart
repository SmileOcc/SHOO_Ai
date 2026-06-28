import 'package:flutter/material.dart';

import 'package:shoo/core/widgets/custom_refresh/hos_custom_refresh_controller.dart';

/// [SHOAppCustomRefresh] 向 [SHOAppCustomRefreshSliver.header] 传递配置。
class SHOAppCustomRefreshScope extends InheritedWidget {
  const SHOAppCustomRefreshScope({
    super.key,
    required this.refreshTriggerOffset,
    this.headerBuilder,
    required super.child,
  });

  final double refreshTriggerOffset;
  final Widget Function(
    BuildContext context,
    SHOAppCustomRefreshStatus status,
    double pullProgress,
  )?
  headerBuilder;

  static SHOAppCustomRefreshScope? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SHOAppCustomRefreshScope>();
  }

  @override
  bool updateShouldNotify(SHOAppCustomRefreshScope oldWidget) {
    return refreshTriggerOffset != oldWidget.refreshTriggerOffset ||
        headerBuilder != oldWidget.headerBuilder;
  }
}
