import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/hos_analytics.dart';

/// 商品详情页曝光上报（每个 productId 仅上报一次）。
class SHOProductViewReporter extends ConsumerStatefulWidget {
  const SHOProductViewReporter({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<SHOProductViewReporter> createState() =>
      _SHOProductViewReporterState();
}

class _SHOProductViewReporterState extends ConsumerState<SHOProductViewReporter> {
  static final Set<String> _reported = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _report());
  }

  Future<void> _report() async {
    if (_reported.contains(widget.productId)) return;
    _reported.add(widget.productId);

    final source =
        GoRouterState.of(context).uri.queryParameters['source'] ?? 'direct';

    await SHOAnalyticsManager.instance.trackEvent(
      SHOAnalyticsRegistry.productView,
      {
        'product_id': widget.productId,
        'source': source,
      },
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
