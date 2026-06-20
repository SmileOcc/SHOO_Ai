enum SHOURLTarget { inAppWebView, externalBrowser, payment }

class SHOURLDecision {
  const SHOURLDecision({required this.target, required this.url});

  final SHOURLTarget target;
  final String url;
}

class SHOURLRouterConfig {
  const SHOURLRouterConfig({
    this.whitelist = const ['shoo.com', 'm.shoo.com', 'localhost', '127.0.0.1'],
    this.paymentDomains = const [
      'wx.tenpay.com',
      'payapp.weixin.qq.com',
      'alipay.com',
      'alipaydev.com',
      'm.alipay.com',
    ],
    this.bankDomains = const [
      'icbc.com.cn',
      'ccb.com',
      'cmbchina.com',
      'abchina.com',
      'bankofchina.com',
      'bankcomm.com',
      'spdb.com.cn',
      'citicbank.com',
      'cebbank.com',
    ],
    this.externalDomains = const [
      'open.weixin.qq.com',
      'api.weibo.com',
      'apps.apple.com',
      'play.google.com',
      't.cn',
      'dwz.cn',
    ],
  });

  final List<String> whitelist;
  final List<String> paymentDomains;
  final List<String> bankDomains;
  final List<String> externalDomains;

  factory SHOURLRouterConfig.fromJson(Map<String, dynamic> json) {
    List<String> listOf(dynamic value) =>
        (value as List<dynamic>? ?? const []).map((e) => e.toString()).toList();

    return SHOURLRouterConfig(
      whitelist: listOf(json['whitelist']),
      paymentDomains: listOf(json['paymentDomains']),
      externalDomains: listOf(json['externalDomains']),
    );
  }
}
