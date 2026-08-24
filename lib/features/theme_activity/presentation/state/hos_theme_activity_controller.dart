import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoo/features/auth/presentation/state/hos_session_provider.dart';
import 'package:shoo/features/coupon/data/repositories/hos_coupon_repository_impl.dart';
import 'package:shoo/features/coupon/domain/use_cases/hos_claim_coupon_use_case.dart';
import 'package:shoo/features/coupon/presentation/state/hos_coupon_controller.dart';
import 'package:shoo/features/theme_activity/data/repositories/hos_theme_activity_repository_impl.dart';
import 'package:shoo/features/theme_activity/domain/entities/hos_theme_activity_product.dart';
import 'package:shoo/features/theme_activity/presentation/analytics/hos_theme_activity_analytics.dart';
import 'package:shoo/features/theme_activity/presentation/state/hos_theme_activity_page_state.dart';

final themeActivityControllerProvider = StateNotifierProvider.family<
    SHOThemeActivityController,
    SHOThemeActivityPageState,
    String>((ref, activityId) {
  return SHOThemeActivityController(ref, activityId);
});

class SHOThemeActivityController extends StateNotifier<SHOThemeActivityPageState> {
  SHOThemeActivityController(this._ref, this.activityId)
      : super(const SHOThemeActivityPageState());

  final Ref _ref;
  final String activityId;

  SHOThemeActivityRepository get _repo =>
      _ref.read(themeActivityRepositoryProvider);

  Future<void> initialize({String? channel}) async {
    if (state.config != null && state.error == null) return;
    state = state.copyWith(isLoading: true, error: null);
    await _loadConfig(resetFooter: true, channel: channel, isRefresh: false);
  }

  Future<void> refresh({String? channel}) async {
    state = state.copyWith(isRefreshing: true, error: null);
    await _loadConfig(resetFooter: true, channel: channel, isRefresh: true);
  }

  Future<void> claimCoupon({
    required String couponId,
    String? channel,
    String? moduleId,
  }) async {
    if (couponId.isEmpty ||
        state.claimingCouponIds.contains(couponId) ||
        state.claimedCouponIds.contains(couponId)) {
      return;
    }

    state = state.copyWith(
      claimingCouponIds: {...state.claimingCouponIds, couponId},
      error: null,
    );

    try {
      await _ref.read(claimCouponUseCaseProvider)(couponId);
      if (!mounted) return;
      state = state.copyWith(
        claimedCouponIds: {...state.claimedCouponIds, couponId},
      );
      _ref.invalidate(couponsProvider);
      await SHOThemeActivityAnalytics.trackCouponClaim(
        activityId: activityId,
        couponId: couponId,
        success: true,
        moduleId: moduleId,
        channel: channel,
      );
    } catch (error) {
      if (mounted) {
        await SHOThemeActivityAnalytics.trackCouponClaim(
          activityId: activityId,
          couponId: couponId,
          success: false,
          moduleId: moduleId,
          channel: channel,
        );
      }
      rethrow;
    } finally {
      if (!mounted) return;
      final nextClaiming = {...state.claimingCouponIds}..remove(couponId);
      state = state.copyWith(claimingCouponIds: nextClaiming);
    }
  }

  Future<void> loadMore({String? channel}) async {
    final footer = state.config?.footer;
    final current = state.footerProducts;
    if (footer == null || current == null || !current.hasMore) return;
    if (state.isLoadingMore) return;

    final nextPage = current.page + 1;
    state = state.copyWith(isLoadingMore: true, error: null);
    try {
      final next = await _repo.getProducts(
        activityId: activityId,
        page: nextPage,
        pageSize: footer.pageSize,
        moduleId: footer.raw['moduleId'] as String?,
      );
      state = state.copyWith(
        isLoadingMore: false,
        footerProducts: current.mergeNext(next),
      );
      await SHOThemeActivityAnalytics.trackFooterLoadMore(
        activityId: activityId,
        page: nextPage,
        success: true,
        channel: channel,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        error: error.toString(),
      );
      await SHOThemeActivityAnalytics.trackFooterLoadMore(
        activityId: activityId,
        page: nextPage,
        success: false,
        channel: channel,
      );
    }
  }

  Future<void> _loadConfig({
    required bool resetFooter,
    String? channel,
    required bool isRefresh,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final config = await _repo.getConfig(activityId, channel: channel);
      SHOThemeActivityProductPage? footerProducts;
      if (config.footer != null && config.access.allowed) {
        footerProducts = await _repo.getProducts(
          activityId: activityId,
          page: 1,
          pageSize: config.footer!.pageSize,
        );
      }
      stopwatch.stop();
      final ownedCouponIds = await _ownedCouponIdsOnPage(config.couponIds);
      state = state.copyWith(
        config: config,
        footerProducts: resetFooter ? footerProducts : state.footerProducts,
        isLoading: false,
        isRefreshing: false,
        error: null,
        claimedCouponIds: {...state.claimedCouponIds, ...ownedCouponIds},
      );
      if (isRefresh) {
        await SHOThemeActivityAnalytics.trackRefresh(
          activityId: activityId,
          success: true,
          durationMs: stopwatch.elapsedMilliseconds,
          channel: channel,
        );
      } else {
        await SHOThemeActivityAnalytics.trackConfigLoad(
          activityId: activityId,
          success: true,
          durationMs: stopwatch.elapsedMilliseconds,
          channel: channel,
        );
      }
    } catch (error) {
      stopwatch.stop();
      final message = error.toString();
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: message,
      );
      if (isRefresh) {
        await SHOThemeActivityAnalytics.trackRefresh(
          activityId: activityId,
          success: false,
          durationMs: stopwatch.elapsedMilliseconds,
          channel: channel,
        );
      } else {
        await SHOThemeActivityAnalytics.trackConfigLoad(
          activityId: activityId,
          success: false,
          durationMs: stopwatch.elapsedMilliseconds,
          channel: channel,
          error: message,
        );
      }
    }
  }

  Future<Set<String>> _ownedCouponIdsOnPage(Set<String> moduleCouponIds) async {
    if (moduleCouponIds.isEmpty) return {};
    if (!_ref.read(sessionProvider).isAuthenticated) return {};
    try {
      final coupons = await _ref.read(couponRepositoryProvider).getCoupons();
      return coupons
          .map((coupon) => coupon.id)
          .where(moduleCouponIds.contains)
          .toSet();
    } catch (_) {
      return {};
    }
  }
}
