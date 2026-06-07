import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'hos_colors.dart';
import 'hos_spacing.dart';
import 'hos_theme_extension.dart';
import 'hos_typography.dart';

/// 应用主题管理：亮色 + 暗色，配合 [ThemeMode.system] 自动切换。
///
/// 参考文章第五步统一主题管理。
///
/// ```dart
/// MaterialApp(
///   theme: SHOAppTheme.light,
///   darkTheme: SHOAppTheme.dark,
///   themeMode: ThemeMode.system,
/// )
/// ```
abstract final class SHOAppTheme {
  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: SHOAppColors.primary,
      secondary: SHOAppColors.accent,
      surface: SHOAppColors.surface,
      error: SHOAppColors.error,
      onPrimary: SHOAppColors.textOnAccent,
      onSecondary: SHOAppColors.textOnAccent,
      onSurface: SHOAppColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: SHOAppColors.background,
      fontFamily: SHOAppTypography.fontFamily,
      textTheme: SHOAppTypography.textTheme,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: SHOAppColors.surface,
        foregroundColor: SHOAppColors.textPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: SHOAppColors.textPrimary,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: SHOAppColors.divider,
        thickness: 0.5,
        space: 0.5,
      ),
      cardTheme: CardThemeData(
        color: SHOAppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SHOAppColors.primary,
          foregroundColor: SHOAppColors.textOnAccent,
          elevation: 0,
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SHOAppSpacing.buttonRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SHOAppColors.textPrimary,
          side: const BorderSide(color: SHOAppColors.border),
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SHOAppSpacing.buttonRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SHOAppColors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SHOAppSpacing.buttonRadius),
          borderSide: BorderSide.none,
        ),
        hintStyle: SHOAppTypography.textTheme.bodyMedium,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: SHOAppColors.tabBarBackground,
        selectedItemColor: SHOAppColors.tabBarActive,
        unselectedItemColor: SHOAppColors.tabBarInactive,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 10),
      ),
      extensions: const [SHOAppThemeColors.light],
    );
  }

  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: SHOAppColors.primary,
      secondary: SHOAppColors.accent,
      surface: Color(0xFF1A1A1A),
      error: SHOAppColors.error,
      onPrimary: SHOAppColors.textOnAccent,
      onSecondary: SHOAppColors.textOnAccent,
      onSurface: Color(0xFFE8E8E8),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF111111),
      fontFamily: SHOAppTypography.fontFamily,
      textTheme: SHOAppTypography.textTheme.apply(
        bodyColor: const Color(0xFFE8E8E8),
        displayColor: const Color(0xFFE8E8E8),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Color(0xFF1A1A1A),
        foregroundColor: Color(0xFFE8E8E8),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE8E8E8),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2A2A2A),
        thickness: 0.5,
        space: 0.5,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1A1A),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF222222),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SHOAppSpacing.buttonRadius),
          borderSide: BorderSide.none,
        ),
        hintStyle: SHOAppTypography.textTheme.bodyMedium?.copyWith(
          color: SHOAppColors.textMuted,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1A1A1A),
        selectedItemColor: Color(0xFFE8E8E8),
        unselectedItemColor: Color(0xFF888888),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 10),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return SHOAppColors.accent;
          return const Color(0xFF888888);
        }),
      ),
      extensions: const [SHOAppThemeColors.dark],
    );
  }
}
