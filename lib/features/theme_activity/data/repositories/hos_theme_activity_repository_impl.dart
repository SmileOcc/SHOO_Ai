import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoo/features/theme_activity/data/datasources/remote/hos_theme_activity_remote_ds.dart';
import 'package:shoo/features/theme_activity/domain/entities/hos_theme_activity_config.dart';
import 'package:shoo/features/theme_activity/domain/entities/hos_theme_activity_product.dart';

final themeActivityRepositoryProvider = Provider<SHOThemeActivityRepository>((
  ref,
) {
  return SHOThemeActivityRepository(ref.watch(themeActivityApiProvider));
});

class SHOThemeActivityRepository {
  SHOThemeActivityRepository(this._api);

  final SHOThemeActivityApi _api;

  Future<SHOThemeActivityConfig> getConfig(
    String activityId, {
    String? channel,
  }) {
    return _api.fetchConfig(activityId, channel: channel);
  }

  Future<SHOThemeActivityProductPage> getProducts({
    required String activityId,
    required int page,
    required int pageSize,
    String? moduleId,
  }) {
    return _api.fetchProducts(
      activityId: activityId,
      page: page,
      pageSize: pageSize,
      moduleId: moduleId,
    );
  }
}
