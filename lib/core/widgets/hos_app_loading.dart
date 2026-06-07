import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../brand/hos_app_icon.dart';
import '../brand/hos_app_icon_style.dart';
import '../brand/hos_brand_config.dart';
/// 品牌加载组件：圆角 App Icon + 内部浅灰圆形旋转环。
///
/// ```dart
/// const SHOAppLoading(size: 72)
/// SHOAppLoading(size: 96, showAppName: true)
/// ```
class SHOAppLoading extends StatefulWidget {
  const SHOAppLoading({
    super.key,
    this.size = 72,
    this.iconStyle,
    this.showAppName = false,
    this.ringColor,
    this.appNameColor,
    this.borderRadius,
  });

  final double size;
  final SHOAppIconStyle? iconStyle;
  final bool showAppName;
  final Color? ringColor;
  final Color? appNameColor;

  /// Icon 圆角；默认按尺寸比例计算。
  final double? borderRadius;

  @override
  State<SHOAppLoading> createState() => _SHOAppLoadingState();
}

class _SHOAppLoadingState extends State<SHOAppLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _resolveRingColor(BuildContext context) {
    if (widget.ringColor != null) return widget.ringColor!;
    // 深色 Icon 底上使用浅灰圆环，亮/暗主题均清晰可辨。
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFAEAEAE) : const Color(0xFFD6D6D6);
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.iconStyle ?? SHOAppBrandConfig.iconStyle;
    final ringColor = _resolveRingColor(context);
    final borderRadius = widget.borderRadius ?? widget.size * 0.2;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SHOAppIcon(
                size: widget.size,
                style: style,
                borderRadius: borderRadius,
              ),
              RotationTransition(
                turns: _controller,
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _SHOLoadingRingPainter(
                    color: ringColor,
                    strokeWidth: widget.size * 0.045,
                    inset: widget.size * 0.14,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.showAppName) ...[
          SizedBox(height: widget.size * 0.18),
          Text(
            SHOAppBrandConfig.displayName,
            style: TextStyle(
              color: widget.appNameColor ??
                  Theme.of(context).colorScheme.onSurface,
              fontSize: widget.size * 0.22,
              fontWeight: FontWeight.w900,
              letterSpacing: widget.size * 0.04,
            ),
          ),
        ],
      ],
    );
  }
}

class _SHOLoadingRingPainter extends CustomPainter {
  const _SHOLoadingRingPainter({
    required this.color,
    required this.strokeWidth,
    required this.inset,
  });

  final Color color;
  final double strokeWidth;
  final double inset;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - inset - strokeWidth / 2;
    const start = -math.pi / 2;
    const activeSweep = math.pi * 1.55;
    const tailSweep = math.pi * 2 - activeSweep;

    final arcRect = Rect.fromCircle(center: center, radius: radius);

    final activePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final tailPaint = Paint()
      ..color = color.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(arcRect, start, activeSweep, false, activePaint);
    canvas.drawArc(arcRect, start + activeSweep, tailSweep, false, tailPaint);
  }

  @override
  bool shouldRepaint(covariant _SHOLoadingRingPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.inset != inset;
  }
}
