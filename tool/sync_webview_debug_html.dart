/// 将 Dart 源码中的 WebView 调试 HTML 同步到 assets 副本。
///
/// 用法：
/// ```sh
/// dart run tool/sync_webview_debug_html.dart
/// ```
library;

import 'dart:io';

Future<void> main() async {
  final dartFile = File(
    'lib/core/platform/webview/mock/hos_webview_debug_html.dart',
  );
  if (!dartFile.existsSync()) {
    stderr.writeln('Missing ${dartFile.path}');
    exit(1);
  }

  final source = dartFile.readAsStringSync();
  final debug = _extractConst(source, 'kSHOWebViewDebugHtml');
  final redirect = _extractConst(source, 'kSHOWebViewRedirectBaiduHtml');

  Directory('assets/webview').createSync(recursive: true);
  File('assets/webview/debug.html').writeAsStringSync(debug);
  File('assets/webview/redirect_baidu.html').writeAsStringSync(redirect);

  stdout.writeln('Synced:');
  stdout.writeln('  assets/webview/debug.html');
  stdout.writeln('  assets/webview/redirect_baidu.html');
}

String _extractConst(String source, String name) {
  final marker = 'const String $name = r\'\'\'';
  final start = source.indexOf(marker);
  if (start < 0) {
    throw StateError('Cannot find $name');
  }
  final contentStart = start + marker.length;
  final end = source.indexOf("'''", contentStart);
  if (end < 0) {
    throw StateError('Unclosed raw string for $name');
  }
  return source.substring(contentStart, end);
}
