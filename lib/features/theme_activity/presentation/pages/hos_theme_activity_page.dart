import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoo/core/config/hos_config.dart';
import 'package:shoo/core/deeplink/hos_deeplink_config.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/share/hos_share_service.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/widgets/custom_refresh/hos_custom_refresh.dart';
import 'package:shoo/core/widgets/hos_network_image.dart';
import 'package:shoo/core/widgets/hos_price_text.dart';
import 'package:shoo/features/home/domain/entities/hos_product.dart';
import 'package:shoo/features/theme_activity/domain/entities/hos_theme_activity_config.dart';
import 'package:shoo/features/theme_activity/domain/entities/hos_theme_activity_product.dart';
import 'package:shoo/features/theme_activity/presentation/analytics/hos_theme_activity_analytics.dart';
import 'package:shoo/features/theme_activity/presentation/analytics/hos_theme_activity_tracking_scope.dart';
import 'package:shoo/features/theme_activity/presentation/modules/hos_theme_activity_module_builders.dart';
import 'package:shoo/features/theme_activity/presentation/navigation/hos_theme_activity_link_handler.dart';
import 'package:shoo/features/theme_activity/presentation/state/hos_theme_activity_controller.dart';
import 'package:shoo/features/theme_activity/presentation/style/hos_module_style.dart';

class SHOThemeActivityPage extends ConsumerStatefulWidget {
  const SHOThemeActivityPage({
    super.key,
    required this.activityId,
    this.channel,
  });

  final String activityId;
  final String? channel;

  @override
  ConsumerState<SHOThemeActivityPage> createState() =>
      _SHOThemeActivityPageState();
}

class _SHOThemeActivityPageState extends ConsumerState<SHOThemeActivityPage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  final _refreshCtrl = SHOAppCustomRefreshController();
  Stopwatch? _contentReadyStopwatch;
  var _contentReadyReported = false;

  @override
  String get pageName => 'theme_activity';

  @override
  Map<String, Object?> get pageAnalyticsExtra => {
    'activity_id': widget.activityId,
    if (widget.channel != null) 'channel': widget.channel,
  };

  SHOThemeActivityController get _controller => ref.read(
    themeActivityControllerProvider(widget.activityId).notifier,
  );

  String? _effectiveChannel(SHOThemeActivityConfig? config) {
    return widget.channel ?? config?.tracking.channel;
  }

  @override
  void initState() {
    super.initState();
    _contentReadyStopwatch = Stopwatch()..start();
    Future.microtask(() async {
      await _controller.initialize(channel: widget.channel);
      if (!mounted) return;
      _syncLoadFooter();
      _reportContentReadyIfNeeded();
    });
  }

  @override
  void dispose() {
    _refreshCtrl.dispose();
    super.dispose();
  }

  void _reportContentReadyIfNeeded() {
    if (_contentReadyReported || _contentReadyStopwatch == null) return;
    final state = ref.read(themeActivityControllerProvider(widget.activityId));
    if (state.config == null || state.error != null) return;
    _contentReadyReported = true;
    _contentReadyStopwatch!.stop();
    SHOPageLoadReporter.report(
      pageName: pageName,
      durationMs: _contentReadyStopwatch!.elapsedMilliseconds,
      phase: SHOPageLoadPhase.contentReady,
      extra: pageAnalyticsExtra,
    );
  }

  void _syncLoadFooter() {
    final hasMore = ref
        .read(themeActivityControllerProvider(widget.activityId))
        .footerProducts
        ?.hasMore;
    if (hasMore == false) {
      _refreshCtrl.loadNoMore();
    } else if (_refreshCtrl.loadStatus == SHOAppCustomLoadStatus.noMore) {
      _refreshCtrl.loadCompleted();
    }
  }

  Future<void> _onRefresh() async {
    await _controller.refresh(channel: _effectiveChannel(
      ref.read(themeActivityControllerProvider(widget.activityId)).config,
    ));
    if (!mounted) return;
    final error = ref
        .read(themeActivityControllerProvider(widget.activityId))
        .error;
    if (error != null) throw Exception(error);
    _syncLoadFooter();
  }

  Future<void> _onLoadMore() async {
    final channel = _effectiveChannel(
      ref.read(themeActivityControllerProvider(widget.activityId)).config,
    );
    final before = ref
        .read(themeActivityControllerProvider(widget.activityId))
        .footerProducts;
    if (before == null || !before.hasMore) {
      _refreshCtrl.loadNoMore();
      return;
    }
    final beforeLen = before.list.length;
    await _controller.loadMore(channel: channel);
    if (!mounted) return;
    final afterState = ref.read(
      themeActivityControllerProvider(widget.activityId),
    );
    final after = afterState.footerProducts;
    if (after == null) {
      _refreshCtrl.loadFailed();
      return;
    }
    if (afterState.error != null && after.list.length == beforeLen) {
      _refreshCtrl.loadFailed();
    } else if (!after.hasMore) {
      _refreshCtrl.loadNoMore();
    } else {
      _refreshCtrl.loadCompleted();
    }
  }

  Future<void> _retryLoad() async {
    await _controller.initialize(channel: widget.channel);
    if (!mounted) return;
    _syncLoadFooter();
    _reportContentReadyIfNeeded();
  }

  Future<void> _shareActivity(SHOThemeActivityConfig config) async {
    final channel = _effectiveChannel(config);
    final link = SHODeepLinkConfig.themeActivityLink(
      widget.activityId,
      channel: channel,
    ).toString();
    await ref.read(shareServiceProvider).shareViaSystem(
          title: config.title,
          link: link,
        );
    await SHOThemeActivityAnalytics.trackShare(
      activityId: widget.activityId,
      channel: channel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(themeActivityControllerProvider(widget.activityId));
    final config = state.config;

    if (state.isLoading && config == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (config == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('主题活动')),
        body: buildTrackedPage(
          Center(
            child: Padding(
              padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.error ?? '加载失败'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: state.isLoading ? null : _retryLoad,
                    child: const Text('重试'),
                  ),
                  if (SHOAppConfig.instance.isDebugPanelEnabled) ...[
                    const SizedBox(height: 12),
                    Text(
                      SHOAppConfig.instance.useMockApi
                          ? '当前：Mock 配置'
                          : '当前：远程 API (${SHOAppConfig.instance.apiBaseUrl})',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
          onRetry: _retryLoad,
        ),
      );
    }

    if (!config.access.allowed) {
      return Scaffold(
        appBar: AppBar(title: Text(config.title)),
        body: Center(
          child: Text(
            config.access.reason == 'not_started' ? '活动尚未开始' : '活动已结束',
          ),
        ),
      );
    }

    final channel = _effectiveChannel(config);
    final navBar = config.navBar;
    final bgColor = parseThemeColor(
      config.pageBackground.color,
      fallback: Theme.of(context).scaffoldBackgroundColor,
    );
    final titleColor = parseThemeColor(navBar.titleColor);
    final iconColor = parseThemeColor(navBar.iconColor);
    final appBarBg = navBar.style == 'transparent'
        ? Colors.transparent
        : parseThemeColor(
            navBar.backgroundColor,
            fallback: Theme.of(context).colorScheme.surface,
          );

    final footerType = config.footer?.type ?? '';
    final products = state.footerProducts?.list ?? const [];
    final hasMore = state.footerProducts?.hasMore ?? false;
    final footerModuleId = config.footer?.raw['moduleId'] as String? ?? 'footer';

    return SHOThemeActivityTrackingScope(
      activityId: widget.activityId,
      channel: channel,
      trackingPrefix: config.tracking.prefix,
      child: Scaffold(
        extendBodyBehindAppBar: navBar.immersive,
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text(
            config.title,
            style: titleColor != null ? TextStyle(color: titleColor) : null,
          ),
          backgroundColor: appBarBg,
          elevation: navBar.style == 'transparent' ? 0 : null,
          iconTheme: iconColor != null ? IconThemeData(color: iconColor) : null,
          actions: [
            if (navBar.showShare)
              IconButton(
                icon: const Icon(Icons.ios_share_outlined),
                onPressed: () => _shareActivity(config),
              ),
          ],
        ),
        body: buildTrackedPage(
          SHOAppCustomRefresh(
            controller: _refreshCtrl,
            onRefresh: _onRefresh,
            onLoadMore: config.footer == null ? null : _onLoadMore,
            enableLoadMore: config.footer != null && hasMore,
            child: CustomScrollView(
              slivers: [
                for (final module in config.visibleModules)
                  SliverToBoxAdapter(
                    child: buildThemeActivityModule(
                      context,
                      module,
                      config.defaultStyle,
                    ),
                  ),
                if (config.footer != null && products.isNotEmpty)
                  ..._buildFooterSlivers(
                    context,
                    footerType: footerType,
                    footer: config.footer!,
                    products: products,
                    defaultStyle: config.defaultStyle,
                    footerModuleId: footerModuleId,
                  ),
                if (state.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(SHOAppSpacing.lg),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                SHOAppCustomRefresh.footerSliver(_refreshCtrl),
              ],
            ),
          ),
          onRetry: _retryLoad,
        ),
      ),
    );
  }

  List<Widget> _buildFooterSlivers(
    BuildContext context, {
    required String footerType,
    required SHOThemeActivityFooter footer,
    required List<SHOThemeActivityProductCard> products,
    required Map<String, dynamic> defaultStyle,
    required String footerModuleId,
  }) {
    final header = footer.raw['header'];
    final headerTitle = header is Map ? header['title'] as String? : null;
    final style = Map<String, dynamic>.from(
      footer.raw['style'] as Map? ?? {},
    );
    final padding = themeEdgeInsets(footer.raw['padding'], fallback: 12);

    final slivers = <Widget>[];
    if (headerTitle != null && headerTitle.isNotEmpty) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              headerTitle,
              style: moduleTextStyle(
                {...defaultStyle, ...style},
                colorKey: 'titleColor',
                defaultWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    switch (footerType) {
      case 'productListSingle':
        slivers.add(
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: EdgeInsets.fromLTRB(
                  padding.left,
                  0,
                  padding.right,
                  padding.bottom,
                ),
                child: _ThemeActivityProductTile(
                  card: products[index],
                  layout: _FooterLayout.single,
                  moduleId: footerModuleId,
                ),
              ),
              childCount: products.length,
            ),
          ),
        );
      case 'productWaterfall':
        slivers.add(
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: padding.left),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: footer.columns.clamp(2, 3),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.66,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _ThemeActivityProductTile(
                  card: products[index],
                  layout: _FooterLayout.grid,
                  moduleId: footerModuleId,
                ),
                childCount: products.length,
              ),
            ),
          ),
        );
      case 'productListDouble':
      default:
        slivers.add(
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: padding.left),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.66,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _ThemeActivityProductTile(
                  card: products[index],
                  layout: _FooterLayout.grid,
                  moduleId: footerModuleId,
                ),
                childCount: products.length,
              ),
            ),
          ),
        );
    }
    return slivers;
  }
}

enum _FooterLayout { single, grid }

class _ThemeActivityProductTile extends StatelessWidget {
  const _ThemeActivityProductTile({
    required this.card,
    required this.layout,
    required this.moduleId,
  });

  final SHOThemeActivityProductCard card;
  final _FooterLayout layout;
  final String moduleId;

  String get _link {
    if (card.link.isNotEmpty) return card.link;
    if (card.productId.isNotEmpty) {
      return 'https://shoo.app/product/${card.productId}';
    }
    return '';
  }

  SHOProduct get _product => SHOProduct(
    id: card.productId,
    title: card.title,
    imageUrl: card.image,
    price: card.price,
    originalPrice: card.originPrice,
    discountLabel: card.badge,
    rating: 0,
    soldCount: 0,
  );

  @override
  Widget build(BuildContext context) {
    final onTap = _link.isEmpty
        ? null
        : () => SHOThemeActivityLinkHandler.open(
              context,
              _link,
              moduleId: moduleId,
              itemId: card.productId,
            );

    if (layout == _FooterLayout.single) {
      return InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 96,
                height: 96,
                child: SHOAppNetworkImage(url: card.image, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(card.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                  if (card.subtitle.isNotEmpty)
                    Text(
                      card.subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 8),
                  SHOAppPriceText(
                    priceCents: card.price,
                    originalCents: card.originPrice,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: SHOAppNetworkImage(url: card.image, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  SHOAppPriceText(
                    priceCents: _product.price,
                    originalCents: _product.originalPrice,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
