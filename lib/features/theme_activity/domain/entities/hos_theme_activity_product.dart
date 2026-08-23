class SHOThemeActivityProductCard {
  const SHOThemeActivityProductCard({
    required this.productId,
    required this.image,
    required this.title,
    this.subtitle = '',
    required this.price,
    this.originPrice = 0,
    this.currency = 'USD',
    this.link = '',
    this.salesText = '',
    this.badge = '',
  });

  final String productId;
  final String image;
  final String title;
  final String subtitle;
  final int price;
  final int originPrice;
  final String currency;
  final String link;
  final String salesText;
  final String badge;

  factory SHOThemeActivityProductCard.fromJson(Map<String, dynamic> json) {
    final productId =
        json['productId'] as String? ?? json['id'] as String? ?? '';
    return SHOThemeActivityProductCard(
      productId: productId,
      image:
          json['image'] as String? ?? json['imageUrl'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      originPrice:
          (json['originPrice'] as num?)?.toInt() ??
          (json['originalPrice'] as num?)?.toInt() ??
          0,
      currency: json['currency'] as String? ?? 'USD',
      link: json['link'] as String? ?? '',
      salesText: json['salesText'] as String? ?? '',
      badge: json['badge'] as String? ?? '',
    );
  }
}

class SHOThemeActivityProductPage {
  const SHOThemeActivityProductPage({
    required this.list,
    required this.page,
    required this.pageSize,
    required this.hasMore,
    this.total,
  });

  final List<SHOThemeActivityProductCard> list;
  final int page;
  final int pageSize;
  final bool hasMore;
  final int? total;

  factory SHOThemeActivityProductPage.fromJson(Map<String, dynamic> json) {
    final listRaw = json['list'] ?? json['items'];
    final list = listRaw is List
        ? listRaw
            .whereType<Map<String, dynamic>>()
            .map(SHOThemeActivityProductCard.fromJson)
            .toList()
        : <SHOThemeActivityProductCard>[];
    return SHOThemeActivityProductPage(
      list: list,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? list.length,
      hasMore: json['hasMore'] as bool? ?? false,
      total: json['total'] as int?,
    );
  }

  SHOThemeActivityProductPage mergeNext(SHOThemeActivityProductPage next) {
    return SHOThemeActivityProductPage(
      list: [...list, ...next.list],
      page: next.page,
      pageSize: next.pageSize,
      hasMore: next.hasMore,
      total: next.total ?? total,
    );
  }
}
