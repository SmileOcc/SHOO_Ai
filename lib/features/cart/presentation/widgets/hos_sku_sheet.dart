import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/auth/hos_auth_guard.dart';
import 'package:shoo/core/constants/hos_constants.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/widgets/hos_button.dart';
import 'package:shoo/core/widgets/hos_dialog.dart';
import 'package:shoo/core/widgets/hos_network_image.dart';
import 'package:shoo/core/widgets/hos_price_text.dart';
import 'package:shoo/l10n/app_localizations.dart';
import 'package:shoo/features/product/domain/entities/hos_product_detail.dart';
import 'package:shoo/features/cart/data/repositories/hos_cart_reconcile_service.dart';
import 'package:shoo/features/cart/presentation/state/hos_cart_controller.dart';
import 'package:shoo/core/pricing/hos_full_reduction.dart';
import 'package:shoo/features/flash_sale/presentation/state/hos_checkout_activity_provider.dart';

enum SHOSkuSheetIntent { addToCart, buyNow, changeCartLine }

/// SKU 选择底部面板：尺码 + 数量 + 加入购物袋 / 立即购买 / 改规格。
class SHOSkuSheet extends ConsumerStatefulWidget {
  const SHOSkuSheet({
    super.key,
    required this.product,
    this.intent = SHOSkuSheetIntent.addToCart,
    this.checkoutActivityLine,
    this.sessionEndAt,
    this.replaceLineId,
    this.initialSize,
    this.initialQuantity = 1,
    this.maxStock,
  });

  final SHOProductDetail product;
  final SHOSkuSheetIntent intent;
  final SHOCheckoutActivityLine? checkoutActivityLine;
  final String? sessionEndAt;
  final String? replaceLineId;
  final String? initialSize;
  final int initialQuantity;
  final int? maxStock;

  /// 展示 SKU 面板。加入购物袋成功时返回 `true`（立即购买 / 改规格返回 `false`）。
  static Future<bool> show(
    BuildContext context,
    SHOProductDetail product, {
    SHOSkuSheetIntent intent = SHOSkuSheetIntent.addToCart,
    SHOCheckoutActivityLine? checkoutActivityLine,
    String? sessionEndAt,
    String? replaceLineId,
    String? initialSize,
    int initialQuantity = 1,
    int? maxStock,
    required WidgetRef ref,
  }) async {
    if (!SHOAuthGuard.requireAuth(context, ref)) {
      return false;
    }

    final result = await SHOAppDialog.showBottomSheet<bool>(
      context,
      isScrollControlled: true,
      child: SHOSkuSheet(
        product: product,
        intent: intent,
        checkoutActivityLine: checkoutActivityLine,
        sessionEndAt: sessionEndAt,
        replaceLineId: replaceLineId,
        initialSize: initialSize,
        initialQuantity: initialQuantity,
        maxStock: maxStock,
      ),
    );
    return result ?? false;
  }

  /// 从「尺码 M」/「Size M」解析尺码码。
  static String? parseSizeFromVariantLabel(String variantLabel) {
    final trimmed = variantLabel.trim();
    if (trimmed.isEmpty) return null;
    final parts = trimmed.split(RegExp(r'\s+'));
    final last = parts.isEmpty ? trimmed : parts.last;
    if (SHOAppConstants.defaultSkuSizes.contains(last)) return last;
    return null;
  }

  @override
  ConsumerState<SHOSkuSheet> createState() => _SHOSkuSheetState();
}

class _SHOSkuSheetState extends ConsumerState<SHOSkuSheet> {
  late String _size;
  late int _quantity;
  late int _maxStock;

  @override
  void initState() {
    super.initState();
    final preferred = widget.initialSize;
    _size = preferred != null &&
            SHOAppConstants.defaultSkuSizes.contains(preferred)
        ? preferred
        : SHOAppConstants.defaultSkuSizes[1];
    _maxStock = (widget.maxStock != null && widget.maxStock! > 0)
        ? widget.maxStock!
        : SHOCartReconcileService.mockStockFor(widget.product.id);
    _quantity = widget.initialQuantity.clamp(1, _maxStock);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final variantLabel = '${l10n.skuSizeLabel} $_size';

    if (widget.intent == SHOSkuSheetIntent.changeCartLine) {
      final lineId = widget.replaceLineId;
      if (lineId == null || lineId.isEmpty) return;
      await ref.read(cartProvider.notifier).changeVariant(
            lineId: lineId,
            newVariantLabel: variantLabel,
            quantity: _quantity,
            expectedProductId: widget.product.id,
          );
      if (!mounted) return;
      Navigator.pop(context, false);
      return;
    }

    await ref.read(cartProvider.notifier).addProduct(
          product: widget.product,
          variantLabel: variantLabel,
          quantity: _quantity,
          stock: _maxStock,
          activity: widget.checkoutActivityLine,
          sessionEndAt: widget.sessionEndAt,
        );
    if (!mounted) return;

    if (widget.intent == SHOSkuSheetIntent.buyNow) {
      Navigator.pop(context, false);
      final line = widget.checkoutActivityLine;
      if (line != null) {
        setCheckoutActivityLine(ref, line);
      }
      await context.push(SHOAppRoutes.checkout);
      return;
    }

    // 加购成功：交给调用方播放飞入动画后再提示。
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final product = widget.product;
    final isChange = widget.intent == SHOSkuSheetIntent.changeCartLine;

    return Padding(
      padding: EdgeInsets.only(
        left: SHOAppSpacing.pagePadding,
        right: SHOAppSpacing.pagePadding,
        top: SHOAppSpacing.lg,
        bottom: MediaQuery.paddingOf(context).bottom + SHOAppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: SHOAppNetworkImage(
                    url: product.imageUrl,
                  ),
                ),
              ),
              const SizedBox(width: SHOAppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: SHOAppSpacing.sm),
                    SHOAppPriceText(priceCents: product.price),
                    const SizedBox(height: SHOAppSpacing.xs),
                    Text(
                      l10n.cartStockLeft(_maxStock),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: SHOAppColors.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SHOAppSpacing.xl),
          Text(
            l10n.skuSelectSize,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: SHOAppSpacing.md),
          Wrap(
            spacing: SHOAppSpacing.sm,
            runSpacing: SHOAppSpacing.sm,
            children: SHOAppConstants.defaultSkuSizes.map((size) {
              final selected = _size == size;
              return ChoiceChip(
                label: Text(size),
                selected: selected,
                onSelected: (_) => setState(() => _size = size),
                selectedColor: SHOAppColors.primary.withValues(alpha: 0.15),
              );
            }).toList(),
          ),
          const SizedBox(height: SHOAppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.skuQuantity,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline, size: 22),
                  ),
                  Text(
                    '$_quantity',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    onPressed: _quantity < _maxStock
                        ? () => setState(() => _quantity++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline, size: 22),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: SHOAppSpacing.xl),
          SHOAppButton(
            label: isChange
                ? l10n.cartConfirmSku
                : widget.intent == SHOSkuSheetIntent.buyNow
                    ? l10n.productBuyNow
                    : l10n.productAddToBag,
            variant: widget.intent == SHOSkuSheetIntent.buyNow
                ? SHOAppButtonVariant.accent
                : SHOAppButtonVariant.primary,
            isExpanded: true,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
