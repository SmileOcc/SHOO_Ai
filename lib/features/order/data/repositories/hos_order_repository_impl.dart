import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/models/hos_page_result.dart';
import 'package:shoo/features/order/domain/entities/hos_order.dart';
import 'package:shoo/features/order/data/datasources/remote/hos_order_remote_ds.dart';

final orderRepositoryProvider = Provider<SHOOrderRepository>((ref) {
  return SHOOrderRepository(ref.watch(orderApiProvider));
});

class SHOOrderRepository {
  SHOOrderRepository(this._api);

  final SHOOrderApi _api;

  Future<List<SHOOrderSummary>> getOrders() async {
    final page = await getOrdersPage();
    return page.items;
  }

  Future<SHOPageResult<SHOOrderSummary>> getOrdersPage({
    int page = 1,
    int pageSize = 10,
  }) {
    return _api.fetchOrders(page: page, pageSize: pageSize);
  }

  Future<SHOOrderDetail> getOrderDetail(String id) => _api.fetchOrderDetail(id);

  Future<SHOLogisticsTrack> getLogistics(String orderId) =>
      _api.fetchLogistics(orderId);
}
