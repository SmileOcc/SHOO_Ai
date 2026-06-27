import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/analytics/hos_page_route_analytics_mixin.dart';
import 'package:shoo/core/analytics/hos_page_route_info.dart';
import 'package:shoo/core/pages/hos_app_page_mixin.dart';
import 'package:shoo/core/pages/hos_app_shell_page.dart';
import 'package:shoo/core/pages/hos_page_error_boundary.dart';
import 'package:shoo/core/pages/hos_page_load_reporter.dart';
import 'package:shoo/core/widgets/hos_loading_state.dart';

/// 基于 Riverpod [AsyncValue] 的数据驱动页面基类。
abstract class SHODataPage<T> extends ConsumerStatefulWidget {
  const SHODataPage({super.key});
}

abstract class SHODataPageState<T, W extends SHODataPage<T>>
    extends ConsumerState<W> with SHOPageRouteAnalyticsMixin<W>, SHOAppPageMixin<W> {
  ProviderListenable<AsyncValue<T>> get dataProvider;

  void invalidateData(WidgetRef ref);

  bool isEmptyData(T data) => false;

  Widget buildContent(BuildContext context, WidgetRef ref, T data);

  Widget? buildLoading(BuildContext context) => null;

  PreferredSizeWidget? buildPageAppBar(BuildContext context, WidgetRef ref) => null;

  /// 是否上报 [SHOPageLoadPhase.contentReady]。
  bool get reportContentReadyLoadTime => true;

  Stopwatch? _contentReadyStopwatch;
  var _contentReadyReported = false;

  SHOAppShellPage buildShell(
    BuildContext context,
    WidgetRef ref, {
    required PreferredSizeWidget? appBar,
    required Widget body,
  }) {
    return SHOAppShellPage(appBar: appBar, body: body);
  }

  @override
  void didPush() {
    if (reportContentReadyLoadTime) {
      _contentReadyStopwatch = Stopwatch()..start();
    }
    super.didPush();
  }

  Widget _wrapContent(BuildContext context, WidgetRef ref, T value) {
    _scheduleContentReadyReport();
    return buildContent(context, ref, value);
  }

  void _scheduleContentReadyReport() {
    if (!reportContentReadyLoadTime || _contentReadyReported) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _contentReadyReported || _contentReadyStopwatch == null) {
        return;
      }
      _contentReadyReported = true;
      _contentReadyStopwatch!.stop();
      final info = SHOPageRouteInfo.tryFromContext(context, pageName: pageName);
      SHOPageLoadReporter.report(
        pageName: pageName,
        durationMs: _contentReadyStopwatch!.elapsedMilliseconds,
        phase: SHOPageLoadPhase.contentReady,
        routePath: info?.routePath,
        extra: pageAnalyticsExtra,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SHOPageErrorBoundary(
      pageName: pageName,
      onRetry: () => invalidateData(ref),
      child: _buildPage(context),
    );
  }

  Widget _buildPage(BuildContext context) {
    final body = ref.watch(dataProvider).whenLoadingState(
          data: (value) => _wrapContent(context, ref, value),
          onRetry: () => invalidateData(ref),
          empty: isEmptyData,
          loading: buildLoading(context),
        );

    final appBar = buildPageAppBar(context, ref);
    if (appBar == null) return body;

    return buildShell(context, ref, appBar: appBar, body: body);
  }
}
