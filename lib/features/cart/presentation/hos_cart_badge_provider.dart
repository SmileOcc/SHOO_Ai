import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'hos_cart_controller.dart';

final cartBadgeCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).itemCount;
});
