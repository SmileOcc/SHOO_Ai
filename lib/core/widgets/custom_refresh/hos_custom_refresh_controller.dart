import 'dart:async';

import 'package:flutter/foundation.dart';

/// 下拉刷新状态。
enum SHOAppCustomRefreshStatus {
  idle,
  dragging,
  loading,
  completed,
  error,
}

/// 上拉加载状态。
enum SHOAppCustomLoadStatus {
  idle,
  loading,
  noMore,
  error,
}

/// [SHOAppCustomRefresh] 状态控制器，外部持有并驱动头尾 UI。
class SHOAppCustomRefreshController extends ChangeNotifier {
  SHOAppCustomRefreshStatus refreshStatus = SHOAppCustomRefreshStatus.idle;
  SHOAppCustomLoadStatus loadStatus = SHOAppCustomLoadStatus.idle;

  /// 当前下拉位移（像素），供 Header 动画使用。
  double dragOffset = 0;

  bool get isRefreshLoading =>
      refreshStatus == SHOAppCustomRefreshStatus.loading;

  bool get isLoadLoading => loadStatus == SHOAppCustomLoadStatus.loading;

  bool get canRefresh =>
      refreshStatus != SHOAppCustomRefreshStatus.loading &&
      loadStatus != SHOAppCustomLoadStatus.loading;

  bool get canLoadMore =>
      refreshStatus != SHOAppCustomRefreshStatus.loading &&
      loadStatus != SHOAppCustomLoadStatus.noMore &&
      loadStatus != SHOAppCustomLoadStatus.loading;

  /// 下拉进度 0~1（相对触发阈值）。
  double pullProgress(double triggerOffset) {
    if (triggerOffset <= 0) return 0;
    return (dragOffset / triggerOffset).clamp(0.0, 1.0);
  }

  /// Header 占据的垂直高度（idle 为 0）。
  double get headerLayoutHeight {
    switch (refreshStatus) {
      case SHOAppCustomRefreshStatus.loading:
      case SHOAppCustomRefreshStatus.error:
      case SHOAppCustomRefreshStatus.completed:
        return headerExpandedHeight;
      case SHOAppCustomRefreshStatus.dragging:
        return dragOffset;
      case SHOAppCustomRefreshStatus.idle:
        return 0;
    }
  }

  void updateDrag(double offset, {bool dragging = false}) {
    if (refreshStatus == SHOAppCustomRefreshStatus.loading) return;
    dragOffset = offset.clamp(0.0, headerExpandedHeight);
    refreshStatus = (offset > 0 || dragging)
        ? SHOAppCustomRefreshStatus.dragging
        : SHOAppCustomRefreshStatus.idle;
    notifyListeners();
  }

  void resetDrag() {
    if (refreshStatus == SHOAppCustomRefreshStatus.loading) return;
    dragOffset = 0;
    if (refreshStatus == SHOAppCustomRefreshStatus.dragging) {
      refreshStatus = SHOAppCustomRefreshStatus.idle;
    }
    notifyListeners();
  }

  void beginRefresh() {
    refreshStatus = SHOAppCustomRefreshStatus.loading;
    dragOffset = headerExpandedHeight;
    notifyListeners();
  }

  void refreshCompleted({bool resetLoad = true}) {
    refreshStatus = SHOAppCustomRefreshStatus.completed;
    dragOffset = 0;
    if (resetLoad && loadStatus == SHOAppCustomLoadStatus.noMore) {
      loadStatus = SHOAppCustomLoadStatus.idle;
    }
    notifyListeners();
    _scheduleRefreshIdle();
  }

  void refreshFailed() {
    refreshStatus = SHOAppCustomRefreshStatus.error;
    dragOffset = 0;
    notifyListeners();
    _scheduleRefreshIdle(from: SHOAppCustomRefreshStatus.error);
  }

  void beginLoad() {
    if (!canLoadMore) return;
    loadStatus = SHOAppCustomLoadStatus.loading;
    notifyListeners();
  }

  void loadCompleted() {
    loadStatus = SHOAppCustomLoadStatus.idle;
    notifyListeners();
  }

  void loadNoMore() {
    loadStatus = SHOAppCustomLoadStatus.noMore;
    notifyListeners();
  }

  void loadFailed() {
    loadStatus = SHOAppCustomLoadStatus.error;
    notifyListeners();
  }

  void reset() {
    _cancelRefreshIdle();
    refreshStatus = SHOAppCustomRefreshStatus.idle;
    loadStatus = SHOAppCustomLoadStatus.idle;
    dragOffset = 0;
    notifyListeners();
  }

  static const double triggerOffsetDefault = 64;
  static const double triggerOffsetMax = 96;

  /// 刷新展开时 Header 占用高度（需容纳 Icon + 文案，避免 RenderFlex overflow）。
  static const double headerExpandedHeight = 96;

  /// Header 内容可渲染的最小高度（低于此值不绘制，避免动画过渡期 overflow）。
  static const double minHeaderContentHeight = 40;

  Timer? _refreshIdleTimer;

  @override
  void dispose() {
    _cancelRefreshIdle();
    super.dispose();
  }

  void _cancelRefreshIdle() {
    _refreshIdleTimer?.cancel();
    _refreshIdleTimer = null;
  }

  void _scheduleRefreshIdle({SHOAppCustomRefreshStatus? from}) {
    _cancelRefreshIdle();
    _refreshIdleTimer = Timer(const Duration(milliseconds: 320), () {
      _refreshIdleTimer = null;
      final expected = from ?? SHOAppCustomRefreshStatus.completed;
      if (refreshStatus == expected) {
        refreshStatus = SHOAppCustomRefreshStatus.idle;
        notifyListeners();
      }
    });
  }
}
