import 'package:flutter/material.dart';

/// 根据歌曲 key 生成稳定的浅色系占位色。
abstract final class SHOMusicColorUtils {
  static const _lightPalette = <int>[
    0xFFFFCDD2,
    0xFFF8BBD0,
    0xFFE1BEE7,
    0xFFD1C4E9,
    0xFFC5CAE9,
    0xFFBBDEFB,
    0xFFB3E5FC,
    0xFFB2EBF2,
    0xFFB2DFDB,
    0xFFC8E6C9,
    0xFFDCEDC8,
    0xFFFFF9C4,
    0xFFFFE0B2,
    0xFFFFCCBC,
  ];

  static int colorForKey(String key, {int salt = 0}) {
    if (key.isEmpty) return _lightPalette.first;
    var hash = salt;
    for (final code in key.codeUnits) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    return _lightPalette[hash % _lightPalette.length];
  }

  static Color coverColorFor(String key) => Color(colorForKey(key, salt: 11));

  static Color backgroundColorFor(String key) => Color(colorForKey(key, salt: 29));
}
