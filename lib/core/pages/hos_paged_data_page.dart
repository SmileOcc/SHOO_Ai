import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/analytics/hos_page_route_info.dart';
import 'package:shoo/core/analytics/hos_page_route_analytics_mixin.dart';
import 'package:shoo/core/pages/hos_app_page_mixin.dart';
import 'package:shoo/core/pages/hos_app_tracked_page_mixin.dart';
import 'package:shoo/core/pages/hos_page_error_boundary.dart';
import 'package:shoo/core/pages/hos_page_load_reporter.dart';
import 'package:shoo/core/pagination/hos_paged_container.dart';
import 'package:shoo/core/widgets/hos_loading_state.dart';
import 'package:shoo/core/widgets/hos_paged_scroll_view.dart';

/// 基于 [AsyncValue] + [SHOPagedContainer] 的分页列表页基类。
abstract class SHOPagedDataPage<T> extends ConsumerStatefulWidget {
  const SHOPagedDataPage({super.key});
}

abstract class SHOPagedDataPageState<
  T,
  P extends SHOPagedContainer<T>,
  W extends SHOPagedDataPage<T>
>
    extends ConsumerState<W>
    with
        SHOPageRouteAnalyticsMixin<W>,
        SHOAppPageMixin<W>,
        SHOAppTrackedPageMixin {
  ProviderListenable<AsyncValue<P>> get pagedProvider;

  void refreshPaged(WidgetRef ref);

  void loadMorePaged(WidgetRef ref);

  void invalidatePaged(WidgetRef ref) => refreshPaged(ref);

  /// 嵌入 Tab 等父级 [Scaffold] 时设为 false，避免重复 ErrorBoundary / Tracked 包装。
  bool get embedInParentShell => false;

  bool get reportContentReadyLoadTime => true;

  PreferredSizeWidget? buildPageAppBar(BuildContext context, WidgetRef ref) =>
      null;

  Widget? buildListHeader(BuildContext context, WidgetRef ref, P paged) => null;

  Widget? buildLoading(BuildContext context) => null;

  String? emptyMessage(BuildContext context) => null;

  IconData? get emptyIcon => null;

  ScrollController? get scrollController => null;

  IndexedWidgetBuilder? get separatorBuilder => null;

  /// 非 null 时使用 [SHOPagedGridView] 替代默认列表。
  SliverGridDelegate? get gridDelegate => null;

  Widget? buildFloatingActionButton(BuildContext context, WidgetRef ref) =>
      null;

  Widget buildPagedItem(BuildContext context, WidgetRef ref, T item, int index);

  /// 展示前过滤/映射分页数据（如订单 Tab 客户端筛选）。
  P transformPaged(P paged) => paged;

  bool get enableLoadMore => true;

  Stopwatch? _contentReadyStopwatch;
  var _contentReadyReported = false;
  ScrollController? _fallbackScrollController;

  ScrollController get _effectiveScrollController =>
      scrollController ?? (_fallbackScrollController ??= ScrollController());

  @override
  void dispose() {
    if (scrollController == null) {
      _fallbackScrollController?.dispose();
    }
    super.dispose();
  }

  @override
  void didPush() {
    if (reportContentReadyLoadTime) {
      _contentReadyStopwatch = Stopwatch()..start();
    }
    super.didPush();
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
    final page = embedInParentShell
        ? _buildPagedBody(context)
        : buildTrackedPage(
            _buildPagedBody(context),
            onRetry: () => invalidatePaged(ref),
          );

    if (embedInParentShell) {
      return SHOPageErrorBoundary(
        pageName: pageName,
        onRetry: () => invalidatePaged(ref),
        child: page,
      );
    }
    return page;
  }

  Widget _buildPagedBody(BuildContext context) {
    final body = ref
        .watch(pagedProvider)
        .when(
          loading: () =>
              buildLoading(context) ??
              const SHOAppLoadingState(
                state: SHOLoadingState.loading,
                loadingWidget: SHOAppListSkeleton(itemCount: 6),
              ),
          error: (error, _) => SHOAppLoadingState(
            state: SHOLoadingState.error,
            message: error.toString(),
            onRetry: () => invalidatePaged(ref),
          ),
          data: (raw) {
            final paged = transformPaged(raw);
            if (paged.pagedItems.isEmpty) {
              return SHOAppLoadingState(
                state: SHOLoadingState.empty,
                message: emptyMessage(context) ?? '',
                emptyIcon: emptyIcon ?? Icons.inbox_outlined,
              );
            }
            _scheduleContentReadyReport();
            final header = buildListHeader(context, ref, paged);
            final list = gridDelegate != null
                ? SHOPagedGridView(
                    controller: _effectiveScrollController,
                    itemCount: paged.pagedItems.length,
                    onRefresh: () async => refreshPaged(ref),
                    onLoadMore: enableLoadMore && paged.pagedHasMore
                        ? () => loadMorePaged(ref)
                        : null,
                    isLoadingMore: paged.pagedIsLoadingMore,
                    hasMore: enableLoadMore && paged.pagedHasMore,
                    gridDelegate: gridDelegate!,
                    itemBuilder: (context, index) => buildPagedItem(
                      context,
                      ref,
                      paged.pagedItems[index],
                      index,
                    ),
                  )
                : SHOPagedScrollView(
                    controller: _effectiveScrollController,
                    itemCount: paged.pagedItems.length,
                    onRefresh: () async => refreshPaged(ref),
                    onLoadMore: enableLoadMore && paged.pagedHasMore
                        ? () => loadMorePaged(ref)
                        : null,
                    isLoadingMore: paged.pagedIsLoadingMore,
                    hasMore: enableLoadMore && paged.pagedHasMore,
                    separatorBuilder: separatorBuilder,
                    itemBuilder: (context, index) => buildPagedItem(
                      context,
                      ref,
                      paged.pagedItems[index],
                      index,
                    ),
                  );
            if (header == null) return list;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                Expanded(child: list),
              ],
            );
          },
        );

    final appBar = buildPageAppBar(context, ref);
    final fab = buildFloatingActionButton(context, ref);
    if (appBar == null && fab == null) return body;

    return Scaffold(appBar: appBar, floatingActionButton: fab, body: body);
  }
}
