import 'package:shoo/core/platform/webview/hos_url_router_service.dart';

abstract final class SHOWebViewSecurity {
  static const blockedSchemes = {
    'weixin',
    'alipay',
    'alipays',
    'tel',
    'sms',
    'mailto',
  };

  static bool isWhitelistedHost(String url, {SHOURLRouterService? router}) {
    final service = router ?? const SHOURLRouterService();
    return service.shouldAllowWebViewNavigation(url);
  }

  static bool isBlockedScheme(String scheme) {
    return blockedSchemes.contains(scheme.toLowerCase());
  }
}
