import 'package:flutter/material.dart';

import '../theme/hos_colors.dart';
import '../theme/hos_spacing.dart';
import '../../l10n/app_localizations.dart';

/// 下拉刷新 + 触底加载更多 列表容器。
class SHOPagedScrollView extends StatelessWidget {
  const SHOPagedScrollView({
    super.key,
    required this.controller,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorBuilder,
    this.padding,
    this.onRefresh,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.loadMoreFooter,
  });

  final ScrollController controller;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final EdgeInsetsGeometry? padding;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;
  final Widget? loadMoreFooter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (onLoadMore == null || !hasMore || isLoadingMore) return false;
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 120) {
          onLoadMore!();
        }
        return false;
      },
      child: RefreshIndicator(
        color: SHOAppColors.accent,
        onRefresh: onRefresh ?? () async {},
        child: ListView.separated(
          controller: controller,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: padding ?? const EdgeInsets.all(SHOAppSpacing.pagePadding),
          itemCount: itemCount + 1,
          separatorBuilder: separatorBuilder ?? (_, __) => const SizedBox.shrink(),
          itemBuilder: (context, index) {
            if (index < itemCount) {
              return itemBuilder(context, index);
            }
            if (loadMoreFooter != null) return loadMoreFooter!;
            if (isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.all(SHOAppSpacing.xl),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }
            if (!hasMore && itemCount > 0) {
              return Padding(
                padding: const EdgeInsets.all(SHOAppSpacing.xl),
                child: Center(
                  child: Text(
                    l10n.pagedListNoMore,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              );
            }
            return const SizedBox(height: SHOAppSpacing.xxxl);
          },
        ),
      ),
    );
  }
}

/// 网格版分页滚动（搜索页）。
class SHOPagedGridView extends StatelessWidget {
  const SHOPagedGridView({
    super.key,
    required this.controller,
    required this.itemCount,
    required this.itemBuilder,
    required this.gridDelegate,
    this.padding,
    this.onRefresh,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = false,
  });

  final ScrollController controller;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final SliverGridDelegate gridDelegate;
  final EdgeInsetsGeometry? padding;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (onLoadMore == null || !hasMore || isLoadingMore) return false;
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 160) {
          onLoadMore!();
        }
        return false;
      },
      child: RefreshIndicator(
        color: SHOAppColors.accent,
        onRefresh: onRefresh ?? () async {},
        child: CustomScrollView(
          controller: controller,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: padding ?? const EdgeInsets.all(SHOAppSpacing.pagePadding),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  itemBuilder,
                  childCount: itemCount,
                ),
                gridDelegate: gridDelegate,
              ),
            ),
            SliverToBoxAdapter(
              child: isLoadingMore
                  ? const Padding(
                      padding: EdgeInsets.all(SHOAppSpacing.xl),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : (!hasMore && itemCount > 0)
                      ? Padding(
                          padding: const EdgeInsets.all(SHOAppSpacing.xl),
                          child: Center(
                            child: Text(
                              l10n.pagedListNoMore,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        )
                      : const SizedBox(height: SHOAppSpacing.xxxl),
            ),
          ],
        ),
      ),
    );
  }
}
