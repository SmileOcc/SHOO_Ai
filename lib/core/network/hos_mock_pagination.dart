/// Mock 响应分页切片（query: page / pageSize）。
Map<String, dynamic> paginateMockEnvelope(
  Map<String, dynamic> envelope, {
  required int page,
  required int pageSize,
  String itemsKey = 'items',
}) {
  final data = envelope['data'];
  if (data is! Map<String, dynamic>) return envelope;

  final items = data[itemsKey];
  if (items is! List) return envelope;

  final start = (page - 1) * pageSize;
  final slice = start >= items.length
      ? <dynamic>[]
      : items.sublist(start, (start + pageSize).clamp(0, items.length));

  return {
    ...envelope,
    'data': {
      ...data,
      itemsKey: slice,
      'page': page,
      'pageSize': pageSize,
      'total': items.length,
      'hasMore': start + pageSize < items.length,
    },
  };
}

int mockQueryInt(Map<String, dynamic> query, String key, int fallback) {
  final raw = query[key];
  if (raw == null) return fallback;
  return int.tryParse(raw.toString()) ?? fallback;
}
