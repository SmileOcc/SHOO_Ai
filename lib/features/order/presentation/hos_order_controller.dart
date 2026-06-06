import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/hos_order_repository.dart';
import '../domain/hos_order.dart';

final ordersProvider = FutureProvider<List<SHOOrderSummary>>((ref) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getOrders();
});

final orderDetailProvider =
    FutureProvider.family<SHOOrderDetail, String>((ref, id) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getOrderDetail(id);
});

final orderLogisticsProvider =
    FutureProvider.family<SHOLogisticsTrack, String>((ref, orderId) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getLogistics(orderId);
});
