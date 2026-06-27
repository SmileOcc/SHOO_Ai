import 'package:shoo/core/network/hos_mock_pagination.dart';

/// 抢购活动 Mock 动态数据：按当前时间生成 7 天日历、场次状态、商品排序分页。
Map<String, dynamic> resolveFlashSaleCalendar(
  Map<String, dynamic> catalogEnvelope, {
  Map<String, dynamic> query = const {},
}) {
  final now = DateTime.now();
  final data = catalogEnvelope['data'] as Map<String, dynamic>? ?? {};
  final templates = (data['sessionTemplates'] as List<dynamic>?) ?? [];
  final activityId = query['activityId']?.toString() ?? '';
  final activity = _resolveActivity(data, activityId);

  final days = <Map<String, dynamic>>[];
  for (var offset = -1; offset < 6; offset++) {
    final day = DateTime(now.year, now.month, now.day).add(Duration(days: offset));
    final dateStr = _formatDate(day);
    final sessions = _buildSessionsForDay(day, templates, now);
    final status = _aggregateDayStatus(sessions);

    days.add({
      'date': dateStr,
      'label': '${day.month}/${day.day}',
      'weekday': _weekdayLabel(day.weekday),
      'status': status,
      'sessionCount': sessions.length,
    });
  }

  return {
    'code': catalogEnvelope['code'] ?? 0,
    'message': catalogEnvelope['message'] ?? 'ok',
    'data': {
      'serverTime': now.toUtc().toIso8601String(),
      'days': days,
      if (activity != null) ...{
        'activityId': activity['id'],
        'activityTitle': activity['title'],
      },
    },
  };
}

Map<String, dynamic> resolveFlashSalePage(
  Map<String, dynamic> catalogEnvelope, {
  required Map<String, dynamic> query,
}) {
  final now = DateTime.now();
  final data = catalogEnvelope['data'] as Map<String, dynamic>? ?? {};
  final templates = (data['sessionTemplates'] as List<dynamic>?) ?? [];
  final allProducts = (data['products'] as List<dynamic>?) ?? [];
  final promoEntries = data['promoEntries'] ?? [];
  final couponsBySuffix = data['couponsBySessionSuffix'] as Map<String, dynamic>? ?? {};
  final activityId = query['activityId']?.toString() ?? '';
  final activity = _resolveActivity(data, activityId);
  final filteredProducts = _filterProductsForActivity(allProducts, activity);

  final dateStr = query['date']?.toString() ?? _formatDate(now);
  final day = _parseDate(dateStr) ?? DateTime(now.year, now.month, now.day);
  final sessions = _buildSessionsForDay(day, templates, now);

  var sessionId = query['sessionId']?.toString();
  if (sessionId == null || sessionId.isEmpty) {
    sessionId = _pickDefaultSessionId(sessions, now);
  }

  final session = sessions.cast<Map<String, dynamic>?>().firstWhere(
        (s) => s!['id'] == sessionId,
        orElse: () => sessions.isNotEmpty ? sessions.first as Map<String, dynamic> : null,
      );
  sessionId = session?['id'] as String? ?? sessionId;

  final suffix = sessionId.split('-').last;
  final rawCoupons = (couponsBySuffix[suffix] as List<dynamic>?) ?? [];
  final claimPhase = _resolveClaimPhase(session, now);
  final claimTarget = _claimCountdownTarget(session, claimPhase, now);

  var products = filteredProducts
      .map((p) => _hydrateProduct(p, sessionId!, session, now))
      .toList();

  final sort = query['sort']?.toString() ?? 'hot';
  products = _sortProducts(products, sort);

  final page = mockQueryInt(query, 'page', 1);
  final pageSize = mockQueryInt(query, 'pageSize', 4);
  final start = (page - 1) * pageSize;
  final slice = start >= products.length
      ? <Map<String, dynamic>>[]
      : products.sublist(start, (start + pageSize).clamp(0, products.length));

  return {
    'code': catalogEnvelope['code'] ?? 0,
    'message': catalogEnvelope['message'] ?? 'ok',
    'data': {
      'serverTime': now.toUtc().toIso8601String(),
      'date': dateStr,
      'sessionId': sessionId,
      if (activity != null) ...{
        'activityId': activity['id'],
        'activityTitle': activity['title'],
      },
      'claimPhase': claimPhase,
      if (claimTarget != null) 'claimCountdownTarget': claimTarget,
      'sessions': sessions,
      'promoEntries': promoEntries,
      'coupons': rawCoupons
          .whereType<Map<String, dynamic>>()
          .map((c) => _hydrateCoupon(c, session, claimPhase))
          .toList(),
      'products': slice,
      'page': page,
      'pageSize': pageSize,
      'total': products.length,
      'hasMore': start + pageSize < products.length,
    },
  };
}

Map<String, dynamic> resolveFlashSaleProductActivity(
  Map<String, dynamic> catalogEnvelope, {
  required String productId,
  required String sessionId,
}) {
  final now = DateTime.now();
  final data = catalogEnvelope['data'] as Map<String, dynamic>? ?? {};
  final activities = data['productActivities'] as Map<String, dynamic>? ?? {};
  final products = (data['products'] as List<dynamic>?) ?? [];
  final templates = (data['sessionTemplates'] as List<dynamic>?) ?? [];

  final product = products.whereType<Map<String, dynamic>>().firstWhere(
        (p) => p['id'] == productId,
        orElse: () => <String, dynamic>{},
      );
  final activityBase = activities[productId] as Map<String, dynamic>? ?? product;

  if (product.isEmpty && activityBase.isEmpty) {
    return {'code': 404, 'message': 'Activity not found', 'data': null};
  }

  final datePart = sessionId.contains('-') ? sessionId.split('-')[1] : _formatDate(now);
  final day = _parseDate(datePart) ?? DateTime(now.year, now.month, now.day);
  final sessions = _buildSessionsForDay(day, templates, now);
  final session = sessions.cast<Map<String, dynamic>?>().firstWhere(
        (s) => s!['id'] == sessionId,
        orElse: () => sessions.isNotEmpty ? sessions.first as Map<String, dynamic> : null,
      );

  final status = _resolveProductStatus(
    session: session,
    stock: activityBase['stock'] as int? ?? product['stock'] as int? ?? 0,
    now: now,
  );

  final overlay = _overlayLabel(status, session);

  return {
    'code': 0,
    'message': 'ok',
    'data': {
      'sessionId': sessionId,
      'status': status,
      'originalPrice': activityBase['originalPrice'] ?? product['originalPrice'] ?? 0,
      'activityPrice': activityBase['activityPrice'] ?? product['activityPrice'] ?? 0,
      'primaryPromoType': activityBase['primaryPromoType'] ?? product['primaryPromoType'],
      'primaryPromoLabel': activityBase['primaryPromoLabel'] ?? product['primaryPromoLabel'],
      'promoTags': activityBase['promoTags'] ?? product['promoTags'] ?? [],
      'sessionStartAt': session?['startAt'],
      'sessionEndAt': session?['endAt'],
      'overlayLabel': overlay,
      'isFollowed': false,
      'stock': activityBase['stock'] ?? product['stock'] ?? 0,
    },
  };
}

List<Map<String, dynamic>> _buildSessionsForDay(
  DateTime day,
  List<dynamic> templates,
  DateTime now,
) {
  final dateStr = _formatDate(day);
  final raw = templates.whereType<Map<String, dynamic>>().map((t) {
    final suffix = t['idSuffix'] as String? ?? '00';
    final start = DateTime(
      day.year,
      day.month,
      day.day,
      t['startHour'] as int? ?? 10,
      t['startMinute'] as int? ?? 0,
    );
    final duration = t['durationMinutes'] as int? ?? 120;
    final end = start.add(Duration(minutes: duration));
    final claimLead = t['claimLeadMinutes'] as int? ?? 30;
    final claimTrail = t['claimTrailMinutes'] as int? ?? 10;
    final claimStart = start.subtract(Duration(minutes: claimLead));
    final claimEnd = start.add(Duration(minutes: claimTrail));

    final status = _sessionStatus(start, end, now);

    return {
      'id': 'fs-$dateStr-$suffix',
      'label': t['label'] ?? '$suffix:00场',
      'startAt': start.toUtc().toIso8601String(),
      'endAt': end.toUtc().toIso8601String(),
      'claimStartAt': claimStart.toUtc().toIso8601String(),
      'claimEndAt': claimEnd.toUtc().toIso8601String(),
      'status': status,
    };
  }).toList();

  return raw;
}

String _aggregateDayStatus(List<Map<String, dynamic>> sessions) {
  if (sessions.isEmpty) return 'not_started';
  final statuses = sessions.map((s) => s['status'] as String).toSet();
  if (statuses.contains('ongoing')) return 'ongoing';
  if (statuses.every((s) => s == 'ended')) return 'ended';
  return 'not_started';
}

String _sessionStatus(DateTime start, DateTime end, DateTime now) {
  if (now.isBefore(start)) return 'not_started';
  if (now.isBefore(end)) return 'ongoing';
  return 'ended';
}

String _pickDefaultSessionId(List<Map<String, dynamic>> sessions, DateTime now) {
  for (final s in sessions) {
    if (s['status'] == 'ongoing') return s['id'] as String;
  }
  for (final s in sessions) {
    if (s['status'] == 'not_started') return s['id'] as String;
  }
  return sessions.isNotEmpty ? sessions.last['id'] as String : '';
}

String _resolveClaimPhase(Map<String, dynamic>? session, DateTime now) {
  if (session == null) return 'after_claim';
  final claimStart = DateTime.parse(session['claimStartAt'] as String).toLocal();
  final claimEnd = DateTime.parse(session['claimEndAt'] as String).toLocal();
  if (now.isBefore(claimStart)) return 'before_claim';
  if (now.isBefore(claimEnd)) return 'claiming';
  return 'after_claim';
}

String? _claimCountdownTarget(
  Map<String, dynamic>? session,
  String phase,
  DateTime now,
) {
  if (session == null) return null;
  if (phase == 'before_claim') return session['claimStartAt'] as String?;
  if (phase == 'claiming') return session['claimEndAt'] as String?;
  return null;
}

Map<String, dynamic> _hydrateCoupon(
  Map<String, dynamic> coupon,
  Map<String, dynamic>? session,
  String claimPhase,
) {
  var status = coupon['status'] as String? ?? 'not_started';
  // 当天任意时间均可领券（已领取 / 已抢光的除外）
  final today = _formatDate(DateTime.now());
  if (claimPhase == 'after_claim') {
    // 检查是否为当天；当天即使 claimPhase=after_claim 仍可领
    final startAt = session?['startAt'] as String?;
    if (startAt != null && startAt.length >= 10) {
      final sessionDate = startAt.substring(0, 10);
      if (sessionDate == today && status != 'claimed' && status != 'sold_out') {
        status = 'claimable';
      } else {
        status = 'expired';
      }
    } else {
      status = 'expired';
    }
  } else if (claimPhase == 'claiming' && status == 'not_started') {
    status = 'claimable';
  } else if (claimPhase == 'before_claim') {
    final startAt = session?['startAt'] as String?;
    if (startAt != null && startAt.length >= 10) {
      final sessionDate = startAt.substring(0, 10);
      if (sessionDate == today && status != 'claimed' && status != 'sold_out') {
        status = 'claimable';
      } else {
        status = 'not_started';
      }
    } else {
      status = 'not_started';
    }
  }
  return {...coupon, 'status': status};
}

Map<String, dynamic> _hydrateProduct(
  Map<String, dynamic> product,
  String sessionId,
  Map<String, dynamic>? session,
  DateTime now,
) {
  final stock = product['stock'] as int? ?? 0;
  final status = _resolveProductStatus(session: session, stock: stock, now: now);
  return {
    ...product,
    'sessionId': sessionId,
    'status': status,
    'isFollowed': false,
  };
}

String _resolveProductStatus({
  required Map<String, dynamic>? session,
  required int stock,
  required DateTime now,
}) {
  if (session == null) return 'ended';
  final start = DateTime.parse(session['startAt'] as String).toLocal();
  final end = DateTime.parse(session['endAt'] as String).toLocal();
  if (now.isBefore(start)) return 'not_started';
  if (now.isBefore(end)) return stock > 0 ? 'ongoing' : 'sold_out';
  return stock > 0 ? 'ended' : 'sold_out';
}

String? _overlayLabel(String status, Map<String, dynamic>? session) {
  final label = session?['label'] as String? ?? '';
  switch (status) {
    case 'not_started':
      return '活动未开始 · $label';
    case 'ongoing':
      return '抢购进行中';
    case 'sold_out':
      return '已抢完';
    case 'ended':
      return '活动已结束';
    default:
      return null;
  }
}

List<Map<String, dynamic>> _sortProducts(
  List<Map<String, dynamic>> products,
  String sort,
) {
  final list = products.map((e) => Map<String, dynamic>.from(e)).toList();
  list.sort((a, b) {
    switch (sort) {
      case 'price_asc':
        return _sortPrice(a).compareTo(_sortPrice(b));
      case 'price_desc':
        return _sortPrice(b).compareTo(_sortPrice(a));
      case 'newest':
        final at = a['createdAt']?.toString() ?? '';
        final bt = b['createdAt']?.toString() ?? '';
        return bt.compareTo(at);
      case 'hot':
      default:
        return (b['soldCount'] as int? ?? 0).compareTo(a['soldCount'] as int? ?? 0);
    }
  });
  return list;
}

int _sortPrice(Map<String, dynamic> p) {
  final status = p['status'] as String? ?? 'not_started';
  if (status == 'ongoing') return p['activityPrice'] as int? ?? 0;
  return p['originalPrice'] as int? ?? 0;
}

String _formatDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime? _parseDate(String raw) {
  final parts = raw.split('-');
  if (parts.length != 3) return null;
  final y = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (y == null || m == null || d == null) return null;
  return DateTime(y, m, d);
}

String _weekdayLabel(int weekday) {
  const labels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  return labels[(weekday - 1).clamp(0, 6)];
}

/// 抢购商品转普通商品详情（`/products/{id}` fallback）。
Map<String, dynamic> lookupFlashSaleProductDetail(
  Map<String, dynamic> catalogEnvelope,
  String productId, {
  String? sessionId,
}) {
  final data = catalogEnvelope['data'];
  if (data is! Map<String, dynamic>) {
    return _flashSaleProductNotFound(productId);
  }

  final products = data['products'] as List<dynamic>?;
  if (products == null) return _flashSaleProductNotFound(productId);

  Map<String, dynamic>? product;
  for (final raw in products) {
    if (raw is Map<String, dynamic> && raw['id'] == productId) {
      product = raw;
      break;
    }
  }
  if (product == null) return _flashSaleProductNotFound(productId);

  var price = product['originalPrice'] as int? ?? 0;
  var discountLabel = product['primaryPromoLabel'] as String? ?? '';

  if (sessionId != null && sessionId.isNotEmpty) {
    final activity = resolveFlashSaleProductActivity(
      catalogEnvelope,
      productId: productId,
      sessionId: sessionId,
    );
    final activityData = activity['data'];
    if (activityData is Map<String, dynamic>) {
      final status = activityData['status'] as String? ?? 'not_started';
      if (status == 'ongoing') {
        price = activityData['activityPrice'] as int? ?? price;
      } else {
        price = activityData['originalPrice'] as int? ?? price;
      }
      discountLabel = activityData['primaryPromoLabel'] as String? ?? discountLabel;
    }
  }

  final imageUrl = product['imageUrl'] as String? ?? '';
  return {
    'code': catalogEnvelope['code'] ?? 0,
    'message': catalogEnvelope['message'] ?? 'ok',
    'data': {
      'id': productId,
      'title': product['title'],
      'imageUrl': imageUrl,
      'images': [imageUrl],
      'price': price,
      'originalPrice': product['originalPrice'] ?? price,
      'discountLabel': discountLabel,
      'rating': 4.6,
      'soldCount': product['soldCount'] ?? 0,
      'description':
          '${product['title']} — 限时抢购专享商品，支持折扣/满减活动价（以场次状态为准）。',
      'reviewCount': 0,
    },
  };
}

Map<String, dynamic> emptyFlashSaleProductReviews() {
  return {
    'code': 0,
    'message': 'ok',
    'data': {
      'averageRating': 0,
      'totalCount': 0,
      'items': <Map<String, dynamic>>[],
    },
  };
}

Map<String, dynamic>? _resolveActivity(
  Map<String, dynamic> data,
  String activityId,
) {
  if (activityId.isEmpty) return null;
  final activities = (data['activities'] as List<dynamic>?) ?? [];
  for (final raw in activities) {
    if (raw is Map<String, dynamic> && raw['id'] == activityId) {
      return raw;
    }
  }
  return null;
}

List<Map<String, dynamic>> _filterProductsForActivity(
  List<dynamic> allProducts,
  Map<String, dynamic>? activity,
) {
  final typed = allProducts.whereType<Map<String, dynamic>>().toList();
  if (activity == null) return typed;

  final kinds = (activity['kinds'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
      const [];
  if (kinds.isEmpty) return typed;

  return typed.where((product) {
    final productKinds = (product['activityKinds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];
    return productKinds.any(kinds.contains);
  }).toList();
}

Map<String, dynamic> _flashSaleProductNotFound(String productId) {
  return {
    'code': 404,
    'message': 'Product not found: $productId',
    'data': null,
  };
}

/// 校验抢购商品结算价与活动状态。
Map<String, dynamic>? validateFlashSaleCheckoutItems(
  Map<String, dynamic> catalogEnvelope,
  List<dynamic> items,
) {
  for (final raw in items) {
    if (raw is! Map<String, dynamic>) continue;
    final productId = raw['productId']?.toString() ?? '';
    final sessionId = raw['sessionId']?.toString() ?? '';
    final clientPrice = raw['unitPriceCents'] as int?;
    if (sessionId.isEmpty || !productId.startsWith('fs-')) continue;

    final activity = resolveFlashSaleProductActivity(
      catalogEnvelope,
      productId: productId,
      sessionId: sessionId,
    );
    if ((activity['code'] as int?) == 404) {
      return {
        'code': 400,
        'message': 'Flash sale activity not found',
        'data': null,
      };
    }
    final data = activity['data'] as Map<String, dynamic>?;
    final status = data?['status'] as String? ?? 'ended';
    if (status != 'ongoing') {
      return {
        'code': 400,
        'message': 'Flash sale is not active for $productId',
        'data': null,
      };
    }
    final expected = data?['activityPrice'] as int? ?? 0;
    if (clientPrice != null && clientPrice != expected) {
      return {
        'code': 400,
        'message': 'Flash sale price mismatch for $productId',
        'data': null,
      };
    }
  }
  return null;
}
