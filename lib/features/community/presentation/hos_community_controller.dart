import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/hos_constants.dart';
import '../../../core/logging/hos_logger.dart';
import '../data/hos_community_api.dart';
import '../domain/hos_community_models.dart';

final communitySortProvider =
    StateProvider<SHOCommunitySort>((ref) => SHOCommunitySort.all);

final communityMenuProvider = FutureProvider<List<SHOCommunityMenuItem>>((ref) async {
  final page = await ref.watch(communityFeedProvider(1).future);
  return page.menuItems;
});

final communityFeedProvider =
    FutureProvider.family<SHOCommunityFeedPage, int>((ref, page) async {
  final sort = ref.watch(communitySortProvider);
  return ref.read(communityApiProvider).fetchFeed(sort: sort, page: page);
});

/// 筛选切换后递增，页面监听并滚回顶部。
final communityFeedScrollToTopProvider = StateProvider<int>((ref) => 0);

class SHOCommunityFeedListState {
  const SHOCommunityFeedListState({
    this.items = const [],
    this.page = 0,
    this.hasMore = true,
    this.isInitialLoading = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.menuItems = const [],
    this.error,
    this.loadMoreError,
  });

  final List<SHOCommunityFeedItem> items;
  final int page;
  final bool hasMore;
  final bool isInitialLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final List<SHOCommunityMenuItem> menuItems;
  final Object? error;
  final Object? loadMoreError;

  bool get isEmpty => items.isEmpty;

  SHOCommunityFeedListState copyWith({
    List<SHOCommunityFeedItem>? items,
    int? page,
    bool? hasMore,
    bool? isInitialLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    List<SHOCommunityMenuItem>? menuItems,
    Object? error,
    Object? loadMoreError,
    bool clearError = false,
    bool clearLoadMoreError = false,
  }) {
    return SHOCommunityFeedListState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      menuItems: menuItems ?? this.menuItems,
      error: clearError ? null : (error ?? this.error),
      loadMoreError:
          clearLoadMoreError ? null : (loadMoreError ?? this.loadMoreError),
    );
  }
}

final communityFeedListProvider =
    NotifierProvider<SHOCommunityFeedListNotifier, SHOCommunityFeedListState>(
  SHOCommunityFeedListNotifier.new,
);

class SHOCommunityFeedListNotifier extends Notifier<SHOCommunityFeedListState> {
  int _requestGen = 0;

  @override
  SHOCommunityFeedListState build() {
    ref.listen(communitySortProvider, (previous, next) {
      if (previous != next) {
        ref.read(communityFeedScrollToTopProvider.notifier).state++;
        unawaited(refresh());
      }
    });
    Future.microtask(refresh);
    return const SHOCommunityFeedListState(isInitialLoading: true);
  }

  Future<void> refresh() async {
    if (state.isRefreshing) return;

    final gen = ++_requestGen;
    final showInitial = state.items.isEmpty;

    state = state.copyWith(
      isInitialLoading: showInitial,
      isRefreshing: !showInitial,
      clearError: true,
      clearLoadMoreError: true,
    );

    try {
      final sort = ref.read(communitySortProvider);
      final page = await ref.read(communityApiProvider).fetchFeed(
            sort: sort,
            page: 1,
            pageSize: SHOAppConstants.defaultPageSize,
          );

      if (gen != _requestGen) return;

      state = SHOCommunityFeedListState(
        items: page.items,
        page: 1,
        hasMore: page.hasMore,
        menuItems: page.menuItems,
      );
    } catch (error, stack) {
      if (gen != _requestGen) return;
      SHOAppLogger.error('Community feed refresh failed', error, stack);
      state = state.copyWith(
        isInitialLoading: false,
        isRefreshing: false,
        error: error,
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore ||
        !state.hasMore ||
        state.isRefreshing ||
        state.isInitialLoading ||
        state.items.isEmpty) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, clearLoadMoreError: true);

    try {
      final sort = ref.read(communitySortProvider);
      final nextPage = state.page + 1;
      final page = await ref.read(communityApiProvider).fetchFeed(
            sort: sort,
            page: nextPage,
            pageSize: SHOAppConstants.defaultPageSize,
          );

      state = state.copyWith(
        items: [...state.items, ...page.items],
        page: nextPage,
        hasMore: page.hasMore,
        isLoadingMore: false,
        menuItems:
            state.menuItems.isEmpty ? page.menuItems : state.menuItems,
      );
    } catch (error, stack) {
      SHOAppLogger.error('Community feed load more failed', error, stack);
      state = state.copyWith(
        isLoadingMore: false,
        loadMoreError: error,
      );
    }
  }
}
