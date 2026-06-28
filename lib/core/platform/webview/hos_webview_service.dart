import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:webview_flutter/webview_flutter.dart';

import 'package:shoo/core/platform/webview/hos_webview_config.dart';

/// 通用 WebView 服务层：URL 分发、Cookie、拦截器。
class SHOWebViewService {
  SHOWebViewService._();

  static final SHOWebViewService instance = SHOWebViewService._();

  bool shouldUseSystemBrowser(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    final lower = url.toLowerCase();
    if (lower.contains('alipay') ||
        lower.contains('weixin://') ||
        lower.contains('alipays://')) {
      return true;
    }
    if (lower.contains('bank') &&
        (lower.contains('pay') || lower.contains('auth'))) {
      return true;
    }
    if (lower.contains('taobao.com') ||
        lower.contains('jd.com') ||
        lower.contains('tmall.com')) {
      return true;
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') return true;
    if (lower.endsWith('.pdf') ||
        lower.endsWith('.apk') ||
        lower.endsWith('.zip')) {
      return true;
    }
    return false;
  }

  bool shouldOpenExternally(String url, SHOWebViewMode mode) {
    switch (mode) {
      case SHOWebViewMode.systemBrowser:
        return true;
      case SHOWebViewMode.inApp:
        return false;
      case SHOWebViewMode.auto:
        return shouldUseSystemBrowser(url);
    }
  }

  Future<bool> openInSystemBrowser(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    if (await launcher.canLaunchUrl(uri)) {
      return launcher.launchUrl(
        uri,
        mode: launcher.LaunchMode.externalApplication,
      );
    }
    return false;
  }

  Future<void> syncCookiesToWebView(
    WebViewController controller,
    List<SHOWebViewCookie> cookies,
  ) async {
    final scripts = cookies
        .map(
          (c) =>
              "document.cookie = '${c.name}=${c.value}; domain=${c.domain}; path=${c.path};';",
        )
        .join('\n');
    await controller.runJavaScript(scripts);
  }

  Future<void> saveCookies(List<SHOWebViewCookie> cookies) async {
    final prefs = await SharedPreferences.getInstance();
    final list = cookies
        .map(
          (c) => {
            'name': c.name,
            'value': c.value,
            'domain': c.domain,
            'path': c.path,
          },
        )
        .toList();
    await prefs.setString('sho_webview_cookies', jsonEncode(list));
  }

  Future<SHOUrlInterceptorResult> handleInterception(
    String url,
    List<SHOUrlInterceptor> interceptors,
  ) async {
    for (final interceptor in interceptors) {
      if (!url.contains(interceptor.pattern)) continue;
      switch (interceptor.type) {
        case SHOWebViewInterceptorType.block:
          return SHOUrlInterceptorResult.blocked();
        case SHOWebViewInterceptorType.override:
          if (interceptor.handler != null) {
            if (await interceptor.handler!(url)) {
              return SHOUrlInterceptorResult.intercepted();
            }
          }
        case SHOWebViewInterceptorType.navigateToNative:
          return SHOUrlInterceptorResult.navigateToNative(url);
      }
    }
    return SHOUrlInterceptorResult.allow();
  }

  Map<String, String> buildRequestHeaders(SHOWebViewConfig config) {
    final cacheControl = switch (config.cachePolicy) {
      SHOWebViewCachePolicy.noCache => 'no-cache',
      SHOWebViewCachePolicy.cacheFirst => 'max-age=3600',
      SHOWebViewCachePolicy.cacheOnly => 'only-if-cached',
      SHOWebViewCachePolicy.defaultPolicy => 'max-age=0',
    };
    return {'Cache-Control': cacheControl, ...?config.customHeaders};
  }
}

class SHOUrlInterceptorResult {
  const SHOUrlInterceptorResult({
    required this.allowed,
    this.intercepted = false,
    this.nativeUrl,
  });

  final bool allowed;
  final bool intercepted;
  final String? nativeUrl;

  factory SHOUrlInterceptorResult.allow() =>
      const SHOUrlInterceptorResult(allowed: true);

  factory SHOUrlInterceptorResult.blocked() =>
      const SHOUrlInterceptorResult(allowed: false, intercepted: true);

  factory SHOUrlInterceptorResult.intercepted() =>
      const SHOUrlInterceptorResult(allowed: false, intercepted: true);

  factory SHOUrlInterceptorResult.navigateToNative(String url) =>
      SHOUrlInterceptorResult(allowed: false, nativeUrl: url);
}
