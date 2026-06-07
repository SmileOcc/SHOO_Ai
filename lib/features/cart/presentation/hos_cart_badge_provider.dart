import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/hos_session_provider.dart';
import 'hos_cart_controller.dart';

final cartBadgeCountProvider = Provider<int>((ref) {
  if (!ref.watch(sessionProvider).isAuthenticated) return 0;
  return ref.watch(cartProvider).itemCount;
});
