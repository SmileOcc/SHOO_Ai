import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/auth/presentation/state/hos_session_provider.dart';
import 'package:shoo/features/cart/presentation/state/hos_cart_controller.dart';

final cartBadgeCountProvider = Provider<int>((ref) {
  if (!ref.watch(sessionProvider).isAuthenticated) return 0;
  return ref.watch(cartProvider).availableItemCount;
});
