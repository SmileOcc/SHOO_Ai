import 'package:flutter/material.dart';

import 'hos_page_route_analytics_mixin.dart';

/// 为 [StatelessWidget] 页面包裹 [RouteAware] 埋点，无需改写为 StatefulWidget。
///
/// ```dart
/// return SHOPageAnalyticsBinder(
///   pageName: 'study_home',
///   child: Scaffold(...),
/// );
/// ```
class SHOPageAnalyticsBinder extends StatefulWidget {
  const SHOPageAnalyticsBinder({
    super.key,
    required this.pageName,
    required this.child,
    this.extra = const {},
  });

  final String pageName;
  final Widget child;
  final Map<String, Object?> extra;

  @override
  State<SHOPageAnalyticsBinder> createState() => _SHOPageAnalyticsBinderState();
}

class _SHOPageAnalyticsBinderState extends State<SHOPageAnalyticsBinder>
    with SHOPageRouteAnalyticsMixin {
  @override
  String get pageAnalyticsName => widget.pageName;

  @override
  Map<String, Object?> get pageAnalyticsExtra => widget.extra;

  @override
  Widget build(BuildContext context) => widget.child;
}
