import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/core/platform/webview/hos_payment_handler.dart';
import 'package:shoo/core/platform/webview/hos_url_navigator.dart';

/// 支付 / 外链 redirect 落地页：打开目标 URL 后自动返回。
class SHOActivityRedirectPage extends StatefulWidget {
  const SHOActivityRedirectPage({
    super.key,
    required this.url,
    required this.isPayment,
  });

  final String url;
  final bool isPayment;

  @override
  State<SHOActivityRedirectPage> createState() => _SHOActivityRedirectPageState();
}

class _SHOActivityRedirectPageState extends State<SHOActivityRedirectPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openAndPop());
  }

  Future<void> _openAndPop() async {
    if (widget.isPayment) {
      await SHOPaymentHandler.openPaymentUrl(widget.url);
    } else {
      await SHOURLNavigator.openInExternalBrowser(widget.url);
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
