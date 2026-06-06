import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/feedback/hos_toast.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/utils/hos_price_formatter.dart';
import '../../../core/widgets/hos_button.dart';
import '../../../core/widgets/hos_dialog.dart';
import '../../../core/widgets/hos_empty_state.dart';
import '../../../core/widgets/hos_network_image.dart';
import '../../../l10n/app_localizations.dart';
import '../data/hos_cart_reconcile_service.dart';
import '../domain/hos_cart.dart';
import 'hos_cart_controller.dart';

class SHOCartPage extends ConsumerStatefulWidget {
  const SHOCartPage({super.key});

  @override
  ConsumerState<SHOCartPage> createState() => _SHOCartPageState();
}

class _SHOCartPageState extends ConsumerState<SHOCartPage> {
  bool _reconciling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reconcileCart());
  }

  Future<void> _reconcileCart() async {
    final cart = ref.read(cartProvider);
    if (cart.items.isEmpty || _reconciling) return;

    setState(() => _reconciling = true);
    try {
      final report =
          await ref.read(cartReconcileServiceProvider).reconcile(cart);
      if (report.hasIssues) {
        await ref
            .read(cartProvider.notifier)
            .applyReconciledItems(report.updatedItems);
        if (mounted) {
          SHOAppToast.info(_cartIssueMessage(AppLocalizations.of(context), report));
        }
      }
    } catch (_) {
      // 静默失败，不影响购物车主流程
    } finally {
      if (mounted) setState(() => _reconciling = false);
    }
  }

  String _cartIssueMessage(AppLocalizations l10n, SHOCartReconcileReport report) {
    if (report.unavailableCount > 0 && report.priceChangedCount > 0) {
      return l10n.cartIssuesBoth(
        report.unavailableCount,
        report.priceChangedCount,
      );
    }
    if (report.unavailableCount > 0) {
      return l10n.cartIssuesUnavailable(report.unavailableCount);
    }
    return l10n.cartIssuesPriceChanged(report.priceChangedCount);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cart = ref.watch(cartProvider);
    final hasUnavailable = cart.items.any((item) => item.unavailable);

    if (cart.items.isEmpty) {
      return SHOEmptyState(
        title: l10n.cartEmptyTitle,
        subtitle: l10n.cartEmptySubtitle,
        icon: Icons.shopping_bag_outlined,
        actionLabel: l10n.cartEmptyAction,
        onAction: () => context.go(SHOAppRoutes.home),
      );
    }

    return Column(
      children: [
        if (hasUnavailable)
          MaterialBanner(
            content: Text(l10n.cartUnavailableBanner),
            leading: const Icon(Icons.warning_amber_rounded),
            actions: [
              TextButton(
                onPressed: () =>
                    ref.read(cartProvider.notifier).removeUnavailableItems(),
                child: Text(l10n.cartRemoveUnavailable),
              ),
            ],
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
            itemCount: cart.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: SHOAppSpacing.md),
            itemBuilder: (context, index) => _SHOCartLineTile(
              item: cart.items[index],
              onToggle: () => ref
                  .read(cartProvider.notifier)
                  .toggleSelected(cart.items[index].id),
              onIncrement: () => ref.read(cartProvider.notifier).updateQuantity(
                    cart.items[index].id,
                    cart.items[index].quantity + 1,
                  ),
              onDecrement: () {
                final item = cart.items[index];
                if (item.quantity <= 1) return;
                ref.read(cartProvider.notifier).updateQuantity(
                      item.id,
                      item.quantity - 1,
                    );
              },
              onRemove: () async {
                final ok = await SHOAppDialog.confirm(
                  context,
                  title: l10n.cartRemoveTitle,
                  message: l10n.cartRemoveMessage,
                  confirmLabel: l10n.cartRemoveConfirm,
                  isDestructive: true,
                );
                if (ok) {
                  await ref
                      .read(cartProvider.notifier)
                      .removeItem(cart.items[index].id);
                }
              },
            ),
          ),
        ),
        _SHOCartFooter(
          cart: cart,
          onSelectAll: (v) => ref.read(cartProvider.notifier).selectAll(v),
          onCheckout: cart.selectedCount > 0 && !hasUnavailable
              ? () => context.push(SHOAppRoutes.checkout)
              : null,
        ),
      ],
    );
  }
}

class _SHOCartLineTile extends StatelessWidget {
  const _SHOCartLineTile({
    required this.item,
    required this.onToggle,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final SHOCartItem item;
  final VoidCallback onToggle;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Opacity(
      opacity: item.unavailable ? 0.45 : 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: item.selected && !item.unavailable,
            onChanged: item.unavailable ? null : (_) => onToggle(),
            activeColor: SHOAppColors.primary,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
            child: SizedBox(
              width: 72,
              height: 72,
              child: SHOAppNetworkImage(
                url: item.imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 144,
              ),
            ),
          ),
          const SizedBox(width: SHOAppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                ),
                if (item.unavailable)
                  Text(
                    l10n.cartItemUnavailable,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SHOAppColors.error,
                        ),
                  ),
                if (item.priceChanged && !item.unavailable)
                  Text(
                    l10n.cartItemPriceUpdated,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SHOAppColors.warning,
                        ),
                  ),
                if (item.variantLabel.isNotEmpty) ...[
                  const SizedBox(height: SHOAppSpacing.xxs),
                  Text(item.variantLabel, style: Theme.of(context).textTheme.bodySmall),
                ],
                const SizedBox(height: SHOAppSpacing.sm),
                Row(
                  children: [
                    Text(
                      priceFormatter.formatCents(item.price),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: SHOAppColors.sale,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: item.unavailable ? null : onDecrement,
                      icon: const Icon(Icons.remove, size: 16),
                    ),
                    Text('${item.quantity}'),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: item.unavailable ? null : onIncrement,
                      icon: const Icon(Icons.add, size: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline, size: 18),
          ),
        ],
      ),
    );
  }
}

class _SHOCartFooter extends StatelessWidget {
  const _SHOCartFooter({
    required this.cart,
    required this.onSelectAll,
    required this.onCheckout,
  });

  final SHOCartSnapshot cart;
  final ValueChanged<bool> onSelectAll;
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
        decoration: const BoxDecoration(
          color: SHOAppColors.surface,
          border: Border(top: BorderSide(color: SHOAppColors.border)),
        ),
        child: Row(
          children: [
            Checkbox(
              value: cart.allSelected,
              tristate: true,
              onChanged: (v) => onSelectAll(v ?? false),
            ),
            Text(l10n.cartSelectAll, style: Theme.of(context).textTheme.bodySmall),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(l10n.cartTotalLabel, style: Theme.of(context).textTheme.bodySmall),
                Text(
                  priceFormatter.formatCents(cart.selectedTotalCents),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: SHOAppColors.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(width: SHOAppSpacing.lg),
            SHOAppButton(
              label: l10n.cartCheckout(cart.selectedCount),
              onPressed: onCheckout,
              size: SHOAppButtonSize.md,
            ),
          ],
        ),
      ),
    );
  }
}
