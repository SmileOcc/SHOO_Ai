import 'package:flutter/material.dart';

/// 阅读器分页布局参数，保证测量与渲染使用同一套文字样式。
class SHOTxtReaderPagination {
  const SHOTxtReaderPagination({
    required this.pageWidth,
    required this.pageHeight,
    required this.textStyle,
    required this.titleStyle,
    this.textScaler = TextScaler.noScaling,
  });

  final double pageWidth;
  final double pageHeight;
  final TextStyle textStyle;
  final TextStyle titleStyle;
  final TextScaler textScaler;
}
