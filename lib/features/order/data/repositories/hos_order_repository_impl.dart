import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/models/hos_page_result.dart';
import 'package:shoo/features/order/data/datasources/remote/hos_order_remote_ds.dart';
import 'package:shoo/features/order/domain/entities/hos_order.dart';
import 'package:shoo/features/order/domain/repositories/hos_order_repository.dart';

final orderRepositoryProvider = Provider<SHOOrderRepository>((ref) {
  return SHOOrderRepositoryImpl(ref.watch(orderApiProvider));
});

class SHOOrderRepositoryImpl implements SHOOrderRepository {
  SHOOrderRepositoryImpl(this._api);

  final SHOOrderApi _api;

  @override
  Future<SHOPageResult<SHOOrderSummary>> getOrdersPage({
    int page = 1,
    int pageSize = 10,
    SHOOrderStatus? status,
  }) {
    return _api.fetchOrders(page: page, pageSize: pageSize, status: status);
  }

  @override
  Future<SHOOrderDetail> getOrderDetail(String id) => _api.fetchOrderDetail(id);

  @override
  Future<SHOLogisticsTrack> getLogistics(String orderId) =>
      _api.fetchLogistics(orderId);
}
