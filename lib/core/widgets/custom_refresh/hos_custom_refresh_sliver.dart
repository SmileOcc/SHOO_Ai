import 'package:flutter/material.dart';

import 'package:shoo/core/widgets/custom_refresh/hos_custom_refresh_controller.dart';
import 'package:shoo/core/widgets/custom_refresh/hos_custom_refresh_defaults.dart';
import 'package:shoo/core/widgets/custom_refresh/hos_custom_refresh_scope.dart';

/// [SHOAppCustomRefresh] Sliver 辅助。
abstract final class SHOAppCustomRefreshSliver {
  /// 放在 [CustomScrollView.slivers] **首位**，与列表一体滚动。
  static Widget header(SHOAppCustomRefreshController controller) {
    return SliverToBoxAdapter(child: _HeaderSlot(controller: controller));
  }

  /// 在 [CustomScrollView.slivers] 末尾追加加载 Footer。
  static Widget footer(
    SHOAppCustomRefreshController controller, {
    Widget Function(BuildContext context, SHOAppCustomLoadStatus status)?
    footerBuilder,
    VoidCallback? onLoadRetry,
  }) {
    return SliverToBoxAdapter(
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return footerBuilder?.call(context, controller.loadStatus) ??
              SHOAppCustomRefreshDefaults.footer(
                context,
                controller.loadStatus,
                onRetry: onLoadRetry,
              );
        },
      ),
    );
  }
}

class _HeaderSlot extends StatelessWidget {
  const _HeaderSlot({required this.controller});

  final SHOAppCustomRefreshController controller;

  static const _animDuration = Duration(milliseconds: 220);
  static const _animCurve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    final scope = SHOAppCustomRefreshScope.maybeOf(context);
    final triggerOffset =
        scope?.refreshTriggerOffset ??
        SHOAppCustomRefreshController.triggerOffsetDefault;
    final headerBuilder = scope?.headerBuilder;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final height = controller.headerLayoutHeight;
        if (height <= 0) return const SizedBox.shrink();

        final animating =
            controller.refreshStatus != SHOAppCustomRefreshStatus.dragging;

        final header =
            headerBuilder?.call(
              context,
              controller.refreshStatus,
              controller.pullProgress(triggerOffset),
            ) ??
            SHOAppCustomRefreshDefaults.header(
              context,
              controller,
              triggerOffset: triggerOffset,
            );

        return ClipRect(
          child: AnimatedContainer(
            duration: animating ? _animDuration : Duration.zero,
            curve: _animCurve,
            height: height,
            width: double.infinity,
            color: Theme.of(context).scaffoldBackgroundColor,
            alignment: Alignment.bottomCenter,
            child: header,
          ),
        );
      },
    );
  }
}
