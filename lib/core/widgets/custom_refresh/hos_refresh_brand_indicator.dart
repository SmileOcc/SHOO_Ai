import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:shoo/core/brand/hos_app_icon.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/widgets/custom_refresh/hos_custom_refresh_controller.dart';

/// SHOO 品牌风格刷新指示器（Header / Footer 复用）。
class SHOAppRefreshBrandIndicator extends StatefulWidget {
  const SHOAppRefreshBrandIndicator({
    super.key,
    required this.refreshStatus,
    this.pullProgress = 0,
    this.size = 36,
    this.compact = false,
  });

  final SHOAppCustomRefreshStatus refreshStatus;
  final double pullProgress;
  final double size;
  final bool compact;

  @override
  State<SHOAppRefreshBrandIndicator> createState() =>
      _SHOAppRefreshBrandIndicatorState();
}

class _SHOAppRefreshBrandIndicatorState
    extends State<SHOAppRefreshBrandIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didUpdateWidget(SHOAppRefreshBrandIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSpin();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncSpin();
  }

  void _syncSpin() {
    final spinning = widget.refreshStatus == SHOAppCustomRefreshStatus.loading;
    if (spinning && !_spinController.isAnimating) {
      _spinController.repeat();
    } else if (!spinning && _spinController.isAnimating) {
      _spinController.stop();
      _spinController.reset();
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.compact ? widget.size * 0.72 : widget.size;
    final progress = widget.pullProgress.clamp(0.0, 1.0);
    final isLoading = widget.refreshStatus == SHOAppCustomRefreshStatus.loading;
    final isCompleted =
        widget.refreshStatus == SHOAppCustomRefreshStatus.completed;
    final isFailed = widget.refreshStatus == SHOAppCustomRefreshStatus.error;
    final isDragging =
        widget.refreshStatus == SHOAppCustomRefreshStatus.dragging;

    final scale = isLoading
        ? 1.0
        : isCompleted
        ? 1.0
        : 0.78 + progress * 0.22;

    Widget icon = SHOAppIcon(size: size * scale, borderRadius: size * 0.18);

    if (isLoading || (widget.compact && isLoading)) {
      icon = RotationTransition(
        turns: _spinController,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.05).animate(
            CurvedAnimation(parent: _spinController, curve: Curves.easeInOut),
          ),
          child: icon,
        ),
      );
    }

    return SizedBox(
      width: size + 16,
      height: size + 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size + 12, size + 12),
            painter: _RingPainter(
              progress: isLoading
                  ? null
                  : isCompleted
                  ? 1
                  : isDragging || progress > 0
                  ? progress
                  : 0,
              spinning: isLoading,
              spinValue: _spinController.value,
              color: isFailed ? SHOAppColors.error : SHOAppColors.accent,
            ),
          ),
          icon,
          if (isCompleted)
            Icon(
              Icons.check_rounded,
              size: size * 0.45,
              color: SHOAppColors.success,
            ),
          if (isFailed)
            Positioned(
              right: 0,
              bottom: 0,
              child: Icon(
                Icons.error_outline_rounded,
                size: size * 0.35,
                color: SHOAppColors.error,
              ),
            ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.spinning,
    required this.spinValue,
    required this.color,
  });

  final double? progress;
  final bool spinning;
  final double spinValue;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paint);

    paint.color = color;
    if (spinning) {
      const sweep = math.pi * 1.35;
      final start = spinValue * math.pi * 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
      return;
    }

    final p = progress ?? 0;
    if (p <= 0) return;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * p * 0.75,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.spinning != spinning ||
        oldDelegate.spinValue != spinValue ||
        oldDelegate.color != color;
  }
}
