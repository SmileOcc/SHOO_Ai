enum SHOCommunityFeedKind { news, post, ad }

enum SHOCommunitySort { latest, all, hot }

enum SHOCommunityNewsStyle {
  headline,
  imageText,
  tripleImage,
  video,
  topicCard,
}

enum SHOCommunityPostStyle {
  standard,
  multiImage,
  poll,
  productShare,
}

enum SHOCommunityAdStyle {
  banner,
  nativeProduct,
  brandStory,
  carousel,
}

class SHOCommunityMenuItem {
  const SHOCommunityMenuItem({
    required this.id,
    required this.label,
    required this.icon,
    this.tintArgb = 0xFFE25C5C,
  });

  final String id;
  final String label;
  final String icon;
  final int tintArgb;

  factory SHOCommunityMenuItem.fromJson(Map<String, dynamic> json) {
    return SHOCommunityMenuItem(
      id: json['id'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String? ?? '✨',
      tintArgb: json['tintArgb'] as int? ?? 0xFFE25C5C,
    );
  }
}

class SHOCommunityAuthor {
  const SHOCommunityAuthor({
    required this.name,
    this.avatarUrl = '',
    this.level = '',
    this.badge = '',
  });

  final String name;
  final String avatarUrl;
  final String level;
  final String badge;

  factory SHOCommunityAuthor.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SHOCommunityAuthor(name: '');
    return SHOCommunityAuthor(
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      level: json['level'] as String? ?? '',
      badge: json['badge'] as String? ?? '',
    );
  }
}

class SHOCommunityPollOption {
  const SHOCommunityPollOption({
    required this.label,
    required this.percent,
  });

  final String label;
  final int percent;

  factory SHOCommunityPollOption.fromJson(Map<String, dynamic> json) {
    return SHOCommunityPollOption(
      label: json['label'] as String? ?? '',
      percent: json['percent'] as int? ?? 0,
    );
  }
}

class SHOCommunityLinkedProduct {
  const SHOCommunityLinkedProduct({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.priceCents,
    this.originalPriceCents,
  });

  final String productId;
  final String title;
  final String imageUrl;
  final int priceCents;
  final int? originalPriceCents;

  factory SHOCommunityLinkedProduct.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const SHOCommunityLinkedProduct(
        productId: '',
        title: '',
        imageUrl: '',
        priceCents: 0,
      );
    }
    return SHOCommunityLinkedProduct(
      productId: json['productId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      priceCents: json['priceCents'] as int? ?? 0,
      originalPriceCents: json['originalPriceCents'] as int?,
    );
  }
}

class SHOCommunityCarouselCard {
  const SHOCommunityCarouselCard({
    required this.title,
    required this.imageUrl,
    required this.subtitle,
    this.link = '',
  });

  final String title;
  final String imageUrl;
  final String subtitle;
  final String link;

  factory SHOCommunityCarouselCard.fromJson(Map<String, dynamic> json) {
    return SHOCommunityCarouselCard(
      title: json['title'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      link: json['link'] as String? ?? '',
    );
  }
}

class SHOCommunityFeedItem {
  const SHOCommunityFeedItem({
    required this.id,
    required this.kind,
    required this.style,
    required this.title,
    this.summary = '',
    this.coverUrl = '',
    this.imageUrls = const [],
    this.source = '',
    this.publishedAt = '',
    this.readCount = 0,
    this.commentCount = 0,
    this.likeCount = 0,
    this.shareCount = 0,
    this.hotScore = 0,
    this.isPinned = false,
    this.category = '',
    this.tags = const [],
    this.author = const SHOCommunityAuthor(name: ''),
    this.videoDuration = '',
    this.topicDiscussCount = 0,
    this.topicPostCount = 0,
    this.topicAvatars = const [],
    this.pollOptions = const [],
    this.pollParticipants = 0,
    this.pollEndsIn = '',
    this.product,
    this.adLabel = '',
    this.brandName = '',
    this.brandLogoUrl = '',
    this.brandSlogan = '',
    this.carouselCards = const [],
    this.link = '',
    this.articleSlug = '',
  });

  final String id;
  final SHOCommunityFeedKind kind;
  final String style;
  final String title;
  final String summary;
  final String coverUrl;
  final List<String> imageUrls;
  final String source;
  final String publishedAt;
  final int readCount;
  final int commentCount;
  final int likeCount;
  final int shareCount;
  final int hotScore;
  final bool isPinned;
  final String category;
  final List<String> tags;
  final SHOCommunityAuthor author;
  final String videoDuration;
  final int topicDiscussCount;
  final int topicPostCount;
  final List<String> topicAvatars;
  final List<SHOCommunityPollOption> pollOptions;
  final int pollParticipants;
  final String pollEndsIn;
  final SHOCommunityLinkedProduct? product;
  final String adLabel;
  final String brandName;
  final String brandLogoUrl;
  final String brandSlogan;
  final List<SHOCommunityCarouselCard> carouselCards;
  final String link;
  final String articleSlug;

  SHOCommunityNewsStyle? get newsStyle {
    if (kind != SHOCommunityFeedKind.news) return null;
    return SHOCommunityNewsStyle.values.firstWhere(
      (e) => e.name == style,
      orElse: () => SHOCommunityNewsStyle.imageText,
    );
  }

  SHOCommunityPostStyle? get postStyle {
    if (kind != SHOCommunityFeedKind.post) return null;
    return SHOCommunityPostStyle.values.firstWhere(
      (e) => e.name == style,
      orElse: () => SHOCommunityPostStyle.standard,
    );
  }

  SHOCommunityAdStyle? get adStyle {
    if (kind != SHOCommunityFeedKind.ad) return null;
    return SHOCommunityAdStyle.values.firstWhere(
      (e) => e.name == style,
      orElse: () => SHOCommunityAdStyle.banner,
    );
  }

  factory SHOCommunityFeedItem.fromJson(Map<String, dynamic> json) {
    final kindRaw = json['kind'] as String? ?? 'news';
    final kind = SHOCommunityFeedKind.values.firstWhere(
      (e) => e.name == kindRaw,
      orElse: () => SHOCommunityFeedKind.news,
    );

    return SHOCommunityFeedItem(
      id: json['id'] as String,
      kind: kind,
      style: json['style'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      coverUrl: json['coverUrl'] as String? ?? '',
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      source: json['source'] as String? ?? '',
      publishedAt: json['publishedAt'] as String? ?? '',
      readCount: json['readCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      shareCount: json['shareCount'] as int? ?? 0,
      hotScore: json['hotScore'] as int? ?? 0,
      isPinned: json['isPinned'] as bool? ?? false,
      category: json['category'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      author: SHOCommunityAuthor.fromJson(
        json['author'] as Map<String, dynamic>?,
      ),
      videoDuration: json['videoDuration'] as String? ?? '',
      topicDiscussCount: json['topicDiscussCount'] as int? ?? 0,
      topicPostCount: json['topicPostCount'] as int? ?? 0,
      topicAvatars: (json['topicAvatars'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      pollOptions: (json['pollOptions'] as List<dynamic>?)
              ?.map((e) =>
                  SHOCommunityPollOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      pollParticipants: json['pollParticipants'] as int? ?? 0,
      pollEndsIn: json['pollEndsIn'] as String? ?? '',
      product: json['product'] == null
          ? null
          : SHOCommunityLinkedProduct.fromJson(
              json['product'] as Map<String, dynamic>,
            ),
      adLabel: json['adLabel'] as String? ?? '',
      brandName: json['brandName'] as String? ?? '',
      brandLogoUrl: json['brandLogoUrl'] as String? ?? '',
      brandSlogan: json['brandSlogan'] as String? ?? '',
      carouselCards: (json['carouselCards'] as List<dynamic>?)
              ?.map((e) =>
                  SHOCommunityCarouselCard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      link: json['link'] as String? ?? '',
      articleSlug: json['articleSlug'] as String? ?? '',
    );
  }
}

class SHOCommunityFeedPage {
  const SHOCommunityFeedPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.hasMore,
    this.menuItems = const [],
  });

  final List<SHOCommunityFeedItem> items;
  final int page;
  final int pageSize;
  final int total;
  final bool hasMore;
  final List<SHOCommunityMenuItem> menuItems;

  factory SHOCommunityFeedPage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return SHOCommunityFeedPage(
      items: (data['items'] as List<dynamic>?)
              ?.map((e) =>
                  SHOCommunityFeedItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      page: data['page'] as int? ?? 1,
      pageSize: data['pageSize'] as int? ?? 20,
      total: data['total'] as int? ?? 0,
      hasMore: data['hasMore'] as bool? ?? false,
      menuItems: (data['menuItems'] as List<dynamic>?)
              ?.map((e) =>
                  SHOCommunityMenuItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

SHOCommunitySort communitySortFromQuery(String? raw) {
  return switch (raw) {
    'latest' => SHOCommunitySort.latest,
    'hot' => SHOCommunitySort.hot,
    _ => SHOCommunitySort.all,
  };
}

String communitySortToQuery(SHOCommunitySort sort) => sort.name;
