import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../errors/hos_exception.dart';
import '../errors/hos_error_mapper.dart';
import '../theme/hos_colors.dart';
import '../theme/hos_spacing.dart';
import '../theme/hos_typography.dart';
import 'hos_error_view.dart';
import 'hos_skeleton_box.dart';

/// 页面数据状态枚举：loading / empty / error / success。
enum SHOLoadingState { loading, empty, error, success }

/// 统一加载 / 空态 / 错误 / 成功内容切换组件。
///
/// 参考文章第四步：业务逻辑与 UI 状态解耦，一处修改全局生效。
/// 可配合 ValueNotifier、Riverpod、Bloc 等任意状态管理。
///
/// ```dart
/// // 配合 ValueNotifier
/// ValueListenableBuilder<SHOLoadingState>(
///   valueListenable: _state,
///   builder: (_, state, __) => SHOAppLoadingState(
///     state: state,
///     message: state == SHOLoadingState.error ? 'Network error' : null,
///     onRetry: _fetchData,
///     child: ListView.builder(...),
///   ),
/// )
///
/// // 配合 Riverpod AsyncValue
/// ref.watch(productsProvider).when(
///   loading: () => const SHOAppLoadingState(state: SHOLoadingState.loading),
///   error: (e, _) => SHOAppLoadingState(
///     state: SHOLoadingState.error,
///     message: e.toString(),
///     onRetry: () => ref.invalidate(productsProvider),
///   ),
///   data: (items) => items.isEmpty
///       ? const SHOAppLoadingState(state: SHOLoadingState.empty)
///       : SHOAppLoadingState(state: SHOLoadingState.success, child: ProductGrid(items)),
/// )
/// ```
class SHOAppLoadingState extends StatelessWidget {
  const SHOAppLoadingState({
    super.key,
    required this.state,
    this.message,
    this.onRetry,
    this.child,
    this.loadingWidget,
    this.emptyIcon = Icons.inbox_outlined,
  });

  final SHOLoadingState state;
  final String? message;
  final VoidCallback? onRetry;
  final Widget? child;
  final Widget? loadingWidget;
  final IconData emptyIcon;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (state) {
      SHOLoadingState.loading => loadingWidget ??
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(SHOAppColors.accent),
                  ),
                ),
                const SizedBox(height: SHOAppSpacing.lg),
                Text(
                  message ?? l10n.loading,
                  style: SHOAppTypography.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
      SHOLoadingState.empty => Center(
          child: Padding(
            padding: const EdgeInsets.all(SHOAppSpacing.xxxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(emptyIcon, size: 48, color: SHOAppColors.textMuted),
                const SizedBox(height: SHOAppSpacing.lg),
                Text(
                  message ?? l10n.noData,
                  textAlign: TextAlign.center,
                  style: SHOAppTypography.textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      SHOLoadingState.error => SHOAppErrorView(
          message: message ?? l10n.loadFailed,
          onRetry: onRetry,
        ),
      SHOLoadingState.success => child ?? const SizedBox.shrink(),
    };
  }
}

/// Riverpod [AsyncValue] 快捷扩展，一行切换四态 UI。
///
/// ```dart
/// ref.watch(homeFeedProvider).whenLoadingState(
///   data: (feed) => HomeContent(feed: feed),
///   onRetry: () => ref.invalidate(homeFeedProvider),
///   empty: (feed) => feed.products.isEmpty,
/// )
/// ```
extension SHOAsyncValueLoadingState<T> on AsyncValue<T> {
  Widget whenLoadingState({
    required Widget Function(T data) data,
    VoidCallback? onRetry,
    bool Function(T data)? empty,
    String Function(Object error)? errorMessage,
    Widget? loading,
  }) {
    return when(
      loading: () => SHOAppLoadingState(
        state: SHOLoadingState.loading,
        loadingWidget: loading,
      ),
      error: (error, _) => SHOAppLoadingState(
        state: SHOLoadingState.error,
        message: errorMessage?.call(error) ??
            (error is SHOAppException
                ? userFacingMessage(error)
                : error.toString()),
        onRetry: onRetry,
      ),
      data: (value) {
        if (empty != null && empty(value)) {
          return const SHOAppLoadingState(state: SHOLoadingState.empty);
        }
        return SHOAppLoadingState(
          state: SHOLoadingState.success,
          child: data(value),
        );
      },
    );
  }
}

/// 列表页骨架屏占位，用于 loading 态替代菊花。
///
/// ```dart
/// SHOAppLoadingState(
///   state: SHOLoadingState.loading,
///   loadingWidget: const SHOAppListSkeleton(itemCount: 6),
/// )
/// ```
class SHOAppListSkeleton extends StatelessWidget {
  const SHOAppListSkeleton({
    super.key,
    this.itemCount = 4,
    this.itemHeight = 80,
  });

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: SHOAppSpacing.md),
      itemBuilder: (_, __) => SHOSkeletonBox(height: itemHeight),
    );
  }
}
