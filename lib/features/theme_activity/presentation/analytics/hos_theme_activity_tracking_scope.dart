import 'package:flutter/widgets.dart';

/// 主题活动页埋点上下文（activityId / channel / tracking 前缀）。
class SHOThemeActivityTrackingScope extends InheritedWidget {
  const SHOThemeActivityTrackingScope({
    super.key,
    required this.activityId,
    this.channel,
    this.trackingPrefix,
    required super.child,
  });

  final String activityId;
  final String? channel;
  final String? trackingPrefix;

  static SHOThemeActivityTrackingScope? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SHOThemeActivityTrackingScope>();
  }

  @override
  bool updateShouldNotify(SHOThemeActivityTrackingScope oldWidget) {
    return activityId != oldWidget.activityId ||
        channel != oldWidget.channel ||
        trackingPrefix != oldWidget.trackingPrefix;
  }
}
