import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/hos_order.dart';
import 'hos_order_api.dart';

final orderRepositoryProvider = Provider<SHOOrderRepository>((ref) {
  return SHOOrderRepository(ref.watch(orderApiProvider));
});

class SHOOrderRepository {
  SHOOrderRepository(this._api);

  final SHOOrderApi _api;

  Future<List<SHOOrderSummary>> getOrders() async {
    final page = await _api.fetchOrders();
    return page.items;
  }

  Future<SHOOrderDetail> getOrderDetail(String id) => _api.fetchOrderDetail(id);

  Future<SHOLogisticsTrack> getLogistics(String orderId) =>
      _api.fetchLogistics(orderId);
}
