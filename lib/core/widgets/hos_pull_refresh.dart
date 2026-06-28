import 'package:flutter/material.dart';

import 'package:shoo/core/theme/hos_colors.dart';

/// 下拉刷新实现引擎。
///
/// 当前默认 [material]（系统 [RefreshIndicator]）。
/// 若后续接入 easy_refresh / pull_to_refresh 等，在此扩展分支即可，业务页无需改动。
enum SHOAppPullRefreshEngine { material }

/// 轻量下拉刷新封装：统一品牌样式与回调约定。
///
/// - [onRefresh] 为 null 时不包裹，直接返回 [child]
/// - 列表/网格子组件建议配合 [scrollPhysics] 保证内容不足一屏也可下拉
class SHOAppPullRefresh extends StatelessWidget {
  const SHOAppPullRefresh({
    super.key,
    required this.child,
    this.onRefresh,
    this.engine = SHOAppPullRefreshEngine.material,
    this.displacement,
    this.edgeOffset,
    this.strokeWidth,
    this.triggerMode = RefreshIndicatorTriggerMode.onEdge,
    this.notificationPredicate,
  });

  final Widget child;
  final Future<void> Function()? onRefresh;
  final SHOAppPullRefreshEngine engine;
  final double? displacement;
  final double? edgeOffset;
  final double? strokeWidth;
  final RefreshIndicatorTriggerMode triggerMode;
  final ScrollNotificationPredicate? notificationPredicate;

  /// 下拉刷新场景推荐的滚动物理（内容不足一屏仍可触发）。
  static const ScrollPhysics scrollPhysics = AlwaysScrollableScrollPhysics();

  @override
  Widget build(BuildContext context) {
    final refresh = onRefresh;
    if (refresh == null) return child;

    switch (engine) {
      case SHOAppPullRefreshEngine.material:
        return RefreshIndicator(
          color: SHOAppColors.accent,
          backgroundColor: Theme.of(context).colorScheme.surface,
          displacement: displacement ?? 40,
          edgeOffset: edgeOffset ?? 0,
          strokeWidth: strokeWidth ?? 2,
          triggerMode: triggerMode,
          notificationPredicate:
              notificationPredicate ?? defaultScrollNotificationPredicate,
          onRefresh: refresh,
          child: child,
        );
    }
  }
}
