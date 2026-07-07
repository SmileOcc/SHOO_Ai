import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoo/core/logging/hos_logger.dart';
import 'package:shoo/features/auth/presentation/state/hos_session_provider.dart';
import 'package:shoo/features/flash_sale/data/repositories/hos_flash_sale_repository_impl.dart';
import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_calendar.dart';
import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_coupon.dart';
import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_enums.dart';
import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_follow.dart';
import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_page.dart';
import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_product.dart';
import 'package:shoo/features/flash_sale/domain/hos_flash_sale_activities.dart';
import 'package:shoo/features/flash_sale/presentation/state/hos_flash_sale_follow_controller.dart';

class SHOFlashSalePageState {
  const SHOFlashSalePageState({
    this.calendar,
    this.pageData,
    this.selectedDate = '',
    this.selectedSessionId = '',
    this.sort = SHOFlashSaleSort.hot,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.claimedCouponIds = const {},
    this.error,
  });

  final SHOFlashSaleCalendar? calendar;
  final SHOFlashSalePageData? pageData;
  final String selectedDate;
  final String selectedSessionId;
  final SHOFlashSaleSort sort;
  final bool isRefreshing;
  final bool isLoadingMore;
  final Set<String> claimedCouponIds;
  final String? error;

  SHOFlashSalePageState copyWith({
    SHOFlashSaleCalendar? calendar,
    SHOFlashSalePageData? pageData,
    String? selectedDate,
    String? selectedSessionId,
    SHOFlashSaleSort? sort,
    bool? isRefreshing,
    bool? isLoadingMore,
    Set<String>? claimedCouponIds,
    String? error,
    bool clearError = false,
  }) {
    return SHOFlashSalePageState(
      calendar: calendar ?? this.calendar,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedSessionId: selectedSessionId ?? this.selectedSessionId,
      sort: sort ?? this.sort,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      claimedCouponIds: claimedCouponIds ?? this.claimedCouponIds,
      error: clearError ? null : (error ?? this.error),
      pageData: pageData ?? this.pageData,
    );
  }

  String? sessionStartAtFor(String sessionId) {
    final sessions = pageData?.sessions ?? const [];
    for (final session in sessions) {
      if (session.id == sessionId) return session.startAt;
    }
    return null;
  }
}

final flashSaleControllerProvider =
    StateNotifierProvider.family<
      SHOFlashSaleController,
      SHOFlashSalePageState,
      String
    >((ref, activityId) => SHOFlashSaleController(ref, activityId));

String _flashSaleFollowKey(String sessionId, String productId) =>
    '$sessionId:$productId';

Set<String> flashSaleFollowKeySet(List<SHOFlashSaleFollow> follows) {
  return {
    for (final f in follows) _flashSaleFollowKey(f.sessionId, f.productId),
  };
}

/// 将关注状态合并进商品列表（O(n) + Set 查找）。
List<SHOFlashSaleProduct> mergeFlashSaleProducts(
  List<SHOFlashSaleProduct> products,
  Set<String> followKeys,
) {
  return products.map((p) {
    final followed = followKeys.contains(
      _flashSaleFollowKey(p.sessionId, p.id),
    );
    if (followed == p.isFollowed) return p;
    return p.copyWith(isFollowed: followed);
  }).toList();
}

/// 合并关注后的商品列表（仅在 pageData.products 或 follows 变化时重算）。
final flashSaleMergedProductsProvider =
    Provider.family<List<SHOFlashSaleProduct>, String>((ref, activityId) {
      final products = ref.watch(
        flashSaleControllerProvider(
          activityId,
        ).select((s) => s.pageData?.products),
      );
      if (products == null) return const [];
      final follows = ref.watch(
        flashSaleFollowControllerProvider.select((a) => a.valueOrNull),
      );
      return mergeFlashSaleProducts(
        products,
        flashSaleFollowKeySet(follows ?? const []),
      );
    });

/// 合并已领取状态后的优惠券列表。
final flashSaleMergedCouponsProvider =
    Provider.family<List<SHOFlashSaleCoupon>, String>((ref, activityId) {
      final pageData = ref.watch(
        flashSaleControllerProvider(activityId).select((s) => s.pageData),
      );
      final claimedIds = ref.watch(
        flashSaleControllerProvider(
          activityId,
        ).select((s) => s.claimedCouponIds),
      );
      if (pageData == null) return const [];
      return pageData.coupons.map((c) {
        if (claimedIds.contains(c.id) &&
            c.status != SHOFlashSaleCouponStatus.claimed) {
          return c.copyWith(status: SHOFlashSaleCouponStatus.claimed);
        }
        return c;
      }).toList();
    });

class SHOFlashSaleController extends StateNotifier<SHOFlashSalePageState> {
  SHOFlashSaleController(this._ref, this._activityId)
    : super(const SHOFlashSalePageState());

  final Ref _ref;
  final String _activityId;

  String get activityId =>
      _activityId.isEmpty ? SHOFlashSaleActivities.defaults : _activityId;

  SHOFlashSaleRepository get _repo => _ref.read(flashSaleRepositoryProvider);

  Future<void> initialize() async {
    state = state.copyWith(isRefreshing: true, clearError: true);
    try {
      final calendar = await _repo.getCalendar(activityId: activityId);
      final defaultDay = calendar.days.firstWhere(
        (d) => d.status == SHOFlashSaleDayStatus.ongoing,
        orElse: () => calendar.days.firstWhere(
          (d) => d.status == SHOFlashSaleDayStatus.notStarted,
          orElse: () => calendar.days[1],
        ),
      );
      state = state.copyWith(
        calendar: calendar,
        selectedDate: defaultDay.date,
        isRefreshing: false,
      );
      await _loadPage(reset: true);
    } catch (e) {
      state = state.copyWith(isRefreshing: false, error: e.toString());
    }
  }

  Future<void> selectDate(String date) async {
    if (date == state.selectedDate) return;
    state = state.copyWith(selectedDate: date, selectedSessionId: '');
    await _loadPage(reset: true);
  }

  Future<void> selectSession(String sessionId) async {
    if (sessionId == state.selectedSessionId) return;
    state = state.copyWith(selectedSessionId: sessionId);
    await _loadPage(reset: true);
  }

  Future<void> selectSort(SHOFlashSaleSort sort) async {
    if (sort == state.sort) return;
    state = state.copyWith(sort: sort);
    await _loadPage(reset: true);
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, clearError: true);
    SHOAppLogger.i("refresh");
    await Future<void>.delayed(const Duration(seconds: 5));
    SHOAppLogger.i("refresh = start");
    try {
      final calendar = await _repo.getCalendar(activityId: activityId);
      state = state.copyWith(calendar: calendar, isRefreshing: false);
      await _loadPage(reset: true);
    } catch (e) {
      state = state.copyWith(isRefreshing: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    final data = state.pageData;
    if (data == null || !data.hasMore || state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      SHOAppLogger.i("loadMore");
      await Future<void>.delayed(const Duration(seconds: 5));
      SHOAppLogger.i("loadMore = start");

      final next = await _repo.getPage(
        activityId: activityId,
        date: state.selectedDate,
        sessionId: state.selectedSessionId,
        sort: state.sort,
        page: data.page + 1,
      );
      state = state.copyWith(
        isLoadingMore: false,
        pageData: data.copyWith(
          products: [...data.products, ...next.products],
          page: next.page,
          hasMore: next.hasMore,
          total: next.total,
        ),
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> claimCoupon(String couponId) async {
    await _repo.claimCoupon(couponId);
    state = state.copyWith(
      claimedCouponIds: {...state.claimedCouponIds, couponId},
    );
  }

  Future<bool> toggleFollow(SHOFlashSaleProduct product) async {
    if (!_ref.read(sessionProvider).isAuthenticated) {
      return false;
    }
    final sessionStartAt =
        state.sessionStartAtFor(product.sessionId) ?? product.createdAt ?? '';
    return _ref
        .read(flashSaleFollowControllerProvider.notifier)
        .toggleFollow(product: product, sessionStartAt: sessionStartAt);
  }

  Future<void> _loadPage({required bool reset}) async {
    if (state.selectedDate.isEmpty) return;
    if (!reset) return;

    state = state.copyWith(isRefreshing: true, clearError: true);
    try {
      final page = await _repo.getPage(
        activityId: activityId,
        date: state.selectedDate,
        sessionId: state.selectedSessionId,
        sort: state.sort,
        page: 1,
      );
      state = state.copyWith(
        pageData: page,
        selectedSessionId: page.sessionId,
        isRefreshing: false,
      );
    } catch (e) {
      state = state.copyWith(isRefreshing: false, error: e.toString());
    }
  }
}

final flashSaleProductActivityProvider =
    FutureProvider.family<
      SHOFlashSaleProductActivity,
      ({String productId, String sessionId})
    >((ref, params) async {
      final repo = ref.watch(flashSaleRepositoryProvider);
      return repo.getProductActivity(
        productId: params.productId,
        sessionId: params.sessionId,
      );
    });
