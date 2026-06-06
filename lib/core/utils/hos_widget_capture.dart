import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

/// 将 [RepaintBoundary] 渲染为 PNG 字节或临时文件。
abstract final class SHOWidgetCapture {
  static Future<Uint8List?> toPngBytes(
    GlobalKey boundaryKey, {
    double pixelRatio = 3,
  }) async {
    final boundary = boundaryKey.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary) return null;

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  static Future<File?> toTempPngFile(
    GlobalKey boundaryKey, {
    String prefix = 'shoo_share',
  }) async {
    final bytes = await toPngBytes(boundaryKey);
    if (bytes == null) return null;

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/$prefix-${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}
