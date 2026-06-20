import 'package:shoo/core/platform/webview/hos_url_decision.dart';

class SHOURLRouterService {
  const SHOURLRouterService({this.config = const SHOURLRouterConfig()});

  final SHOURLRouterConfig config;

  SHOURLDecision resolve(String rawUrl) {
    final url = rawUrl.trim();
    if (url.isEmpty) {
      return SHOURLDecision(target: SHOURLTarget.externalBrowser, url: url);
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      return SHOURLDecision(target: SHOURLTarget.externalBrowser, url: url);
    }

    final scheme = uri.scheme.toLowerCase();
    if (_isBlockedScheme(scheme)) {
      return SHOURLDecision(target: SHOURLTarget.externalBrowser, url: url);
    }

    if (scheme == 'weixin' || scheme == 'alipays' || scheme == 'alipay') {
      return SHOURLDecision(target: SHOURLTarget.payment, url: url);
    }

    final host = uri.host.toLowerCase();
    if (host.isEmpty && (scheme == 'http' || scheme == 'https')) {
      return SHOURLDecision(target: SHOURLTarget.inAppWebView, url: url);
    }

    if (_hostMatchesAny(host, config.paymentDomains) ||
        _hostMatchesAny(host, config.bankDomains)) {
      return SHOURLDecision(target: SHOURLTarget.payment, url: url);
    }

    if (_hostMatchesAny(host, config.externalDomains)) {
      return SHOURLDecision(target: SHOURLTarget.externalBrowser, url: url);
    }

    if (_hostMatchesAny(host, config.whitelist) ||
        _hostEndsWithAny(host, config.whitelist)) {
      return SHOURLDecision(target: SHOURLTarget.inAppWebView, url: url);
    }

    return SHOURLDecision(target: SHOURLTarget.externalBrowser, url: url);
  }

  bool shouldAllowWebViewNavigation(String url) {
    final decision = resolve(url);
    return decision.target == SHOURLTarget.inAppWebView;
  }

  bool _isBlockedScheme(String scheme) {
    return const {'tel', 'sms', 'mailto'}.contains(scheme);
  }

  bool _hostMatchesAny(String host, List<String> domains) {
    for (final domain in domains) {
      if (host == domain) return true;
    }
    return false;
  }

  bool _hostEndsWithAny(String host, List<String> domains) {
    for (final domain in domains) {
      if (host == domain || host.endsWith('.$domain')) return true;
    }
    return false;
  }
}
