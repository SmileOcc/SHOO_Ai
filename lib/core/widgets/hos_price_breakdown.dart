import 'package:flutter/material.dart';

import 'package:shoo/core/pricing/hos_price_calculator.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/utils/hos_price_formatter.dart';
import 'package:shoo/l10n/app_localizations.dart';

/// 结算价格明细行。
class SHOPriceBreakdownView extends StatelessWidget {
  const SHOPriceBreakdownView({super.key, required this.breakdown});

  final SHOPriceBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        _SHOPriceRow(
          label: l10n.priceSubtotal,
          value: priceFormatter.formatCents(breakdown.subtotalCents),
        ),
        if (breakdown.activitySavedCents > 0) ...[
          const SizedBox(height: SHOAppSpacing.sm),
          _SHOPriceRow(
            label: l10n.priceActivitySaved,
            value:
                '-${priceFormatter.formatCents(breakdown.activitySavedCents)}',
            valueColor: SHOAppColors.sale,
          ),
        ],
        if (breakdown.fullReductionCents > 0) ...[
          const SizedBox(height: SHOAppSpacing.sm),
          _SHOPriceRow(
            label: breakdown.fullReductionLabel ?? l10n.priceFullReduction,
            value:
                '-${priceFormatter.formatCents(breakdown.fullReductionCents)}',
            valueColor: SHOAppColors.sale,
          ),
        ],
        if (breakdown.discountCents > 0) ...[
          const SizedBox(height: SHOAppSpacing.sm),
          _SHOPriceRow(
            label: l10n.priceDiscount,
            value: '-${priceFormatter.formatCents(breakdown.discountCents)}',
            valueColor: SHOAppColors.sale,
          ),
        ],
        if (breakdown.shippingCents > 0) ...[
          const SizedBox(height: SHOAppSpacing.sm),
          _SHOPriceRow(
            label: l10n.priceShipping,
            value: priceFormatter.formatCents(breakdown.shippingCents),
          ),
        ],
        const SizedBox(height: SHOAppSpacing.md),
        const Divider(),
        const SizedBox(height: SHOAppSpacing.sm),
        _SHOPriceRow(
          label: l10n.orderTotalLabel,
          value: priceFormatter.formatCents(breakdown.totalCents),
          isTotal: true,
        ),
      ],
    );
  }
}

class _SHOPriceRow extends StatelessWidget {
  const _SHOPriceRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final style = isTotal
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: SHOAppColors.primary,
          )
        : Theme.of(context).textTheme.bodyMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? Theme.of(context).textTheme.titleSmall
              : Theme.of(context).textTheme.bodyMedium,
        ),
        Text(value, style: style?.copyWith(color: valueColor)),
      ],
    );
  }
}
