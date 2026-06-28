import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:shoo/core/widgets/custom_refresh/hos_custom_refresh_controller.dart';
import 'package:shoo/core/widgets/custom_refresh/hos_custom_refresh_defaults.dart';
import 'package:shoo/core/widgets/custom_refresh/hos_custom_refresh_scope.dart';
import 'package:shoo/core/widgets/custom_refresh/hos_custom_refresh_sliver.dart';

export 'hos_custom_refresh_controller.dart';
export 'hos_custom_refresh_sliver.dart';
export 'hos_refresh_brand_indicator.dart';

/// 禁用 Android Material 拉伸光晕，下拉视觉由品牌 Header 承担。
class SHOAppCustomRefreshScrollBehavior extends MaterialScrollBehavior {
  const SHOAppCustomRefreshScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

/// 下拉拖拽追踪。
///
/// - iOS：scrollDelta + 回弹触发（dragDetails == null）
/// - Android：OverscrollNotification + ScrollEnd 触发
enum _PullDragPhase { idle, dragging, armed }

final class _PullDragTracker {
  _PullDragPhase phase = _PullDragPhase.idle;

  double offset = 0;

  static const _extentEpsilon = 0.5;

  void reset() {
    phase = _PullDragPhase.idle;
    offset = 0;
  }

  bool get isActive =>
      phase == _PullDragPhase.dragging || phase == _PullDragPhase.armed;

  bool tryStart(ScrollNotification notification) {
    if (phase != _PullDragPhase.idle) return false;

    final metrics = notification.metrics;
    if (!_isVertical(metrics) || !_atScrollTop(metrics)) return false;

    final userDrag =
        (notification is ScrollStartNotification &&
            notification.dragDetails != null) ||
        (notification is ScrollUpdateNotification &&
            notification.dragDetails != null);

    if (!userDrag) return false;

    phase = _PullDragPhase.dragging;
    offset = 0;
    return true;
  }

  /// Android：顶部 overscroll 可能先于 [ScrollStartNotification] 到达。
  bool tryStartFromOverscroll(OverscrollNotification notification) {
    if (phase != _PullDragPhase.idle) return false;

    final metrics = notification.metrics;
    if (!_isVertical(metrics) ||
        !_atScrollTop(metrics) ||
        notification.overscroll >= 0) {
      return false;
    }

    phase = _PullDragPhase.dragging;
    offset = 0;
    return true;
  }

  void updateFromScroll(ScrollNotification notification, double triggerOffset) {
    final metrics = notification.metrics;
    if (!_isVertical(metrics)) {
      if (isActive) reset();
      return;
    }

    if (isActive && !_atScrollTop(metrics)) {
      reset();
      return;
    }

    if (notification is ScrollUpdateNotification && isActive) {
      final delta = notification.scrollDelta;
      if (delta != null) {
        if (metrics.axisDirection == AxisDirection.down) {
          _applyOffset(offset - delta, triggerOffset);
        } else if (metrics.axisDirection == AxisDirection.up) {
          _applyOffset(offset + delta, triggerOffset);
        }
      }
    }

    if (notification is OverscrollNotification && isActive) {
      if (metrics.axisDirection == AxisDirection.down) {
        _applyOffset(offset - notification.overscroll, triggerOffset);
      } else if (metrics.axisDirection == AxisDirection.up) {
        _applyOffset(offset + notification.overscroll, triggerOffset);
      }
    }
  }

  void _applyOffset(double next, double triggerOffset) {
    offset = next.clamp(
      0.0,
      SHOAppCustomRefreshController.headerExpandedHeight,
    );
    if (phase == _PullDragPhase.dragging && offset >= triggerOffset) {
      phase = _PullDragPhase.armed;
    } else if (phase == _PullDragPhase.armed && offset < triggerOffset) {
      phase = _PullDragPhase.dragging;
    }
  }

  bool _isVertical(ScrollMetrics metrics) {
    return metrics.axisDirection == AxisDirection.down ||
        metrics.axisDirection == AxisDirection.up;
  }

  bool _atScrollTop(ScrollMetrics metrics) {
    return metrics.extentBefore <= _extentEpsilon;
  }

  /// iOS：armed 后 bounce 回弹时 dragDetails 为 null。
  bool shouldTriggerOnUpdate(ScrollUpdateNotification notification) {
    return !kIsWeb &&
        defaultTargetPlatform != TargetPlatform.android &&
        phase == _PullDragPhase.armed &&
        notification.dragDetails == null;
  }

  /// Android / iOS 通用：拉过阈值后松手触发。
  bool shouldTriggerOnEnd() => phase == _PullDragPhase.armed;

  bool shouldCancelOnEnd() => phase == _PullDragPhase.dragging;
}

/// 通用、可定制、状态驱动的一体化刷新组件。
///
/// 刷新 Header 需作为 [CustomScrollView.slivers] 的**第一项**（[headerSliver]），
/// 与列表内容一体滚动；上拉 Footer 放在末尾（[footerSliver]）。
class SHOAppCustomRefresh extends StatefulWidget {
  const SHOAppCustomRefresh({
    super.key,
    required this.controller,
    required this.onRefresh,
    required this.child,
    this.onLoadMore,
    this.enableRefresh = true,
    this.enableLoadMore = true,
    this.refreshTriggerOffset =
        SHOAppCustomRefreshController.triggerOffsetDefault,
    this.loadOffset = 100,
    this.headerBuilder,
    this.footerBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.isEmpty = false,
    this.isError = false,
    this.errorMessage,
    this.onErrorRetry,
  });

  final SHOAppCustomRefreshController controller;
  final Future<void> Function() onRefresh;
  final Future<void> Function()? onLoadMore;
  final Widget child;

  final bool enableRefresh;
  final bool enableLoadMore;
  final double refreshTriggerOffset;
  final double loadOffset;

  final Widget Function(
    BuildContext context,
    SHOAppCustomRefreshStatus status,
    double pullProgress,
  )?
  headerBuilder;

  final Widget Function(BuildContext context, SHOAppCustomLoadStatus status)?
  footerBuilder;

  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(
    BuildContext context,
    String message,
    VoidCallback? onRetry,
  )?
  errorBuilder;

  final bool isEmpty;
  final bool isError;
  final String? errorMessage;
  final VoidCallback? onErrorRetry;

  /// 放在 [CustomScrollView.slivers] **首位**，与内容一体滚动。
  static Widget headerSliver(SHOAppCustomRefreshController controller) {
    return SHOAppCustomRefreshSliver.header(controller);
  }

  static Widget footerSliver(
    SHOAppCustomRefreshController controller, {
    Widget Function(BuildContext context, SHOAppCustomLoadStatus status)?
    footerBuilder,
    VoidCallback? onLoadRetry,
  }) {
    return SHOAppCustomRefreshSliver.footer(
      controller,
      footerBuilder: footerBuilder,
      onLoadRetry: onLoadRetry,
    );
  }

  @override
  State<SHOAppCustomRefresh> createState() => _SHOAppCustomRefreshState();
}

class _SHOAppCustomRefreshState extends State<SHOAppCustomRefresh> {
  final _pullTracker = _PullDragTracker();
  var _refreshTaskRunning = false;
  var _loadTaskRunning = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(SHOAppCustomRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _handleRefresh() async {
    if (_refreshTaskRunning || !widget.controller.canRefresh) {
      return;
    }
    _refreshTaskRunning = true;
    _pullTracker.reset();
    widget.controller.beginRefresh();
    try {
      await widget.onRefresh();
      if (mounted) widget.controller.refreshCompleted();
    } catch (_) {
      if (mounted) widget.controller.refreshFailed();
    } finally {
      _refreshTaskRunning = false;
    }
  }

  Future<void> _runLoadMore() async {
    final load = widget.onLoadMore;
    if (load == null ||
        _loadTaskRunning ||
        !widget.enableLoadMore ||
        !widget.controller.canLoadMore) {
      return;
    }
    _loadTaskRunning = true;
    widget.controller.beginLoad();
    try {
      await load();
    } catch (_) {
      if (mounted) widget.controller.loadFailed();
    } finally {
      _loadTaskRunning = false;
    }
  }

  void _deferAsync(VoidCallback action) {
    if (!mounted) return;
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      action();
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) action();
    });
  }

  void _syncDragToController() {
    if (widget.controller.isRefreshLoading) return;
    if (_pullTracker.isActive) {
      widget.controller.updateDrag(_pullTracker.offset, dragging: true);
    } else if (widget.controller.dragOffset > 0 ||
        widget.controller.refreshStatus == SHOAppCustomRefreshStatus.dragging) {
      widget.controller.resetDrag();
    }
  }

  void _finishDrag({required bool refresh}) {
    if (refresh) {
      _deferAsync(_handleRefresh);
    } else {
      _pullTracker.reset();
      widget.controller.resetDrag();
    }
  }

  bool _shouldHandleScroll(ScrollNotification notification) {
    return notification.depth == 0;
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!_shouldHandleScroll(notification)) return false;

    if (widget.enableLoadMore &&
        widget.controller.canLoadMore &&
        notification is ScrollEndNotification) {
      if (notification.metrics.extentAfter < widget.loadOffset) {
        _deferAsync(_runLoadMore);
      }
    }

    if (!widget.enableRefresh || widget.controller.isRefreshLoading) {
      return false;
    }

    if (notification is OverscrollNotification) {
      _pullTracker.tryStartFromOverscroll(notification);
    }

    _pullTracker.tryStart(notification);
    _pullTracker.updateFromScroll(notification, widget.refreshTriggerOffset);
    _syncDragToController();

    if (notification is ScrollUpdateNotification &&
        _pullTracker.shouldTriggerOnUpdate(notification)) {
      _finishDrag(refresh: true);
      return false;
    }

    if (notification is ScrollEndNotification) {
      if (_pullTracker.shouldTriggerOnEnd()) {
        _finishDrag(refresh: true);
      } else if (_pullTracker.shouldCancelOnEnd() || _pullTracker.isActive) {
        _finishDrag(refresh: false);
      }
    }

    return false;
  }

  bool _handleOverscrollIndicator(
    OverscrollIndicatorNotification notification,
  ) {
    if (notification.depth != 0 || !notification.leading) return false;
    if (_pullTracker.isActive ||
        widget.controller.isRefreshLoading ||
        widget.controller.dragOffset > 0) {
      notification.disallowIndicator();
      return true;
    }
    return false;
  }

  Widget _buildBody() {
    if (widget.isError && widget.errorMessage != null) {
      return widget.errorBuilder?.call(
            context,
            widget.errorMessage!,
            widget.onErrorRetry,
          ) ??
          SHOAppCustomRefreshDefaults.error(
            context,
            message: widget.errorMessage!,
            onRetry: widget.onErrorRetry,
          );
    }

    if (widget.isEmpty && !widget.controller.isRefreshLoading) {
      return widget.emptyBuilder?.call(context) ??
          SHOAppCustomRefreshDefaults.empty(context);
    }

    return widget.child;
  }

  @override
  Widget build(BuildContext context) {
    return SHOAppCustomRefreshScope(
      refreshTriggerOffset: widget.refreshTriggerOffset,
      headerBuilder: widget.headerBuilder,
      child: ScrollConfiguration(
        behavior: const SHOAppCustomRefreshScrollBehavior(),
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: _handleOverscrollIndicator,
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: _buildBody(),
          ),
        ),
      ),
    );
  }
}

/// 下拉刷新推荐滚动物理。
///
/// - [AlwaysScrollableScrollPhysics]：内容不足一屏也可下拉
/// - [ClampingScrollPhysics]：Android 顶部 overscroll；位移由 Header Sliver 吸收
const ScrollPhysics shoAppCustomRefreshScrollPhysics =
    AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics());

/// Android 推荐；与 [shoAppCustomRefreshScrollPhysics] 相同，语义更明确。
const ScrollPhysics shoAppCustomRefreshScrollPhysicsAndroid =
    shoAppCustomRefreshScrollPhysics;

/// iOS 推荐；与 Android 保持一致，避免 bounce 与 Header Sliver 双重位移。
const ScrollPhysics shoAppCustomRefreshScrollPhysicsIOS =
    shoAppCustomRefreshScrollPhysics;
