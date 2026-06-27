import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/core/analytics/hos_page_analytics.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/platform/webview/hos_payment_handler.dart';
import 'package:shoo/core/platform/webview/hos_url_navigator.dart';

/// 支付 / 外链 redirect 落地页：打开目标 URL 后自动返回。
class SHOActivityRedirectPage extends ConsumerStatefulWidget {
  const SHOActivityRedirectPage({
    super.key,
    required this.url,
    required this.isPayment,
  });

  final String url;
  final bool isPayment;

  @override
  ConsumerState<SHOActivityRedirectPage> createState() =>
      _SHOActivityRedirectPageState();
}

class _SHOActivityRedirectPageState extends ConsumerState<SHOActivityRedirectPage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  @override
  String get pageName => 'activity_redirect';

  @override
  Map<String, Object?> get pageAnalyticsExtra => {
        'is_payment': widget.isPayment,
      };

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
    return buildTrackedPage(
      const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
