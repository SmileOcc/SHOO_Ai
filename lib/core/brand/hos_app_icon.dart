import 'package:flutter/material.dart';

import '../theme/hos_colors.dart';
import 'hos_app_icon_style.dart';
import 'hos_brand_config.dart';

/// SHOO 品牌 App Icon，支持多款视觉风格。
class SHOAppIcon extends StatelessWidget {
  const SHOAppIcon({
    super.key,
    required this.size,
    this.style = SHOAppBrandConfig.iconStyle,
    this.borderRadius,
  });

  final double size;
  final SHOAppIconStyle style;

  /// 为 null 时经典方块为直角；Loading 等场景传入圆角半径。
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SHOAppIconPainter(style: style, borderRadius: borderRadius),
      ),
    );
  }
}

class _SHOAppIconPainter extends CustomPainter {
  const _SHOAppIconPainter({
    required this.style,
    this.borderRadius,
  });

  final SHOAppIconStyle style;
  final double? borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    switch (style) {
      case SHOAppIconStyle.classic:
        _paintClassic(canvas, size);
      case SHOAppIconStyle.accentBadge:
        _paintAccentBadge(canvas, size);
      case SHOAppIconStyle.fashionBag:
        _paintFashionBag(canvas, size);
      case SHOAppIconStyle.monogram:
        _paintMonogram(canvas, size);
      case SHOAppIconStyle.outlineRing:
        _paintOutlineRing(canvas, size);
    }
  }

  void _paintClassic(Canvas canvas, Size size) {
    final bounds = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..color = SHOAppColors.primary;
    if (borderRadius != null && borderRadius! > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(bounds, Radius.circular(borderRadius!)),
        paint,
      );
    } else {
      canvas.drawRect(bounds, paint);
    }
    _drawWordmark(
      canvas,
      size,
      text: SHOAppBrandConfig.iconMark,
      color: Colors.white,
      fontSize: size.width * 0.34,
    );
  }

  void _paintAccentBadge(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      center,
      size.width / 2,
      Paint()..color = SHOAppColors.accent,
    );
    _drawWordmark(canvas, size, color: Colors.white, fontSize: size.width * 0.18);
  }

  void _paintFashionBag(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.18, h * 0.34, w * 0.82, h * 0.9),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(body, Paint()..color = SHOAppColors.primary);

    final handle = Path()
      ..moveTo(w * 0.34, h * 0.34)
      ..cubicTo(w * 0.34, h * 0.12, w * 0.66, h * 0.12, w * 0.66, h * 0.34);
    canvas.drawPath(
      handle,
      Paint()
        ..color = SHOAppColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.07
        ..strokeCap = StrokeCap.round,
    );

    _drawWordmark(
      canvas,
      size,
      color: Colors.white,
      fontSize: size.width * 0.15,
      dyOffset: h * 0.06,
    );
  }

  void _paintMonogram(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      center,
      size.width / 2,
      Paint()..color = SHOAppColors.surface,
    );
    canvas.drawCircle(
      center,
      size.width / 2,
      Paint()
        ..color = SHOAppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.04,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'S',
        style: TextStyle(
          color: SHOAppColors.accent,
          fontSize: size.width * 0.52,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2 - size.height * 0.03,
      ),
    );

    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.28),
      size.width * 0.07,
      Paint()..color = SHOAppColors.accent,
    );
  }

  void _paintOutlineRing(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      center,
      size.width / 2,
      Paint()..color = SHOAppColors.surface,
    );
    canvas.drawCircle(
      center,
      size.width / 2,
      Paint()
        ..color = SHOAppColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.08,
    );
    _drawWordmark(
      canvas,
      size,
      color: SHOAppColors.primary,
      fontSize: size.width * 0.17,
    );
  }

  void _drawWordmark(
    Canvas canvas,
    Size size, {
    String? text,
    required Color color,
    required double fontSize,
    double dyOffset = 0,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text ?? SHOAppBrandConfig.displayName,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: fontSize * 0.08,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2 + dyOffset,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _SHOAppIconPainter oldDelegate) {
    return oldDelegate.style != style ||
        oldDelegate.borderRadius != borderRadius;
  }
}
