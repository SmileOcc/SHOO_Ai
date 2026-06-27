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
import 'package:shoo/features/cart/presentation/state/hos_cart_controller.dart';
import 'package:shoo/core/pricing/hos_full_reduction.dart';
import 'package:shoo/features/flash_sale/presentation/state/hos_checkout_activity_provider.dart';

enum SHOSkuSheetIntent { addToCart, buyNow }

/// SKU 选择底部面板：尺码 + 数量 + 加入购物袋 / 立即购买。
class SHOSkuSheet extends ConsumerStatefulWidget {
  const SHOSkuSheet({
    super.key,
    required this.product,
    this.intent = SHOSkuSheetIntent.addToCart,
    this.checkoutActivityLine,
  });

  final SHOProductDetail product;
  final SHOSkuSheetIntent intent;
  final SHOCheckoutActivityLine? checkoutActivityLine;

  static Future<void> show(
    BuildContext context,
    SHOProductDetail product, {
    SHOSkuSheetIntent intent = SHOSkuSheetIntent.addToCart,
    SHOCheckoutActivityLine? checkoutActivityLine,
    required WidgetRef ref,
  }) {
    if (!SHOAuthGuard.requireAuth(context, ref)) {
      return Future.value();
    }

    return SHOAppDialog.showBottomSheet(
      context,
      child: SHOSkuSheet(
        product: product,
        intent: intent,
        checkoutActivityLine: checkoutActivityLine,
      ),
    );
  }

  @override
  ConsumerState<SHOSkuSheet> createState() => _SHOSkuSheetState();
}

class _SHOSkuSheetState extends ConsumerState<SHOSkuSheet> {
  late String _size;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _size = SHOAppConstants.defaultSkuSizes[1];
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final variantLabel = '${l10n.skuSizeLabel} $_size';
    await ref.read(cartProvider.notifier).addProduct(
          product: widget.product,
          variantLabel: variantLabel,
          quantity: _quantity,
        );
    if (!mounted) return;
    Navigator.pop(context);

    if (widget.intent == SHOSkuSheetIntent.buyNow) {
      final line = widget.checkoutActivityLine;
      if (line != null) {
        setCheckoutActivityLine(ref, line);
      }
      context.push(SHOAppRoutes.checkout);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.productAddToBagSuccess)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final product = widget.product;

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
                  child: SHOAppNetworkImage(url: product.imageUrl, fit: BoxFit.cover),
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
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SHOAppSpacing.xl),
          Text(
            l10n.skuSelectSize,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
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
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline, size: 22),
                  ),
                  Text('$_quantity', style: Theme.of(context).textTheme.titleMedium),
                  IconButton(
                    onPressed: _quantity < 99
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
            label: widget.intent == SHOSkuSheetIntent.buyNow
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
