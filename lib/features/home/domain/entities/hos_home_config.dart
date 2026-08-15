class SHOHomeQuickEntry {
  const SHOHomeQuickEntry({
    required this.id,
    required this.title,
    required this.icon,
    required this.link,
    this.sort = 0,
    this.enabled = true,
  });

  final String id;
  final String title;
  final String icon;
  final String link;
  final int sort;
  final bool enabled;

  factory SHOHomeQuickEntry.fromJson(Map<String, dynamic> json) {
    return SHOHomeQuickEntry(
      id: json['id']?.toString() ?? '',
      title: (json['title'] ?? json['name'])?.toString() ?? '',
      icon: json['icon']?.toString() ?? '🏷️',
      link: json['link']?.toString() ?? '/',
      sort: json['sort'] is int
          ? json['sort'] as int
          : int.tryParse('${json['sort']}') ?? 0,
      enabled: json['enabled'] != false,
    );
  }
}

class SHOHomeFeedConfig {
  const SHOHomeFeedConfig({
    this.title = '',
    this.mode = 'latest',
    this.categoryId = '',
    this.productIds = const [],
    this.pageSize = 50,
  });

  final String title;
  final String mode;
  final String categoryId;
  final List<String> productIds;
  final int pageSize;

  factory SHOHomeFeedConfig.fromJson(Map<String, dynamic> json) {
    final rawIds = json['productIds'];
    return SHOHomeFeedConfig(
      title: json['title']?.toString() ?? '',
      mode: json['mode']?.toString() ?? 'latest',
      categoryId: json['categoryId']?.toString() ?? '',
      productIds: rawIds is List
          ? rawIds.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
          : const [],
      pageSize: json['pageSize'] is int
          ? json['pageSize'] as int
          : int.tryParse('${json['pageSize']}') ?? 50,
    );
  }

  static const fallback = SHOHomeFeedConfig();
}
