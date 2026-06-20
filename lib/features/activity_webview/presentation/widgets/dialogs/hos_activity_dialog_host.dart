import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoo/features/activity_webview/domain/entities/hos_activity_config.dart';
import 'package:shoo/features/activity_webview/presentation/state/hos_activity_config_provider.dart';
import 'package:shoo/features/activity_webview/presentation/state/hos_dialog_provider.dart';
import 'package:shoo/features/activity_webview/presentation/state/hos_share_provider.dart';
import 'package:shoo/features/activity_webview/presentation/widgets/dialogs/hos_coupon_dialog.dart';
import 'package:shoo/features/activity_webview/presentation/widgets/dialogs/hos_lottery_dialog.dart';
import 'package:shoo/features/activity_webview/presentation/widgets/dialogs/hos_prize_dialog.dart';
import 'package:shoo/features/activity_webview/presentation/widgets/dialogs/hos_rules_dialog.dart';
import 'package:shoo/features/activity_webview/presentation/widgets/dialogs/hos_share_dialog.dart';

/*

核心解决的问题 ：
- WebView 是 Platform View，运行在原生视图层级
- 传统 Flutter 手势拦截无法阻止事件传递到 WebView
- 弹窗显示时，滑动/点击会穿透到 WebView，导致网页跟着滚动或触发点击事件

// Android: 使用 TextureLayer 混合合成，手势穿透更严重
// iOS: 使用 UiKitView，部分场景下手势可以被 Flutter 拦截
 
第一层：尝试 IgnorePointer/AbsorbPointer
       ↓ (失败，Platform View 不参与 Flutter 手势竞技场)
第二层：弹窗显示时用原生 View 覆盖 WebView
       ↓ (能解决，但增加了原生通信复杂度)
第三层：PlatformViewLink + 手势代理
       ↓ (Flutter 3.x 的改进方案)
第四层：从产品交互层面规避


IgnorePointer 完全阻断底层事件 底层完全禁用 Platform View 场景 ✅ 
AbsorbPointer 吸收事件但不传递 子组件也无法响应 需要保留部分响应 
GestureDetector 拦截 灵活控制 无法阻止 Platform View 纯 Flutter Widget

 */

/// 活动页弹窗宿主：WebView 为 Platform View，必须用 [IgnorePointer] 阻断底层手势。
class SHOActivityDialogHost extends ConsumerWidget {
  const SHOActivityDialogHost({super.key, required this.child});

  final Widget child;

  bool _overlayVisible(
    String? dialogKind,
    SHOShareState share,
    SHOActivityConfig? config,
  ) {
    return dialogKind != null || (share.visible && config != null);
  }

  void _dismissOverlay(WidgetRef ref, {required bool shareVisible}) {
    if (shareVisible) {
      ref.read(shareProvider.notifier).hide();
      return;
    }
    hideActivityDialog(ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dialogKind = ref.watch(activityDialogProvider);
    final config = ref.watch(activityConfigProvider).valueOrNull;
    final share = ref.watch(shareProvider);
    final visible = _overlayVisible(dialogKind, share, config);

    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(ignoring: visible, child: child),//IgnorePointer 是 Flutter 框架层的机制，只能影响 Flutter 渲染树中的 Widget
        if (visible) ...[
          Positioned.fill(
            child: _ActivityModalBarrier(//_ActivityModalBarrier 遮罩层：组合使用确保滚轮、滑动、点击全部被拦截，无遗漏
              onDismiss: () => _dismissOverlay(
                ref,
                shareVisible: share.visible && config != null,
              ),
            ),
          ),
          if (dialogKind == 'coupon')
            _ActivityDialogPanel(//弹窗面板
              child: SHOCouponDialog(
                coupon:
                    config?.coupons.firstOrNull ??
                    const SHOActivityCoupon(
                      type: '满减',
                      amount: 100,
                      condition: 200,
                    ),
              ),
            ),
          if (dialogKind == 'rules')
            _ActivityDialogPanel(
              child: SHORulesDialog(
                rules: config?.rules ?? const [],
                activityId: config?.id,
              ),
            ),
          if (dialogKind == 'lottery')
            const _ActivityDialogPanel(child: SHOLotteryDialog()),
          if (dialogKind == 'prize')
            const _ActivityDialogPanel(child: SHOPrizeDialog()),
          if (share.visible && config != null)
            _ActivityDialogPanel(child: SHOShareDialog(config: config)),
        ],
      ],
    );
  }
}

/// 全屏遮罩：吸收指针/滚轮，点击空白关闭。
class _ActivityModalBarrier extends StatelessWidget {
  const _ActivityModalBarrier({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {},
      onPointerMove: (_) {},
      onPointerUp: (_) {},
      onPointerSignal: (_) {},
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onDismiss,
        onVerticalDragStart: (_) {},
        onHorizontalDragStart: (_) {},
        child: const ColoredBox(color: Color(0x61000000)),
      ),
    );
  }
}

/// 弹窗面板：居中并限制最大宽度，避免 Stack 内无界布局。
class _ActivityDialogPanel extends StatelessWidget {
  const _ActivityDialogPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width * 0.92;
    return Positioned.fill(
      child: Center(
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) {},
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        ),
      ),
    );
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
