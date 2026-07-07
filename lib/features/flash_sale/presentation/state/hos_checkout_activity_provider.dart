import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoo/core/pricing/hos_full_reduction.dart';
import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_enums.dart';
import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_product.dart';

final checkoutActivityLinesProvider =
    StateProvider<Map<String, SHOCheckoutActivityLine>>((ref) => {});

void setCheckoutActivityLine(WidgetRef ref, SHOCheckoutActivityLine line) {
  ref
      .read(checkoutActivityLinesProvider.notifier)
      .update((state) => {...state, line.productId: line});
}

void clearCheckoutActivityLines(WidgetRef ref) {
  ref.read(checkoutActivityLinesProvider.notifier).state = {};
}

SHOCheckoutActivityLine? buildCheckoutActivityLine(
  SHOFlashSaleProduct product,
) {
  if (product.status != SHOFlashSaleProductStatus.ongoing) return null;

  final tiers = <SHOFullReductionTier>[];
  for (final tag in product.promoTags) {
    if (!tag.type.startsWith('full_reduction')) continue;
    final digits = RegExp(
      r'\d+',
    ).allMatches(tag.label).map((m) => m.group(0)).toList();
    if (digits.length >= 2) {
      tiers.add(
        SHOFullReductionTier(
          minOrderCents: (int.tryParse(digits[0]!) ?? 0) * 100,
          reductionCents: (int.tryParse(digits[1]!) ?? 0) * 100,
          label: tag.label,
        ),
      );
    }
  }

  return SHOCheckoutActivityLine(
    productId: product.id,
    sessionId: product.sessionId,
    unitPriceCents: product.activityPrice,
    originalUnitPriceCents: product.originalPrice,
    fullReductionTiers: tiers,
  );
}

SHOCheckoutActivityLine? buildCheckoutActivityLineFromActivity({
  required String productId,
  required SHOFlashSaleProductActivity activity,
}) {
  if (!activity.showActivityPrice) return null;

  final tiers = <SHOFullReductionTier>[];
  for (final tag in activity.promoTags) {
    if (!tag.type.startsWith('full_reduction')) continue;
    final digits = RegExp(
      r'\d+',
    ).allMatches(tag.label).map((m) => m.group(0)).toList();
    if (digits.length >= 2) {
      tiers.add(
        SHOFullReductionTier(
          minOrderCents: (int.tryParse(digits[0]!) ?? 0) * 100,
          reductionCents: (int.tryParse(digits[1]!) ?? 0) * 100,
          label: tag.label,
        ),
      );
    }
  }

  return SHOCheckoutActivityLine(
    productId: productId,
    sessionId: activity.sessionId,
    unitPriceCents: activity.activityPrice,
    originalUnitPriceCents: activity.originalPrice,
    fullReductionTiers: tiers,
  );
}

List<SHOFullReductionTier> mergedFullReductionTiers(
  Map<String, SHOCheckoutActivityLine> lines,
) {
  final all = <SHOFullReductionTier>[];
  for (final line in lines.values) {
    all.addAll(line.fullReductionTiers);
  }
  return all;
}

int checkoutActivitySavedCents({
  required Map<String, SHOCheckoutActivityLine> lines,
  required int quantityByProductId,
}) {
  var saved = 0;
  for (final line in lines.values) {
    if (line.originalUnitPriceCents <= line.unitPriceCents) continue;
    saved +=
        (line.originalUnitPriceCents - line.unitPriceCents) *
        quantityByProductId;
  }
  return saved;
}
