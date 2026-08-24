import 'package:shoo/features/cart/data/repositories/hos_cart_reconcile_service.dart';

/// Mock 订单内存态：待支付、支付、超时取消、库存锁定。
abstract final class SHOMockOrderStore {
  static const paymentWindow = Duration(minutes: 20);

  static final Map<String, Map<String, dynamic>> _orders = {};
  static final Map<String, int> _consumed = {};
  static final List<_Reservation> _reservations = [];

  static void putPending(Map<String, dynamic> order) {
    final id = order['id']?.toString();
    if (id == null || id.isEmpty) return;
    _orders[id] = Map<String, dynamic>.from(order);
  }

  static Map<String, dynamic>? createFromCheckout({
    required List<Map<String, dynamic>> items,
    int? totalCents,
    String? shippingAddress,
  }) {
    expireStaleOrders();
    for (final item in items) {
      final productId = item['productId']?.toString() ?? '';
      final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
      final variant = item['variantLabel']?.toString().trim() ?? '';
      if (productId.isEmpty || quantity <= 0) continue;
      if (_available(productId, variant) < quantity) {
        return null;
      }
    }

    final id = 'o-${DateTime.now().millisecondsSinceEpoch}';
    final deadline = DateTime.now().add(paymentWindow);
    final subtotal = totalCents ??
        items.fold<int>(0, (sum, item) {
          final price = (item['price'] as num?)?.toInt() ?? 0;
          final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
          return sum + price * quantity;
        });

    final order = {
      'id': id,
      'orderNo': 'SH${DateTime.now().millisecondsSinceEpoch}',
      'status': 'pending_payment',
      'totalCents': subtotal,
      'createdAt': _formatDate(DateTime.now()),
      'paymentDeadlineAt': deadline.toIso8601String(),
      'shippingAddress': shippingAddress ?? '',
      'hasLogistics': false,
      'items': items,
    };

    for (final item in items) {
      final productId = item['productId']?.toString() ?? '';
      final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
      final variant = item['variantLabel']?.toString().trim() ?? '';
      if (productId.isEmpty || quantity <= 0) continue;
      _reservations.add(
        _Reservation(
          orderId: id,
          productId: productId,
          variantLabel: variant,
          quantity: quantity,
          expiresAt: deadline,
        ),
      );
    }

    _orders[id] = order;
    return Map<String, dynamic>.from(order);
  }

  static void markPaid(String orderId) {
    expireStaleOrders();
    final existing = _orders[orderId];
    if (existing != null && existing['status'] == 'pending_payment') {
      for (final reservation in _reservations.where(
        (entry) => entry.orderId == orderId,
      )) {
        final key = _stockKey(reservation.productId, reservation.variantLabel);
        _consumed[key] = (_consumed[key] ?? 0) + reservation.quantity;
      }
      _reservations.removeWhere((entry) => entry.orderId == orderId);
      _orders[orderId] = {...existing, 'status': 'paid'};
      return;
    }
    if (existing != null) {
      _orders[orderId] = {...existing, 'status': 'paid'};
    }
  }

  static Map<String, dynamic>? get(String orderId) {
    expireStaleOrders();
    final order = _orders[orderId];
    if (order == null) return null;
    return Map<String, dynamic>.from(order);
  }

  static List<Map<String, dynamic>> listAll() {
    expireStaleOrders();
    return _orders.values
        .map((order) => Map<String, dynamic>.from(order))
        .toList()
      ..sort((a, b) {
        final left = a['createdAt']?.toString() ?? '';
        final right = b['createdAt']?.toString() ?? '';
        return right.compareTo(left);
      });
  }

  static void expireStaleOrders() {
    final now = DateTime.now();
    final expiredOrderIds = <String>{};
    for (final reservation in _reservations) {
      if (reservation.expiresAt.isAfter(now)) continue;
      expiredOrderIds.add(reservation.orderId);
    }
    for (final order in _orders.values) {
      if (order['status'] != 'pending_payment') continue;
      final deadlineRaw = order['paymentDeadlineAt']?.toString() ?? '';
      final deadline = DateTime.tryParse(deadlineRaw);
      if (deadline != null && deadline.isBefore(now)) {
        expiredOrderIds.add(order['id']?.toString() ?? '');
      }
    }

    for (final orderId in expiredOrderIds) {
      if (orderId.isEmpty) continue;
      _reservations.removeWhere((entry) => entry.orderId == orderId);
      final existing = _orders[orderId];
      if (existing == null || existing['status'] != 'pending_payment') {
        continue;
      }
      _orders[orderId] = {...existing, 'status': 'cancelled'};
    }
  }

  static void clear() {
    _orders.clear();
    _consumed.clear();
    _reservations.clear();
  }

  static String _stockKey(String productId, String variantLabel) {
    final variant = variantLabel.trim();
    if (variant.isEmpty) return productId;
    return '$productId::$variant';
  }

  static int _available(String productId, String variantLabel) {
    final key = _stockKey(productId, variantLabel);
    final base = SHOCartReconcileService.mockStockFor(productId);
    final consumed = _consumed[key] ?? 0;
    final locked = _reservations
        .where(
          (entry) =>
              _stockKey(entry.productId, entry.variantLabel) == key &&
              entry.expiresAt.isAfter(DateTime.now()),
        )
        .fold<int>(0, (sum, entry) => sum + entry.quantity);
    return (base - consumed - locked).clamp(0, 1 << 31);
  }

  static String _formatDate(DateTime value) {
    final pad = (int n) => n.toString().padLeft(2, '0');
    return '${value.year}-${pad(value.month)}-${pad(value.day)} '
        '${pad(value.hour)}:${pad(value.minute)}';
  }
}

class _Reservation {
  _Reservation({
    required this.orderId,
    required this.productId,
    required this.variantLabel,
    required this.quantity,
    required this.expiresAt,
  });

  final String orderId;
  final String productId;
  final String variantLabel;
  final int quantity;
  final DateTime expiresAt;
}
