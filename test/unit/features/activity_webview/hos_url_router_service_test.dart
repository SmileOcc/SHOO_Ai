import 'package:flutter_test/flutter_test.dart';
import 'package:shoo/core/platform/webview/hos_url_decision.dart';
import 'package:shoo/core/platform/webview/hos_url_router_service.dart';

void main() {
  const router = SHOURLRouterService();

  group('SHOURLRouterService', () {
    test('allows myshop whitelist in webview', () {
      final decision = router.resolve('https://m.shoo.com/activity/2024');
      expect(decision.target, SHOURLTarget.inAppWebView);
    });

    test('routes wechat pay to payment', () {
      final decision = router.resolve(
        'https://wx.tenpay.com/mock/payment?orderId=1',
      );
      expect(decision.target, SHOURLTarget.payment);
    });

    test('routes unknown host to external browser', () {
      final decision = router.resolve('https://example.com/page');
      expect(decision.target, SHOURLTarget.externalBrowser);
    });

    test('routes weixin scheme to payment', () {
      final decision = router.resolve('weixin://wap/pay?prepayid=xxx');
      expect(decision.target, SHOURLTarget.payment);
    });
  });
}
