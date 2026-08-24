import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoo/features/theme_activity/domain/entities/hos_theme_activity_config.dart';
import 'package:shoo/features/theme_activity/domain/entities/hos_theme_activity_product.dart';

part 'hos_theme_activity_page_state.freezed.dart';

@freezed
class SHOThemeActivityPageState with _$SHOThemeActivityPageState {
  const factory SHOThemeActivityPageState({
    SHOThemeActivityConfig? config,
    SHOThemeActivityProductPage? footerProducts,
    @Default(false) bool isLoading,
    @Default(false) bool isRefreshing,
    @Default(false) bool isLoadingMore,
    String? error,
    @Default(<String>{}) Set<String> claimedCouponIds,
    @Default(<String>{}) Set<String> claimingCouponIds,
  }) = _SHOThemeActivityPageState;

  const SHOThemeActivityPageState._();

  bool get hasFooter => config?.footer != null;
}
