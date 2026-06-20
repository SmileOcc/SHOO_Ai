class SHOActivityPromoSegment {
  const SHOActivityPromoSegment({
    required this.type,
    this.content,
    this.text,
    this.url,
  });

  final String type;
  final String? content;
  final String? text;
  final String? url;

  factory SHOActivityPromoSegment.fromJson(Map<String, dynamic> json) {
    return SHOActivityPromoSegment(
      type: json['type'] as String? ?? 'text',
      content: json['content'] as String?,
      text: json['text'] as String?,
      url: json['url'] as String?,
    );
  }
}

class SHOActivityPromoBlock {
  const SHOActivityPromoBlock({
    required this.type,
    this.segments = const [],
    this.url,
    this.caption,
    this.width,
    this.height,
  });

  final String type;
  final List<SHOActivityPromoSegment> segments;
  final String? url;
  final String? caption;
  final int? width;
  final int? height;

  factory SHOActivityPromoBlock.fromJson(Map<String, dynamic> json) {
    return SHOActivityPromoBlock(
      type: json['type'] as String? ?? 'paragraph',
      segments: (json['segments'] as List<dynamic>? ?? const [])
          .map(
            (e) => SHOActivityPromoSegment.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
      url: json['url'] as String?,
      caption: json['caption'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
    );
  }
}

class SHOActivityNavigation {
  const SHOActivityNavigation({
    required this.productListLeafId,
    required this.productListTitle,
    required this.sampleProductId,
  });

  final String productListLeafId;
  final String productListTitle;
  final String sampleProductId;

  factory SHOActivityNavigation.fromJson(Map<String, dynamic> json) {
    return SHOActivityNavigation(
      productListLeafId: json['productListLeafId'] as String? ?? '',
      productListTitle: json['productListTitle'] as String? ?? '活动商品',
      sampleProductId: json['sampleProductId'] as String? ?? '',
    );
  }
}
