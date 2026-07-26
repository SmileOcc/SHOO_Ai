import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:shoo/core/widgets/hos_network_image.dart';

/// 加购飞入动画：商品图从起点沿弧线旋转缩小飞到购物车图标。
///
/// 使用二次贝塞尔曲线实现抛物线轨迹，配合旋转和缩放效果，
/// 在 Overlay 层展示动画，不影响其他组件。
abstract final class SHOAddToCartFlyAnimation {
  /// 默认起始尺寸（像素），动画开始时商品图的大小。
  static const double defaultStartSize = 80;

  /// 默认结束尺寸（像素），动画结束时商品图缩小到的大小。
  static const double defaultEndSize = 24;

  /// 播放一次飞入动画。终点锚点不可用时静默跳过。
  ///
  /// 起点固定为屏幕窗口上半部中心（80×80 方图从此抛出），
  /// 沿二次贝塞尔弧线旋转缩小飞到终点。
  ///
  /// [context]：用于获取屏幕尺寸和 Overlay
  /// [imageUrl]：商品图片 URL
  /// [toKey]：终点组件的 GlobalKey，通常是购物车图标
  /// [startSize]：起始尺寸，默认 80px
  /// [endSize]：结束尺寸，默认 24px
  /// [duration]：动画时长，默认 720ms
  static Future<void> play({
    required BuildContext context,
    required String imageUrl,
    required GlobalKey toKey,
    double startSize = defaultStartSize,
    double endSize = defaultEndSize,
    Duration duration = const Duration(milliseconds: 720),
  }) {
    // 检查 1：终点组件是否存在
    final toCtx = toKey.currentContext;
    if (toCtx == null) return Future.value();

    // 检查 2：终点组件是否有尺寸
    final toBox = toCtx.findRenderObject() as RenderBox?;
    if (toBox == null || !toBox.hasSize) {
      return Future.value();
    }

    // 检查 3：Overlay 是否可用（当前代码）
    // 获取应用的根 Overlay 层 ，用于在所有组件之上显示飞入动画。
    final overlayState = Overlay.maybeOf(context, rootOverlay: true);
    if (overlayState == null) return Future.value();

    final size = MediaQuery.sizeOf(context);
    // 屏幕上半部中心：水平居中，竖直取上半区中点
    final fromCenter = Offset(size.width / 2, size.height / 4);
    final toCenter = toBox.localToGlobal(toBox.size.center(Offset.zero));

    final completer = Completer<void>();

  // 使用 late 关键字可以：
  // - 声明变量但 延迟初始化
  // - 允许在赋值之前引用该变量（在闭包中）

    // OverlayEntry 是 Overlay 层中的一个"条目" ，可以理解为一个 悬浮在所有组件之上的独立 Widget 。
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _SHOAddToCartFlyOverlay(
        imageUrl: imageUrl,
        startCenter: fromCenter,
        endCenter: toCenter,
        startSize: startSize,
        endSize: endSize,
        duration: duration,
        onCompleted: () {
          // 动画完成后移除
          entry.remove(); // 在闭包中引用 entry 所以需要late
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );
    // 插入到 Overlay 层
    // 将条目添加到 Overlay 层，开始渲染
    overlayState.insert(entry);
    return completer.future;
  }
}

/// 飞入动画的 Overlay 组件，负责渲染动画过程中的商品图片。
class _SHOAddToCartFlyOverlay extends StatefulWidget {
  const _SHOAddToCartFlyOverlay({
    required this.imageUrl,
    required this.startCenter,
    required this.endCenter,
    required this.startSize,
    required this.endSize,
    required this.duration,
    required this.onCompleted,
  });

  /// 商品图片 URL。
  final String imageUrl;

  /// 动画起始中心点坐标。
  final Offset startCenter;

  /// 动画结束中心点坐标。
  final Offset endCenter;

  /// 起始尺寸（像素）。
  final double startSize;

  /// 结束尺寸（像素）。
  final double endSize;

  /// 动画时长。
  final Duration duration;

  /// 动画完成回调。
  final VoidCallback onCompleted;

  @override
  State<_SHOAddToCartFlyOverlay> createState() =>
      _SHOAddToCartFlyOverlayState();
}

/// 飞入动画的状态类，管理动画控制器和轨迹计算。
class _SHOAddToCartFlyOverlayState extends State<_SHOAddToCartFlyOverlay>
    with SingleTickerProviderStateMixin {
  /// 动画控制器，控制动画进度。
  late final AnimationController _controller;

  /// 曲线动画，应用 easeInCubic 缓动效果使动画先慢后快。
  late final Animation<double> _curve;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeInCubic);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted();
      }
    });
    // 组件创建后立即启动动画
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 计算二次贝塞尔曲线上的点，形成落入购物车的抛物线轨迹。
  ///
  /// 控制点偏左上，使轨迹呈现向上抛再落下的效果。
  /// [t]：动画进度，范围 0.0 到 1.0。
  Offset _pointOnArc(double t) {
    final p0 = widget.startCenter;
    final p2 = widget.endCenter;
    final midX = (p0.dx + p2.dx) / 2;
    final midY = math.min(p0.dy, p2.dy);
    final p1 = Offset(midX - (p2.dx - p0.dx).abs() * 0.15 - 36, midY - 96);
    final u = 1 - t;
    return Offset(
      u * u * p0.dx + 2 * u * t * p1.dx + t * t * p2.dx,
      u * u * p0.dy + 2 * u * t * p1.dy + t * t * p2.dy,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 让子 Widget 忽略所有指针事件 （点击、触摸、拖动等），使其"穿透"可点击，用户可以直接操作其下方的组件。
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _curve,
        builder: (context, child) {
          final t = _curve.value;
          // 尺寸从 startSize 线性插值到 endSize
          // 结果 = a + (b - a) * t
          final size = lerpDouble(widget.startSize, widget.endSize, t)!;
          // 根据进度计算当前位置（沿贝塞尔曲线）
          final center = _pointOnArc(t);
          // 旋转角度：从 0 到 360°（2π 弧度）
          final rotation = t * math.pi * 2;
          // 透明度：前 85% 保持不透明，后 15% 渐隐
          final opacity = t < 0.85 ? 1.0 : (1 - (t - 0.85) / 0.15);

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                left: center.dx - size / 2,
                top: center.dy - size / 2,
                width: size,
                height: size,
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Transform.rotate(angle: rotation, child: child),
                ),
              ),
            ],
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SHOAppNetworkImage(
            url: widget.imageUrl,
            width: widget.startSize,
            height: widget.startSize,
            memCacheWidth: 160,
            showLoadingSkeleton: false,
          ),
        ),
      ),
    );
  }
}
