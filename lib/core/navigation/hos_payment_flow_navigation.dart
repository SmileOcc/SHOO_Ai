import 'package:go_router/go_router.dart';

import '../../app/router/hos_routes.dart';

/// 标记从支付成功页进入订单详情，返回时需跳过收银台与确认订单。
abstract final class SHOOrderDetailExtras {
  static const fromPaymentSuccess = Object();
}

bool isOrderDetailFromPaymentSuccess(Object? extra) =>
    identical(extra, SHOOrderDetailExtras.fromPaymentSuccess);

/// 关闭订单详情，并连续跳过栈中的收银台 / 确认订单页。
void popOrderDetailPastPaymentFlow(GoRouter router) {
  if (router.canPop()) router.pop();
  while (router.canPop()) {
    final path = router.state.uri.path;
    if (path.startsWith('/payment/') || path == SHOAppRoutes.checkout) {
      router.pop();
      continue;
    }
    break;
  }
}
