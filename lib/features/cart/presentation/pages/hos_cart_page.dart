import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/auth/hos_auth_guard.dart';
import 'package:shoo/core/feedback/hos_toast.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/pricing/hos_price_calculator.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/theme/hos_theme_extension.dart';
import 'package:shoo/core/utils/hos_price_formatter.dart';
import 'package:shoo/core/widgets/hos_button.dart';
import 'package:shoo/core/widgets/hos_dialog.dart';
import 'package:shoo/core/widgets/hos_empty_state.dart';
import 'package:shoo/core/widgets/hos_network_image.dart';
import 'package:shoo/core/widgets/hos_product_card.dart';
import 'package:shoo/core/widgets/hos_skeleton_box.dart';
import 'package:shoo/features/address/presentation/state/hos_address_controller.dart';
import 'package:shoo/features/auth/presentation/state/hos_session_provider.dart';
import 'package:shoo/features/cart/data/repositories/hos_cart_reconcile_service.dart';
import 'package:shoo/features/cart/domain/entities/hos_cart.dart';
import 'package:shoo/features/cart/domain/hos_cart_pricing.dart';
import 'package:shoo/features/cart/presentation/state/hos_cart_controller.dart';
import 'package:shoo/features/cart/presentation/state/hos_cart_manage_provider.dart';
import 'package:shoo/features/cart/presentation/widgets/hos_cart_marquee_banner.dart';
import 'package:shoo/features/cart/presentation/widgets/hos_sku_sheet.dart';
import 'package:shoo/features/coupon/domain/entities/hos_coupon.dart';
import 'package:shoo/features/coupon/presentation/state/hos_coupon_controller.dart';
import 'package:shoo/features/home/presentation/state/hos_home_controller.dart';
import 'package:shoo/features/product/presentation/state/hos_product_controller.dart';
import 'package:shoo/features/profile/data/datasources/local/hos_profile_activity_storage.dart';
import 'package:shoo/features/profile/presentation/state/hos_profile_controller.dart';
import 'package:shoo/l10n/app_localizations.dart';

/// 购物车页面，展示用户已添加的商品列表。
///
/// 核心功能：
/// - 登录态检查：未登录时显示登录引导
/// - 购物车项分组展示：可用商品和不可用商品分别显示
/// - 滑动操作：左滑显示收藏和删除按钮
/// - 管理模式：支持批量选择和删除
/// - 结算功能：底部显示选中商品总价和结算按钮
/// - 购物车对账：页面初始化时自动同步商品价格、库存等状态
///
/// 混合了页面路由分析 [SHOPageRouteAnalyticsMixin]、页面基础功能 [SHOAppPageMixin]
/// 和页面追踪 [SHOAppTrackedPageMixin]。
class SHOCartPage extends ConsumerStatefulWidget {
  const SHOCartPage({super.key});

  @override
  ConsumerState<SHOCartPage> createState() => _SHOCartPageState();
}

class _SHOCartPageState extends ConsumerState<SHOCartPage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  /// 是否正在进行购物车对账（同步价格、库存等状态）。
  bool _reconciling = false;

  /// 管理模式下选中的商品 ID 集合。
  final _manageSelected = <String>{};

  /// 当前展开滑动操作的行 ID，用于控制同一时间只展开一行。
  String? _openSwipeLineId;

  /// 页面名称，用于分析和追踪。
  @override
  String get pageName => 'cart';

  @override
  void initState() {
    super.initState();
    // 页面渲染完成后触发购物车对账
    WidgetsBinding.instance.addPostFrameCallback((_) => _reconcileCart());
  }

  /// 清除管理模式下的选择状态，并关闭滑动操作。
  void _clearManageSelection() {
    if (_manageSelected.isEmpty && _openSwipeLineId == null) return;
    setState(() {
      _manageSelected.clear();
      _openSwipeLineId = null;
    });
  }

  /// 设置当前展开滑动操作的行 ID。
  ///
  /// [lineId] 为 null 表示关闭所有滑动操作。
  void _setOpenSwipe(String? lineId) {
    if (_openSwipeLineId == lineId) return;
    setState(() => _openSwipeLineId = lineId);
  }

  /// 收藏/取消收藏购物车商品。
  ///
  /// 收藏成功后显示 Toast 提示，并关闭滑动操作。
  Future<void> _favoriteCartItem(SHOCartItem item) async {
    final l10n = AppLocalizations.of(context);
    final added = await ref
        .read(profileActivityProvider.notifier)
        .toggleFavorite(
          item.productId,
          cache: SHOProfileProductCache(
            title: item.title,
            imageUrl: item.imageUrl,
            price: item.price,
            originalPrice: item.listPrice,
          ),
        );
    if (!mounted) return;
    _setOpenSwipe(null);
    SHOAppToast.success(
      added ? l10n.profileFavoriteAdded : l10n.profileFavoriteRemoved,
    );
  }

  /// 删除单个购物车商品。
  ///
  /// 弹出确认对话框，确认后从购物车中移除商品。
  Future<void> _removeCartItem(SHOCartItem item) async {
    final l10n = AppLocalizations.of(context);
    _setOpenSwipe(null);
    final ok = await SHOAppDialog.confirm(
      context,
      title: l10n.cartRemoveTitle,
      message: l10n.cartRemoveMessage,
      confirmLabel: l10n.cartRemoveConfirm,
      isDestructive: true,
    );
    if (ok) {
      await ref.read(cartProvider.notifier).removeItem(item.id);
    }
  }

  /// 购物车对账：同步服务器上的商品价格、库存、活动状态。
  ///
  /// 页面初始化时自动调用，检查并更新过期、缺货、价格变动的商品。
  /// 对账过程中静默失败，不影响购物车主流程。
  Future<void> _reconcileCart() async {
    if (!ref.read(sessionProvider).isAuthenticated) return;

    final cart = ref.read(cartProvider);
    if (cart.items.isEmpty || _reconciling) return;

    setState(() => _reconciling = true);
    try {
      final report = await ref
          .read(cartReconcileServiceProvider)
          .reconcile(cart);
      await ref
          .read(cartProvider.notifier)
          .applyReconciledItems(report.updatedItems);
      if (report.hasIssues && mounted) {
        SHOAppToast.info(
          _cartIssueMessage(AppLocalizations.of(context), report),
        );
      }
    } catch (_) {
      // 静默失败，不影响购物车主流程
    } finally {
      if (mounted) setState(() => _reconciling = false);
    }
  }

  /// 生成购物车对账问题的提示消息。
  ///
  /// 根据对账报告中的各类问题数量，拼接成可读的提示文本。
  String _cartIssueMessage(
    AppLocalizations l10n,
    SHOCartReconcileReport report,
  ) {
    final parts = <String>[];
    if (report.unavailableCount > 0) {
      parts.add(l10n.cartIssuesUnavailable(report.unavailableCount));
    }
    if (report.priceChangedCount > 0) {
      parts.add(l10n.cartIssuesPriceChanged(report.priceChangedCount));
    }
    if (report.stockClampedCount > 0) {
      parts.add(l10n.cartStockClamped(report.stockClampedCount));
    }
    if (report.activityExpiredCount > 0) {
      parts.add(l10n.cartActivityExpiredToast(report.activityExpiredCount));
    }
    return parts.join(' · ');
  }

  /// 更换购物车商品的规格（SKU）。
  ///
  /// 加载商品详情后弹出规格选择弹窗，替换原有购物车项。
  Future<void> _changeSku(SHOCartItem item) async {
    if (item.unavailable) return;
    try {
      final detail = await ref.read(
        productDetailProvider(item.productId).future,
      );
      if (!mounted) return;
      await SHOSkuSheet.show(
        context,
        detail,
        intent: SHOSkuSheetIntent.changeCartLine,
        replaceLineId: item.id,
        initialSize: SHOSkuSheet.parseSizeFromVariantLabel(item.variantLabel),
        initialQuantity: item.quantity,
        maxStock: item.stock,
        ref: ref,
      );
    } catch (_) {
      if (mounted) {
        SHOAppToast.error(AppLocalizations.of(context).loadFailed);
      }
    }
  }

  /// 删除管理模式下选中的所有商品。
  ///
  /// 弹出确认对话框，确认后批量删除选中商品，并退出管理模式。
  Future<void> _deleteManageSelected() async {
    final l10n = AppLocalizations.of(context);
    if (_manageSelected.isEmpty) return;
    final ok = await SHOAppDialog.confirm(
      context,
      title: l10n.cartRemoveTitle,
      message: l10n.cartRemoveMessage,
      confirmLabel: l10n.cartDeleteSelected,
      isDestructive: true,
    );
    if (!ok) return;
    await ref.read(cartProvider.notifier).removeItems(_manageSelected);
    ref.read(cartManageModeProvider.notifier).state = false;
    _clearManageSelection();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    final cart = ref.watch(cartProvider);
    final managing = ref.watch(cartManageModeProvider);
    ref.listen<bool>(cartManageModeProvider, (previous, next) {
      if (next && _openSwipeLineId != null) {
        _setOpenSwipe(null);
      }
      if (previous == true && next == false) {
        _clearManageSelection();
      }
    });

    if (!session.isAuthenticated) {
      return buildTrackedPage(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SHOCartMarqueeBanner(),
            Expanded(
              child: SHOEmptyState(
                title: l10n.cartLoginTitle,
                subtitle: l10n.cartLoginSubtitle,
                icon: Icons.person_outline_rounded,
                actionLabel: l10n.cartLoginAction,
                onAction: () => context.push(
                  SHOAuthGuard.loginPath(
                    redirectTo: GoRouterState.of(context).uri.toString(),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (cart.items.isEmpty) {
      return buildTrackedPage(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SHOCartMarqueeBanner(),
            Expanded(
              child: _SHOCartEmptyWithRecommendations(
                onBrowse: () {
                  if (context.canPop()) {
                    context.pop();
                    return;
                  }
                  context.go(SHOAppRoutes.home);
                },
              ),
            ),
          ],
        ),
      );
    }

    final available = cart.availableItems;
    final unavailable = cart.unavailableItems;

    return buildTrackedPage(
      Column(
        children: [
          const SHOCartMarqueeBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                SHOAppSpacing.pagePadding,
                SHOAppSpacing.sm,
                SHOAppSpacing.pagePadding,
                SHOAppSpacing.pagePadding,
              ),
              children: [
                if (available.isNotEmpty)
                  _SHOCartGroupCard(
                    title: l10n.cartSectionAvailable,
                    count: available.length,
                    children: [
                      for (final (i, item) in available.indexed) ...[
                        if (i > 0) const Divider(height: 1, thickness: 1),
                        _SHOCartLineTile(
                          key: ValueKey(item.id),
                          item: item,
                          managing: managing,
                          manageSelected: _manageSelected.contains(item.id),
                          favorited: ref
                              .watch(profileActivityProvider)
                              .favorites
                              .contains(item.productId),
                          swipeOpen: !managing && _openSwipeLineId == item.id,
                          onSwipeOpenChanged: managing
                              ? null
                              : (open) => _setOpenSwipe(open ? item.id : null),
                          onManageToggle: () {
                            setState(() {
                              if (_manageSelected.contains(item.id)) {
                                _manageSelected.remove(item.id);
                              } else {
                                _manageSelected.add(item.id);
                              }
                            });
                          },
                          onOpenProduct: () {
                            _setOpenSwipe(null);
                            context.push(SHOAppRoutes.product(item.productId));
                          },
                          onToggle: () => ref
                              .read(cartProvider.notifier)
                              .toggleSelected(item.id),
                          onIncrement: () {
                            if (item.quantity >= item.stock) {
                              SHOAppToast.info(l10n.cartMaxStockReached);
                              return;
                            }
                            ref
                                .read(cartProvider.notifier)
                                .updateQuantity(item.id, item.quantity + 1);
                          },
                          onDecrement: () {
                            if (item.quantity <= 1) return;
                            ref
                                .read(cartProvider.notifier)
                                .updateQuantity(item.id, item.quantity - 1);
                          },
                          onChangeSku: () {
                            _setOpenSwipe(null);
                            _changeSku(item);
                          },
                          onFavorite: () => _favoriteCartItem(item),
                          onRemove: () => _removeCartItem(item),
                        ),
                      ],
                    ],
                  ),
                if (available.isNotEmpty && unavailable.isNotEmpty)
                  const SizedBox(height: SHOAppSpacing.lg),
                if (unavailable.isNotEmpty)
                  _SHOCartGroupCard(
                    title: l10n.cartSectionUnavailable,
                    count: unavailable.length,
                    actionLabel: l10n.cartRemoveUnavailable,
                    onAction: () => ref
                        .read(cartProvider.notifier)
                        .removeUnavailableItems(),
                    children: [
                      for (final (i, item) in unavailable.indexed) ...[
                        if (i > 0) const Divider(height: 1, thickness: 1),
                        _SHOCartLineTile(
                          key: ValueKey('unavailable-${item.id}'),
                          item: item,
                          managing: false,
                          manageSelected: false,
                          favorited: ref
                              .watch(profileActivityProvider)
                              .favorites
                              .contains(item.productId),
                          swipeOpen: _openSwipeLineId == item.id,
                          onSwipeOpenChanged: (open) =>
                              _setOpenSwipe(open ? item.id : null),
                          onManageToggle: null,
                          onOpenProduct: () {
                            _setOpenSwipe(null);
                            context.push(SHOAppRoutes.product(item.productId));
                          },
                          onToggle: () {},
                          onIncrement: () {},
                          onDecrement: () {},
                          onChangeSku: () {},
                          onFavorite: () => _favoriteCartItem(item),
                          onRemove: () => _removeCartItem(item),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
          if (managing)
            _SHOCartManageFooter(
              selectedCount: _manageSelected.length,
              onSelectAll: () {
                setState(() {
                  if (_manageSelected.length == available.length) {
                    _manageSelected.clear();
                  } else {
                    _manageSelected
                      ..clear()
                      ..addAll(available.map((e) => e.id));
                  }
                });
              },
              allSelected:
                  available.isNotEmpty &&
                  _manageSelected.length == available.length,
              onDelete: _deleteManageSelected,
            )
          else if (cart.items.isNotEmpty)
            _SHOCartFooter(
              cart: cart,
              onSelectAll: (v) => ref.read(cartProvider.notifier).selectAll(v),
              onPickCoupon: () => context.push(SHOAppRoutes.couponsSelect),
              onCheckout: cart.selectedCount > 0
                  ? () {
                      if (!SHOAuthGuard.requireAuth(context, ref)) {
                        return;
                      }
                      syncCheckoutActivityFromCart(ref, cart.selectedItems);
                      final fromCartStack =
                          GoRouterState.of(context).uri.path ==
                          SHOAppRoutes.cartStack;
                      context.push(
                        SHOAppRoutes.checkoutWithContext(
                          fromCartStack: fromCartStack,
                        ),
                      );
                    }
                  : null,
            ),
        ],
      ),
    );
  }
}

class _SHOCartGroupCard extends StatelessWidget {
  const _SHOCartGroupCard({
    required this.title,
    required this.count,
    required this.children,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final int count;
  final List<Widget> children;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.shoSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.shoTheme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SHOAppSpacing.lg,
              SHOAppSpacing.lg,
              SHOAppSpacing.md,
              SHOAppSpacing.md,
            ),
            child: Row(
              children: [
                Text(
                  '$title ($count)',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                if (actionLabel != null && onAction != null)
                  TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(actionLabel!),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          ...children,
        ],
      ),
    );
  }
}

class _SHOCartEmptyWithRecommendations extends ConsumerWidget {
  const _SHOCartEmptyWithRecommendations({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final feedAsync = ref.watch(homeFeedProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: SHOAppSpacing.xl),
            child: SHOEmptyState(
              title: l10n.cartEmptyTitle,
              subtitle: l10n.cartEmptySubtitle,
              icon: Icons.shopping_bag_outlined,
              actionLabel: l10n.cartEmptyAction,
              onAction: onBrowse,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              SHOAppSpacing.pagePadding,
              SHOAppSpacing.md,
              SHOAppSpacing.pagePadding,
              SHOAppSpacing.md,
            ),
            child: Text(
              l10n.cartRecommendTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
        feedAsync.when(
          loading: () => SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: SHOAppSpacing.pagePadding,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: SHOAppSpacing.lg,
                crossAxisSpacing: SHOAppSpacing.lg,
                childAspectRatio: SHOProductCard.gridChildAspectRatio,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, __) => const SHOProductCardSkeleton(),
                childCount: 4,
              ),
            ),
          ),
          error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          data: (feed) => SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: SHOAppSpacing.pagePadding,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: SHOAppSpacing.lg,
                crossAxisSpacing: SHOAppSpacing.lg,
                childAspectRatio: SHOProductCard.gridChildAspectRatio,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = feed.products[index];
                return SHOProductCard(
                  product: product,
                  onTap: () => context.push(SHOAppRoutes.product(product.id)),
                );
              }, childCount: feed.products.length.clamp(0, 8)),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: SHOAppSpacing.xxxl)),
      ],
    );
  }
}

class _SHOCartLineTile extends StatefulWidget {
  const _SHOCartLineTile({
    super.key,
    required this.item,
    required this.managing,
    required this.manageSelected,
    required this.favorited,
    required this.swipeOpen,
    required this.onSwipeOpenChanged,
    required this.onManageToggle,
    required this.onOpenProduct,
    required this.onToggle,
    required this.onIncrement,
    required this.onDecrement,
    required this.onChangeSku,
    required this.onFavorite,
    required this.onRemove,
  });

  final SHOCartItem item;
  final bool managing;
  final bool manageSelected;
  final bool favorited;
  final bool swipeOpen;
  final ValueChanged<bool>? onSwipeOpenChanged;
  final VoidCallback? onManageToggle;
  final VoidCallback onOpenProduct;
  final VoidCallback onToggle;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onChangeSku;
  final VoidCallback onFavorite;
  final VoidCallback onRemove;

  @override
  State<_SHOCartLineTile> createState() => _SHOCartLineTileState();
}

class _SHOCartLineTileState extends State<_SHOCartLineTile> {
  static const double _imageSize = 88;
  static const double _actionWidth = 72;
  static const double _revealExtent = _actionWidth * 2;

  double _dragExtent = 0;
  bool _dragging = false;

  SHOCartItem get item => widget.item;

  bool get _swipeEnabled =>
      !widget.managing && widget.onSwipeOpenChanged != null;

  @override
  void didUpdateWidget(covariant _SHOCartLineTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_swipeEnabled) {
      _dragExtent = 0;
      _dragging = false;
      return;
    }
    if (_dragging) return;
    final target = widget.swipeOpen ? -_revealExtent : 0.0;
    if (_dragExtent != target) {
      _dragExtent = target;
    }
  }

  void _animateTo(double target) {
    setState(() {
      _dragging = false;
      _dragExtent = target;
    });
    widget.onSwipeOpenChanged?.call(target < 0);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_swipeEnabled) return;
    final next = (_dragExtent + details.delta.dx).clamp(-_revealExtent, 0.0);
    setState(() {
      _dragging = true;
      _dragExtent = next;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_swipeEnabled) return;
    final velocity = details.primaryVelocity ?? 0;
    final shouldOpen =
        velocity < -200 || (_dragExtent.abs() > _revealExtent * 0.4);
    _animateTo(shouldOpen ? -_revealExtent : 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final atMaxStock = !item.unavailable && item.quantity >= item.stock;
    final unit = item.effectiveUnitCents;

    final content = Opacity(
      opacity: item.unavailable ? 0.5 : 1,
      child: ColoredBox(
        color: context.shoSurface,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SHOAppSpacing.sm,
            SHOAppSpacing.lg,
            SHOAppSpacing.lg,
            SHOAppSpacing.lg,
          ),
          child: Row(
            children: [
              Checkbox(
                value: widget.managing
                    ? widget.manageSelected
                    : (item.selected && !item.unavailable),
                onChanged: item.unavailable
                    ? null
                    : widget.managing
                    ? (_) => widget.onManageToggle?.call()
                    : (_) => widget.onToggle(),
                activeColor: SHOAppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (_dragExtent < 0) {
                      _animateTo(0);
                      return;
                    }
                    widget.onOpenProduct();
                  },
                  borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
                  child: SizedBox(
                    height: _imageSize,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            SHOAppSpacing.cardRadius,
                          ),
                          child: SizedBox(
                            width: _imageSize,
                            height: _imageSize,
                            child: SHOAppNetworkImage(
                              url: item.imageUrl,
                              memCacheWidth: 176,
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
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontSize: 13,
                                      height: 1.25,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              if (item.unavailable)
                                Text(
                                  l10n.cartItemUnavailable,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: SHOAppColors.error,
                                        fontSize: 11,
                                      ),
                                )
                              else if (item.hasActivity)
                                Text(
                                  item.isActivityExpired
                                      ? l10n.cartActivityExpired
                                      : l10n.cartActivityBadge,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: item.isActivityExpired
                                            ? SHOAppColors.warning
                                            : SHOAppColors.sale,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                      ),
                                )
                              else if (item.priceChanged)
                                Text(
                                  l10n.cartItemPriceUpdated,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: SHOAppColors.warning,
                                        fontSize: 11,
                                      ),
                                ),
                              if (item.variantLabel.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: item.unavailable || widget.managing
                                      ? null
                                      : widget.onChangeSku,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: SHOAppColors.surfaceMuted,
                                      borderRadius: BorderRadius.circular(
                                        SHOAppSpacing.cardRadius,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            item.variantLabel,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(fontSize: 11),
                                          ),
                                        ),
                                        if (!item.unavailable &&
                                            !widget.managing) ...[
                                          const SizedBox(width: 2),
                                          Text(
                                            l10n.cartChangeSku,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontSize: 11,
                                                  color: SHOAppColors.accent,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const Icon(
                                            Icons.keyboard_arrow_down,
                                            size: 14,
                                            color: SHOAppColors.accent,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              const Spacer(),
                              if (!widget.managing)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: Row(
                                        children: [
                                          Text(
                                            priceFormatter.formatCents(unit),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  color: SHOAppColors.sale,
                                                ),
                                          ),
                                          if (item.showStrikeListPrice) ...[
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                priceFormatter.formatCents(
                                                  item.listPrice,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: SHOAppColors
                                                          .textMuted,
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      fontSize: 11,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (!item.unavailable) ...[
                                      const SizedBox(width: 8),
                                      _SHOCartQtyStepper(
                                        quantity: item.quantity,
                                        onDecrement: widget.onDecrement,
                                        onIncrement: atMaxStock
                                            ? null
                                            : widget.onIncrement,
                                      ),
                                    ],
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!_swipeEnabled) return content;

    return ClipRect(
      child: Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(
              color: SHOAppColors.error,
              child: Row(
                children: [
                  const Spacer(),
                  _SHOCartSwipeAction(
                    width: _actionWidth,
                    icon: widget.favorited
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    label: l10n.profileFavorites,
                    onTap: widget.onFavorite,
                  ),
                  _SHOCartSwipeAction(
                    width: _actionWidth,
                    icon: Icons.delete_outline_rounded,
                    label: l10n.cartDeleteSelected,
                    onTap: widget.onRemove,
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            child: AnimatedContainer(
              duration: _dragging
                  ? Duration.zero
                  : const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              transform: Matrix4.translationValues(_dragExtent, 0, 0),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}

class _SHOCartSwipeAction extends StatelessWidget {
  const _SHOCartSwipeAction({
    required this.width,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final double width;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SHOCartQtyStepper extends StatelessWidget {
  const _SHOCartQtyStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        border: Border.all(color: context.shoTheme.border),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyBtn(icon: Icons.remove, onTap: onDecrement),
          Container(
            constraints: const BoxConstraints(minWidth: 28),
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          _QtyBtn(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 28,
        height: 28,
        child: Icon(
          icon,
          size: 14,
          color: onTap == null
              ? SHOAppColors.textMuted
              : SHOAppColors.textPrimary,
        ),
      ),
    );
  }
}

class _SHOCartManageFooter extends StatelessWidget {
  const _SHOCartManageFooter({
    required this.selectedCount,
    required this.allSelected,
    required this.onSelectAll,
    required this.onDelete,
  });

  final int selectedCount;
  final bool allSelected;
  final VoidCallback onSelectAll;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final enabled = selectedCount > 0;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
        decoration: BoxDecoration(
          color: context.shoSurface,
          border: Border(top: BorderSide(color: context.shoTheme.border)),
        ),
        child: Row(
          children: [
            Checkbox(
              value: allSelected,
              onChanged: (_) => onSelectAll(),
              activeColor: SHOAppColors.primary,
            ),
            Text(l10n.cartSelectAll),
            const Spacer(),
            SHOAppButton(
              label:
                  '${l10n.cartDeleteSelected}${enabled ? '($selectedCount)' : ''}',
              onPressed: enabled ? onDelete : null,
              variant: SHOAppButtonVariant.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _SHOCartFooter extends ConsumerWidget {
  const _SHOCartFooter({
    required this.cart,
    required this.onSelectAll,
    required this.onPickCoupon,
    required this.onCheckout,
  });

  final SHOCartSnapshot cart;
  final ValueChanged<bool> onSelectAll;
  final VoidCallback onPickCoupon;
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final coupons =
        ref.watch(couponsProvider).valueOrNull ?? const <SHOCoupon>[];
    final selectedCoupon = ref.watch(selectedCouponProvider);
    final addressAsync = ref.watch(selectedAddressProvider);
    final subtotal = cart.selectedTotalCents;
    final shipping = SHOCartPricing.shippingCentsFor(subtotal);
    final freeGap = SHOCartPricing.freeShippingGapCents(subtotal);
    final preview = SHOPriceCalculator.calculateOrderPrice(
      subtotalCents: subtotal,
      coupon: selectedCoupon,
      fullReductionTiers: SHOCartPricing.defaultFullReductionTiers,
      shippingCents: shipping,
      activitySavedCents: cart.selectedActivitySavedCents,
    );
    final bestCoupon = selectedCoupon == null
        ? SHOCartPricing.bestCouponFor(
            subtotalCents: subtotal,
            coupons: coupons,
          )
        : null;
    final bestCouponDiscount = bestCoupon == null
        ? 0
        : SHOPriceCalculator.calculateCouponDiscount(
            subtotalCents: subtotal,
            coupon: bestCoupon,
          );
    final saved =
        (preview.discountCents +
                preview.fullReductionCents +
                preview.activitySavedCents)
            .clamp(0, 1 << 31);
    final nextTier = SHOCartPricing.nextTierAfter(subtotalCents: subtotal);
    final progressGap = nextTier == null
        ? 0
        : (nextTier.minOrderCents - subtotal).clamp(0, 1 << 31);
    final couponLabel =
        selectedCoupon?.title ??
        (bestCoupon != null
            ? '${bestCoupon.title} · ${l10n.cartSavedHint(priceFormatter.formatCents(bestCouponDiscount))}'
            : l10n.couponSelectHint);
    final address = addressAsync.valueOrNull;
    final city = address?.city.trim() ?? '';

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          SHOAppSpacing.pagePadding,
          SHOAppSpacing.sm,
          SHOAppSpacing.pagePadding,
          SHOAppSpacing.pagePadding,
        ),
        decoration: BoxDecoration(
          color: context.shoSurface,
          border: Border(top: BorderSide(color: context.shoTheme.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => context.push(SHOAppRoutes.addressesSelect),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16),
                  const SizedBox(width: SHOAppSpacing.sm),
                  Expanded(
                    child: Text(
                      city.isNotEmpty
                          ? l10n.cartDeliverTo(city)
                          : l10n.cartNoAddressShipping,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    shipping == 0 && subtotal > 0
                        ? l10n.cartShippingFree
                        : '${l10n.cartShippingLabel} ${priceFormatter.formatCents(shipping)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: shipping == 0 && subtotal > 0
                          ? SHOAppColors.sale
                          : SHOAppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 16),
                ],
              ),
            ),
            if (freeGap > 0 && subtotal > 0) ...[
              const SizedBox(height: SHOAppSpacing.xxs),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.cartShippingProgress(
                    priceFormatter.formatCents(freeGap),
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: SHOAppColors.accent),
                ),
              ),
            ],
            InkWell(
              onTap: onPickCoupon,
              borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: SHOAppSpacing.xs),
                child: Row(
                  children: [
                    const Icon(Icons.local_offer_outlined, size: 16),
                    const SizedBox(width: SHOAppSpacing.sm),
                    Text(
                      l10n.cartCouponPreview,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: SHOAppSpacing.sm),
                    Expanded(
                      child: Text(
                        couponLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SHOAppColors.sale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, size: 16),
                  ],
                ),
              ),
            ),
            if (nextTier != null && progressGap > 0) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.cartFullReductionProgress(
                    priceFormatter.formatCents(progressGap),
                    nextTier.label.isNotEmpty
                        ? nextTier.label
                        : l10n.priceFullReduction,
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: SHOAppColors.accent),
                ),
              ),
            ],
            if (saved > 0)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.cartSavedHint(priceFormatter.formatCents(saved)),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SHOAppColors.sale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: SHOAppSpacing.sm),
            Row(
              children: [
                Checkbox(
                  value: cart.allSelected,
                  tristate: true,
                  onChanged: (v) => onSelectAll(v ?? false),
                ),
                Text(
                  l10n.cartSelectAll,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.cartEstimatedTotal,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      priceFormatter.formatCents(
                        subtotal <= 0 ? 0 : preview.totalCents,
                      ),
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
