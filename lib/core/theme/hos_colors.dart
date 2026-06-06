import 'package:flutter/material.dart';

/// Design Token — 颜色规范。
///
/// 参考文章第一步：语义化命名（primary / accent / error），
/// 禁止在页面中硬编码 `Color(0xFF...)`。
///
/// ```dart
/// Container(color: SHOAppColors.surface)
/// Text('Sale', style: TextStyle(color: SHOAppColors.accent))
/// ```
abstract final class SHOAppColors {
  static const Color primary = Color(0xFF222222);
  static const Color accent = Color(0xFFFF4657);
  static const Color accentDark = Color(0xFFE03E4D);
  static const Color sale = Color(0xFFFF4657);
  static const Color flash = Color(0xFFFF6B00);

  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF5F5F5);

  static const Color textPrimary = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textMuted = Color(0xFF999999);
  static const Color textOnAccent = Color(0xFFFFFFFF);

  static const Color border = Color(0xFFEEEEEE);
  static const Color divider = Color(0xFFF0F0F0);

  static const Color success = Color(0xFF00B578);
  static const Color warning = Color(0xFFFFB020);
  static const Color error = Color(0xFFFF4657);

  static const Color skeletonBase = Color(0xFFE8E8E8);
  static const Color skeletonHighlight = Color(0xFFF5F5F5);

  static const Color tabBarBackground = Color(0xFFFFFFFF);
  static const Color tabBarActive = Color(0xFF222222);
  static const Color tabBarInactive = Color(0xFFAAAAAA);
}
