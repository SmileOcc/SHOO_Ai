import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/home/data/repositories/hos_home_repository_impl.dart';
import 'package:shoo/features/home/domain/entities/hos_banner.dart';
import 'package:shoo/features/home/domain/entities/hos_product.dart';

class SHOHomeFeed {
  const SHOHomeFeed({required this.banners, required this.products});

  final List<SHOBannerItem> banners;
  final List<SHOProduct> products;
}

final homeFeedProvider = FutureProvider<SHOHomeFeed>((ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  final results = await Future.wait([
    repo.getBanners(),
    repo.getRecommendedProducts(),
  ]);

  return SHOHomeFeed(
    banners: results[0] as List<SHOBannerItem>,
    products: results[1] as List<SHOProduct>,
  );
});
