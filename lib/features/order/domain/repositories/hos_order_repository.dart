import 'package:shoo/core/models/hos_page_result.dart';
import 'package:shoo/features/order/domain/entities/hos_order.dart';

/// 订单仓储接口（Domain 层）。
abstract interface class SHOOrderRepository {
  Future<SHOPageResult<SHOOrderSummary>> getOrdersPage({
    int page,
    int pageSize,
    SHOOrderStatus? status,
  });

  Future<SHOOrderDetail> getOrderDetail(String id);

  Future<SHOLogisticsTrack> getLogistics(String orderId);
}
