import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/widgets/hos_loading_state.dart';
import '../../../l10n/app_localizations.dart';
import 'hos_after_sale_controller.dart';
import 'hos_after_sale_status_label.dart';

class SHOAfterSaleListPage extends ConsumerWidget {
  const SHOAfterSaleListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final requestsAsync = ref.watch(afterSalesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.afterSaleListTitle)),
      body: requestsAsync.whenLoadingState(
        onRetry: () => ref.invalidate(afterSalesProvider),
        empty: (list) => list.isEmpty,
        data: (requests) => ListView.separated(
          padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: SHOAppSpacing.md),
          itemBuilder: (context, index) {
            final req = requests[index];
            return Container(
              padding: const EdgeInsets.all(SHOAppSpacing.lg),
              decoration: BoxDecoration(
                border: Border.all(color: SHOAppColors.border),
                borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        req.orderNo,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        shoAfterSaleStatusLabel(context, req.status),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: SHOAppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SHOAppSpacing.sm),
                  Text(
                    shoAfterSaleTypeLabel(context, req.type),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (req.productTitle.isNotEmpty) ...[
                    const SizedBox(height: SHOAppSpacing.xxs),
                    Text(req.productTitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                  const SizedBox(height: SHOAppSpacing.xs),
                  Text(req.reason, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: SHOAppSpacing.xs),
                  Text(req.createdAt, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
