import 'package:flutter/material.dart';

import 'hos_colors.dart';

/// Design Token — 字号 / 字重规范。
///
/// 参考文章第一步 [AppTextStyles]：h1~caption 语义化文字样式。
///
/// ```dart
/// Text('RECOMMENDED', style: SHOAppTypography.textTheme.titleLarge)
/// ```
abstract final class SHOAppTypography {
  static const String fontFamily = 'Roboto';

  static TextTheme textTheme = const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: SHOAppColors.textPrimary,
      height: 1.2,
    ),
    headlineMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: SHOAppColors.textPrimary,
      height: 1.25,
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: SHOAppColors.textPrimary,
      height: 1.3,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: SHOAppColors.textPrimary,
      height: 1.3,
    ),
    bodyLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: SHOAppColors.textPrimary,
      height: 1.35,
    ),
    bodyMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: SHOAppColors.textSecondary,
      height: 1.35,
    ),
    bodySmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      color: SHOAppColors.textMuted,
      height: 1.3,
    ),
    labelLarge: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: SHOAppColors.textPrimary,
      height: 1.2,
    ),
    labelMedium: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: SHOAppColors.textSecondary,
      height: 1.2,
    ),
    labelSmall: TextStyle(
      fontSize: 9,
      fontWeight: FontWeight.w700,
      color: SHOAppColors.textOnAccent,
      height: 1.1,
      letterSpacing: 0.3,
    ),
  );
}
