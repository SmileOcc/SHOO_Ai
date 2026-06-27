import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/analytics/hos_page_route_analytics_mixin.dart';
import 'package:shoo/core/analytics/hos_page_route_info.dart';
import 'package:shoo/core/pages/hos_page_load_reporter.dart';

/// 页面通用 Mixin：在 [SHOPageRouteAnalyticsMixin] 之上增加业务生命周期 hook。
///
/// 用法（与 [SHOPageRouteAnalyticsMixin] 一起混入 [ConsumerState]）：
///
/// ```dart
/// class _MyPageState extends ConsumerState<MyPage>
///     with SHOPageRouteAnalyticsMixin, SHOAppPageMixin {
///   @override
///   String get pageName => 'my_page';
/// }
/// ```
mixin SHOAppPageMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T>, SHOPageRouteAnalyticsMixin<T> {
  /// 业务页面名，默认 Widget 类型名；同时作为 [pageAnalyticsName]。
  String get pageName => widget.runtimeType.toString();

  @override
  String get pageAnalyticsName => pageName;

  /// 是否上报 [SHOPageLoadPhase.firstFrame] 耗时。
  bool get reportFirstFrameLoadTime => true;

  Stopwatch? _firstFrameStopwatch;
  var _firstFrameReported = false;

  /// 页面首次可见（[RouteAware.didPush]）后调用，适合预加载 / invalidate。
  @protected
  void onPagePreload(WidgetRef ref) {}

  /// 上层路由 pop 后页面恢复可见（[RouteAware.didPopNext]）时调用。
  @protected
  void onPageResumeVisible(WidgetRef ref) {}

  @override
  void didPush() {
    if (reportFirstFrameLoadTime) {
      _firstFrameStopwatch = Stopwatch()..start();
    }
    super.didPush();
    onPagePreload(ref);
    if (reportFirstFrameLoadTime) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _reportFirstFrameLoad());
    }
  }

  @override
  void didPopNext() {
    super.didPopNext();
    onPageResumeVisible(ref);
  }

  void _reportFirstFrameLoad() {
    if (!mounted || _firstFrameReported || _firstFrameStopwatch == null) return;
    _firstFrameReported = true;
    _firstFrameStopwatch!.stop();

    final info = SHOPageRouteInfo.tryFromContext(context, pageName: pageName);
    SHOPageLoadReporter.report(
      pageName: pageName,
      durationMs: _firstFrameStopwatch!.elapsedMilliseconds,
      phase: SHOPageLoadPhase.firstFrame,
      routePath: info?.routePath,
      extra: pageAnalyticsExtra,
    );
  }
}
