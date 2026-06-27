/// 分页列表页通用快照（[SHOPagedListState]、[SHOReviewsPagedState] 等）。
abstract interface class SHOPagedContainer<T> {
  List<T> get pagedItems;
  bool get pagedHasMore;
  bool get pagedIsLoadingMore;
}
