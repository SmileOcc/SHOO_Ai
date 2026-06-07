import '../../../l10n/app_localizations.dart';
import '../domain/hos_order.dart';

/// 订单列表 Tab，顺序与「我的」订单模块一致。
enum SHOOrderListTab {
  all,
  pendingPayment,
  shipped,
  paid,
  delivered;

  static SHOOrderListTab fromStatusQuery(String? raw) {
    return switch (_parseStatusFilter(raw)) {
      SHOOrderStatus.pendingPayment => SHOOrderListTab.pendingPayment,
      SHOOrderStatus.shipped => SHOOrderListTab.shipped,
      SHOOrderStatus.paid => SHOOrderListTab.paid,
      SHOOrderStatus.delivered => SHOOrderListTab.delivered,
      _ => SHOOrderListTab.all,
    };
  }
}

extension SHOOrderListTabX on SHOOrderListTab {
  SHOOrderStatus? get statusFilter => switch (this) {
        SHOOrderListTab.all => null,
        SHOOrderListTab.pendingPayment => SHOOrderStatus.pendingPayment,
        SHOOrderListTab.shipped => SHOOrderStatus.shipped,
        SHOOrderListTab.paid => SHOOrderStatus.paid,
        SHOOrderListTab.delivered => SHOOrderStatus.delivered,
      };

  String label(AppLocalizations l10n) => switch (this) {
        SHOOrderListTab.all => l10n.ordersAllShort,
        SHOOrderListTab.pendingPayment => l10n.ordersPendingPayment,
        SHOOrderListTab.shipped => l10n.ordersShipped,
        SHOOrderListTab.paid => l10n.ordersToUse,
        SHOOrderListTab.delivered => l10n.ordersReviews,
      };
}

SHOOrderStatus? _parseStatusFilter(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return switch (raw) {
    'pending_payment' => SHOOrderStatus.pendingPayment,
    'paid' => SHOOrderStatus.paid,
    'shipped' => SHOOrderStatus.shipped,
    'delivered' => SHOOrderStatus.delivered,
    _ => null,
  };
}

List<SHOOrderSummary> filterOrdersByTab(
  List<SHOOrderSummary> orders,
  SHOOrderListTab tab,
) {
  final status = tab.statusFilter;
  if (status == null) return orders;
  return orders.where((o) => o.status == status).toList();
}
