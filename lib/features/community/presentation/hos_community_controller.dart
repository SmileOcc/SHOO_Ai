import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class SHOCommunityFeedListState {
  const SHOCommunityFeedListState({
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.loadingMore = false,
    this.menuItems = const [],
  });

  final List<SHOCommunityFeedItem> items;
  final int page;
  final bool hasMore;
  final bool loadingMore;
  final List<SHOCommunityMenuItem> menuItems;

  SHOCommunityFeedListState copyWith({
    List<SHOCommunityFeedItem>? items,
    int? page,
    bool? hasMore,
    bool? loadingMore,
    List<SHOCommunityMenuItem>? menuItems,
  }) {
    return SHOCommunityFeedListState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      menuItems: menuItems ?? this.menuItems,
    );
  }
}

final communityFeedListProvider =
    NotifierProvider<SHOCommunityFeedListNotifier, SHOCommunityFeedListState>(
  SHOCommunityFeedListNotifier.new,
);

class SHOCommunityFeedListNotifier extends Notifier<SHOCommunityFeedListState> {
  @override
  SHOCommunityFeedListState build() {
    ref.listen(communitySortProvider, (_, __) {
      refresh();
    });
    Future.microtask(refresh);
    return const SHOCommunityFeedListState();
  }

  Future<void> refresh() async {
    final wasEmpty = state.items.isEmpty;
    if (wasEmpty) {
      state = state.copyWith(loadingMore: true);
    }
    try {
      final sort = ref.read(communitySortProvider);
      final page = await ref.read(communityApiProvider).fetchFeed(
            sort: sort,
            page: 1,
          );
      state = SHOCommunityFeedListState(
        items: page.items,
        page: 1,
        hasMore: page.hasMore,
        menuItems: page.menuItems,
      );
    } catch (error, stack) {
      SHOAppLogger.error('Community feed refresh failed', error, stack);
      state = state.copyWith(loadingMore: false);
    }
  }

  Future<void> loadMore() async {
    if (state.loadingMore || !state.hasMore) return;
    state = state.copyWith(loadingMore: true);
    try {
      final sort = ref.read(communitySortProvider);
      final nextPage = state.page + 1;
      final page = await ref.read(communityApiProvider).fetchFeed(
            sort: sort,
            page: nextPage,
          );
      state = state.copyWith(
        items: [...state.items, ...page.items],
        page: nextPage,
        hasMore: page.hasMore,
        loadingMore: false,
        menuItems:
            state.menuItems.isEmpty ? page.menuItems : state.menuItems,
      );
    } catch (error, stack) {
      SHOAppLogger.error('Community feed refresh failed', error, stack);
      state = state.copyWith(loadingMore: false);
    }
  }
}
