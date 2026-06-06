import 'package:flutter/material.dart';

import 'hos_colors.dart';

/// 语义化主题色扩展 — 随亮/暗模式切换，避免硬编码 [SHOAppColors.surface]。
@immutable
class SHOAppThemeColors extends ThemeExtension<SHOAppThemeColors> {
  const SHOAppThemeColors({
    required this.surfaceMuted,
    required this.border,
    required this.divider,
    required this.textSecondary,
    required this.textMuted,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.profileHeaderStart,
    required this.profileHeaderEnd,
    required this.tabBarBackground,
    required this.tabBarInactive,
  });

  final Color surfaceMuted;
  final Color border;
  final Color divider;
  final Color textSecondary;
  final Color textMuted;
  final Color skeletonBase;
  final Color skeletonHighlight;
  final Color profileHeaderStart;
  final Color profileHeaderEnd;
  final Color tabBarBackground;
  final Color tabBarInactive;

  static const light = SHOAppThemeColors(
    surfaceMuted: SHOAppColors.surfaceMuted,
    border: SHOAppColors.border,
    divider: SHOAppColors.divider,
    textSecondary: SHOAppColors.textSecondary,
    textMuted: SHOAppColors.textMuted,
    skeletonBase: SHOAppColors.skeletonBase,
    skeletonHighlight: SHOAppColors.skeletonHighlight,
    profileHeaderStart: Color(0xFF2D2D2D),
    profileHeaderEnd: Color(0xFF1A1A1A),
    tabBarBackground: SHOAppColors.tabBarBackground,
    tabBarInactive: SHOAppColors.tabBarInactive,
  );

  static const dark = SHOAppThemeColors(
    surfaceMuted: Color(0xFF222222),
    border: Color(0xFF2E2E2E),
    divider: Color(0xFF2A2A2A),
    textSecondary: Color(0xFFB0B0B0),
    textMuted: Color(0xFF888888),
    skeletonBase: Color(0xFF2A2A2A),
    skeletonHighlight: Color(0xFF333333),
    profileHeaderStart: Color(0xFF1F1F1F),
    profileHeaderEnd: Color(0xFF111111),
    tabBarBackground: Color(0xFF1A1A1A),
    tabBarInactive: Color(0xFF777777),
  );

  static SHOAppThemeColors of(BuildContext context) {
    return Theme.of(context).extension<SHOAppThemeColors>() ?? light;
  }

  @override
  SHOAppThemeColors copyWith({
    Color? surfaceMuted,
    Color? border,
    Color? divider,
    Color? textSecondary,
    Color? textMuted,
    Color? skeletonBase,
    Color? skeletonHighlight,
    Color? profileHeaderStart,
    Color? profileHeaderEnd,
    Color? tabBarBackground,
    Color? tabBarInactive,
  }) {
    return SHOAppThemeColors(
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
      profileHeaderStart: profileHeaderStart ?? this.profileHeaderStart,
      profileHeaderEnd: profileHeaderEnd ?? this.profileHeaderEnd,
      tabBarBackground: tabBarBackground ?? this.tabBarBackground,
      tabBarInactive: tabBarInactive ?? this.tabBarInactive,
    );
  }

  @override
  SHOAppThemeColors lerp(ThemeExtension<SHOAppThemeColors>? other, double t) {
    if (other is! SHOAppThemeColors) return this;
    return SHOAppThemeColors(
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight: Color.lerp(skeletonHighlight, other.skeletonHighlight, t)!,
      profileHeaderStart: Color.lerp(profileHeaderStart, other.profileHeaderStart, t)!,
      profileHeaderEnd: Color.lerp(profileHeaderEnd, other.profileHeaderEnd, t)!,
      tabBarBackground: Color.lerp(tabBarBackground, other.tabBarBackground, t)!,
      tabBarInactive: Color.lerp(tabBarInactive, other.tabBarInactive, t)!,
    );
  }
}

extension SHOThemeContext on BuildContext {
  SHOAppThemeColors get shoTheme => SHOAppThemeColors.of(this);

  Color get shoBackground => Theme.of(this).scaffoldBackgroundColor;

  Color get shoSurface => Theme.of(this).colorScheme.surface;
}
