import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/l10n/app_localizations.dart';
import 'package:shoo/features/after_sale/domain/entities/hos_after_sale.dart';
import 'package:shoo/features/after_sale/presentation/state/hos_after_sale_controller.dart';
import 'package:shoo/features/after_sale/presentation/widgets/hos_after_sale_status_label.dart';

class SHOAfterSaleListPage extends SHODataPage<List<SHOAfterSaleRequest>> {
  const SHOAfterSaleListPage({super.key});

  @override
  SHODataPageState<List<SHOAfterSaleRequest>, SHOAfterSaleListPage> createState() =>
      _SHOAfterSaleListPageState();
}

class _SHOAfterSaleListPageState
    extends SHODataPageState<List<SHOAfterSaleRequest>, SHOAfterSaleListPage> {
  @override
  ProviderListenable<AsyncValue<List<SHOAfterSaleRequest>>> get dataProvider =>
      afterSalesProvider;

  @override
  void invalidateData(WidgetRef ref) => ref.invalidate(afterSalesProvider);

  @override
  String get pageName => 'after_sale_list';

  @override
  bool isEmptyData(List<SHOAfterSaleRequest> data) => data.isEmpty;

  @override
  PreferredSizeWidget? buildPageAppBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppBar(title: Text(l10n.afterSaleListTitle));
  }

  @override
  Widget buildContent(
    BuildContext context,
    WidgetRef ref,
    List<SHOAfterSaleRequest> requests,
  ) {
    return ListView.separated(
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
    );
  }
}
