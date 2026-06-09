import 'package:flutter/material.dart';

import '../../../core/theme/hos_colors.dart';

class SHOTxtReaderTheme {
  const SHOTxtReaderTheme({
    required this.background,
    required this.text,
    required this.isDark,
  });

  final Color background;
  final Color text;
  final bool isDark;

  static const sepiaBackground = Color(0xFFE8E3D3);
  static const greenBackground = Color(0xFFE3EDDF);
  static const darkBackground = Color(0xFF1A1A1A);

  static const textPresets = [
    Color(0xFF3D3024),
    Color(0xFF222222),
    Color(0xFF5C4B3A),
    Color(0xFF2E5E4E),
  ];

  static const backgroundPresets = [
    sepiaBackground,
    SHOAppColors.surface,
    greenBackground,
    darkBackground,
  ];

  factory SHOTxtReaderTheme.sepia({
    Color textColor = const Color(0xFF3D3024),
  }) {
    return SHOTxtReaderTheme(
      background: sepiaBackground,
      text: textColor,
      isDark: false,
    );
  }

  factory SHOTxtReaderTheme.light({
    Color textColor = SHOAppColors.textPrimary,
    Color background = SHOAppColors.surface,
  }) {
    return SHOTxtReaderTheme(
      background: background,
      text: textColor,
      isDark: false,
    );
  }

  factory SHOTxtReaderTheme.dark({
    Color textColor = const Color(0xFFB8B8B8),
  }) {
    return SHOTxtReaderTheme(
      background: darkBackground,
      text: textColor,
      isDark: true,
    );
  }

  SHOTxtReaderTheme copyWith({
    Color? background,
    Color? text,
    bool? isDark,
  }) {
    return SHOTxtReaderTheme(
      background: background ?? this.background,
      text: text ?? this.text,
      isDark: isDark ?? this.isDark,
    );
  }

  int get textColorArgb => text.toARGB32();
  int get backgroundColorArgb => background.toARGB32();

  static SHOTxtReaderTheme fromProgress({
    required bool darkMode,
    required int textColorArgb,
    int? backgroundColorArgb,
  }) {
    final textColor = Color(textColorArgb);
    if (darkMode) {
      return SHOTxtReaderTheme.dark(textColor: textColor);
    }
    final bg = backgroundColorArgb == null
        ? sepiaBackground
        : Color(backgroundColorArgb);
    return SHOTxtReaderTheme(
      background: bg,
      text: textColor,
      isDark: false,
    );
  }
}
