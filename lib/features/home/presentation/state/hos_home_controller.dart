import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/home/data/repositories/hos_home_repository_impl.dart';
import 'package:shoo/features/home/domain/entities/hos_banner.dart';
import 'package:shoo/features/home/domain/entities/hos_home_config.dart';
import 'package:shoo/features/home/domain/entities/hos_product.dart';

class SHOHomeFeed {
  const SHOHomeFeed({
    required this.banners,
    required this.products,
    required this.quickEntries,
    required this.feedConfig,
  });

  final List<SHOBannerItem> banners;
  final List<SHOProduct> products;
  final List<SHOHomeQuickEntry> quickEntries;
  final SHOHomeFeedConfig feedConfig;
}

final homeFeedProvider = FutureProvider<SHOHomeFeed>((ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  final feedConfig = await repo.getFeedConfig();
  final results = await Future.wait([
    repo.getBanners(),
    repo.getRecommendedProducts(config: feedConfig),
    repo.getQuickEntries(),
  ]);

  return SHOHomeFeed(
    banners: results[0] as List<SHOBannerItem>,
    products: results[1] as List<SHOProduct>,
    quickEntries: results[2] as List<SHOHomeQuickEntry>,
    feedConfig: feedConfig,
  );
});
