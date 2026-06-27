import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/analytics/hos_page_route_analytics_mixin.dart';
import 'package:shoo/core/pages/hos_app_page_mixin.dart';
import 'package:shoo/core/pages/hos_page_error_boundary.dart';

/// 复杂业务页（非单一 [AsyncValue]）统一：埋点 + `page_load_time` + ErrorBoundary。
///
/// ```dart
/// class _State extends ConsumerState<MyPage>
///     with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
///   @override
///   String get pageName => 'my_page';
///
///   @override
///   Widget build(BuildContext context) {
///     return buildTrackedPage(Scaffold(...));
///   }
/// }
/// ```
mixin SHOAppTrackedPageMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T>, SHOPageRouteAnalyticsMixin<T>, SHOAppPageMixin<T> {
  Widget buildTrackedPage(Widget body, {VoidCallback? onRetry}) {
    return SHOPageErrorBoundary(
      pageName: pageName,
      onRetry: onRetry,
      child: body,
    );
  }
}
