import 'dart:convert';
import 'dart:typed_data';

/// WebView / H5 截图数据解析。
abstract final class SHOWebViewCapture {
  static const captureScript =
      'window.requestActivityScreenshot && window.requestActivityScreenshot()';

  static Uint8List? decodeDataUrl(String dataUrl) {
    if (dataUrl.isEmpty) return null;
    final commaIndex = dataUrl.indexOf(',');
    if (commaIndex < 0) return null;
    try {
      return base64Decode(dataUrl.substring(commaIndex + 1));
    } catch (_) {
      return null;
    }
  }
}
