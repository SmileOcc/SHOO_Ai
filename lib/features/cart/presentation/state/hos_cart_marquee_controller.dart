import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/cart/data/datasources/remote/hos_cart_marquee_remote_ds.dart';
import 'package:shoo/features/cart/domain/entities/hos_cart_marquee.dart';

final cartMarqueeProvider = FutureProvider<List<SHOCartMarqueeItem>>((
  ref,
) async {
  return ref.watch(cartMarqueeApiProvider).fetchMarqueeItems();
});
