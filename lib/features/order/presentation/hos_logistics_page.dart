import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/widgets/hos_loading_state.dart';
import '../../../core/widgets/hos_logistics_timeline.dart';
import '../../../l10n/app_localizations.dart';
import 'hos_order_controller.dart';

class SHOLogisticsPage extends ConsumerWidget {
  const SHOLogisticsPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final trackAsync = ref.watch(orderLogisticsProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.logisticsTitle)),
      body: trackAsync.whenLoadingState(
        onRetry: () => ref.invalidate(orderLogisticsProvider(orderId)),
        data: (track) => ListView(
          padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
          children: [
            Container(
              padding: const EdgeInsets.all(SHOAppSpacing.lg),
              decoration: BoxDecoration(
                color: SHOAppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.logisticsCarrierLabel,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    track.carrier,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: SHOAppSpacing.md),
                  Text(
                    l10n.logisticsTrackingNoLabel,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          track.trackingNumber,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: track.trackingNumber),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.logisticsCopied)),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: SHOAppSpacing.xl),
            Text(
              l10n.logisticsTimelineTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: SHOAppSpacing.lg),
            SHOLogisticsTimeline(events: track.events),
          ],
        ),
      ),
    );
  }
}
