import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/order/presentation/state/hos_order_controller.dart';
import 'package:shoo/features/order/presentation/state/hos_orders_paged_controller.dart';
import 'package:shoo/features/profile/presentation/state/hos_profile_controller.dart';

/// 订单相关缓存统一刷新（列表、分页、个人中心角标、详情）。
void invalidateOrderCaches(WidgetRef ref, {String? orderId}) {
  ref.invalidate(ordersPagedProvider);
  ref.invalidate(profileOrderCountsProvider);
  if (orderId != null) {
    ref.invalidate(orderDetailProvider(orderId));
  }
}
