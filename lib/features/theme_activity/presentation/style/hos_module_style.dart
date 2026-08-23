import 'package:flutter/material.dart';

Color? parseThemeColor(String? raw, {Color? fallback}) {
  if (raw == null || raw.isEmpty) return fallback;
  final value = raw.replaceAll('#', '');
  if (value.length == 6) {
    final parsed = int.tryParse(value, radix: 16);
    if (parsed != null) return Color(0xFF000000 | parsed);
  }
  if (value.length == 8) {
    final parsed = int.tryParse(value, radix: 16);
    if (parsed != null) return Color(parsed);
  }
  return fallback;
}

double themeNumber(dynamic raw, {double fallback = 0}) {
  if (raw is num) return raw.toDouble();
  if (raw is String) return double.tryParse(raw) ?? fallback;
  return fallback;
}

EdgeInsets themeEdgeInsets(dynamic raw, {double fallback = 0}) {
  if (raw is num) {
    final v = raw.toDouble();
    return EdgeInsets.all(v);
  }
  if (raw is Map) {
    final top = themeNumber(raw['top'], fallback: fallback);
    final right = themeNumber(raw['right'], fallback: fallback);
    final bottom = themeNumber(raw['bottom'], fallback: fallback);
    final left = themeNumber(raw['left'], fallback: fallback);
    return EdgeInsets.fromLTRB(left, top, right, bottom);
  }
  return EdgeInsets.all(fallback);
}

BoxDecoration moduleBoxDecoration(
  Map<String, dynamic> style, {
  Map<String, dynamic>? fallback,
}) {
  final merged = {...?fallback, ...style};
  final radius = themeNumber(merged['borderRadius'], fallback: 0);
  final borderWidth = themeNumber(merged['borderWidth']);
  final borderColor = parseThemeColor(merged['borderColor'] as String?);
  final backgroundColor = parseThemeColor(merged['backgroundColor'] as String?);
  final backgroundImage = merged['backgroundImage'] as String?;

  return BoxDecoration(
    color: backgroundImage == null ? backgroundColor : null,
    image: backgroundImage != null && backgroundImage.isNotEmpty
        ? DecorationImage(
            image: NetworkImage(backgroundImage),
            fit: BoxFit.cover,
          )
        : null,
    borderRadius: BorderRadius.circular(radius),
    border: borderWidth > 0 && borderColor != null
        ? Border.all(color: borderColor, width: borderWidth)
        : null,
  );
}

TextStyle? moduleTextStyle(
  Map<String, dynamic> style, {
  required String colorKey,
  String? sizeKey,
  FontWeight? defaultWeight,
}) {
  final color = parseThemeColor(style[colorKey] as String?);
  final size = themeNumber(style[sizeKey ?? '${colorKey}FontSize'], fallback: 14);
  if (color == null) return null;
  return TextStyle(
    color: color,
    fontSize: size,
    fontWeight: defaultWeight,
  );
}
