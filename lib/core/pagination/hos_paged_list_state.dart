import 'package:shoo/core/pagination/hos_paged_container.dart';

/// 分页列表通用状态。
class SHOPagedListState<T> implements SHOPagedContainer<T> {
  const SHOPagedListState({
    this.items = const [],
    this.page = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.isRefreshing = false,
  });

  final List<T> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;

  bool get isEmpty => items.isEmpty;

  @override
  List<T> get pagedItems => items;

  @override
  bool get pagedHasMore => hasMore;

  @override
  bool get pagedIsLoadingMore => isLoadingMore;

  SHOPagedListState<T> copyWith({
    List<T>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
  }) {
    return SHOPagedListState<T>(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}
