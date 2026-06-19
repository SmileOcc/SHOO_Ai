import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/widgets/hos_tab_badge_icon.dart';
import 'package:shoo/features/cart/presentation/state/hos_cart_badge_provider.dart';
import 'package:shoo/features/message/presentation/state/hos_message_controller.dart';

/// 五 Tab 角标状态：[Shop, Category, Community, Bag, Me]
final tabBadgesProvider = Provider<List<SHOTabBadge>>((ref) {
  final cartCount = ref.watch(cartBadgeCountProvider);
  final unreadMessages = ref.watch(unreadMessageCountProvider);

  return [
    const SHOTabBadge(dot: true),
    const SHOTabBadge(),
    const SHOTabBadge(dot: true),
    SHOTabBadge(count: cartCount > 0 ? cartCount : null),
    SHOTabBadge(count: unreadMessages > 0 ? unreadMessages : null),
  ];
});
