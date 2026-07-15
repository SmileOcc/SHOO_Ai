import 'package:flutter/material.dart';

import 'package:shoo/core/theme/hos_colors.dart';

/// 将 [query] 在 [text] 中的匹配片段高亮为 [SHOAppColors.primary]。
abstract final class SHOTextHighlight {
  static Widget rich({
    required String text,
    required String query,
    required TextStyle style,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = trimmed.toLowerCase();
    final spans = <TextSpan>[];
    var start = 0;

    while (start < text.length) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index < 0) {
        spans.add(TextSpan(text: text.substring(start), style: style));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: style));
      }
      spans.add(
        TextSpan(
          text: text.substring(index, index + lowerQuery.length),
          style: style.copyWith(
            color: SHOAppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      start = index + lowerQuery.length;
    }

    return Text.rich(
      TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
