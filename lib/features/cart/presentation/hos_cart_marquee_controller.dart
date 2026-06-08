import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/hos_cart_marquee_api.dart';
import '../domain/hos_cart_marquee.dart';

final cartMarqueeProvider = FutureProvider<List<SHOCartMarqueeItem>>((ref) async {
  return ref.watch(cartMarqueeApiProvider).fetchMarqueeItems();
});
