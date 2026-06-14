/// Mock 订单内存态：新建待支付、支付后更新，避免 GET 详情始终返回已发货假数据。
abstract final class SHOMockOrderStore {
  static final Map<String, Map<String, dynamic>> _orders = {};

  static void putPending(Map<String, dynamic> order) {
    final id = order['id']?.toString();
    if (id == null || id.isEmpty) return;
    _orders[id] = Map<String, dynamic>.from(order);
  }

  static void markPaid(String orderId) {
    final existing = _orders[orderId];
    if (existing != null) {
      _orders[orderId] = {
        ...existing,
        'status': 'paid',
      };
      return;
    }
    _orders[orderId] = {
      'id': orderId,
      'orderNo': orderId,
      'status': 'paid',
      'totalCents': 0,
      'createdAt': '',
      'shippingAddress': '',
      'hasLogistics': false,
      'items': <Map<String, dynamic>>[],
    };
  }

  static Map<String, dynamic>? get(String orderId) {
    final order = _orders[orderId];
    if (order == null) return null;
    return Map<String, dynamic>.from(order);
  }

  static void clear() => _orders.clear();
}
