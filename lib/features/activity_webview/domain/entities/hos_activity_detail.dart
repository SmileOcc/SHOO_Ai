import 'package:shoo/features/activity_webview/domain/entities/hos_activity_promo.dart';

class SHOActivityDetailSection {
  const SHOActivityDetailSection({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  factory SHOActivityDetailSection.fromJson(Map<String, dynamic> json) {
    return SHOActivityDetailSection(
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
    );
  }
}

class SHOActivityDetail {
  const SHOActivityDetail({
    required this.id,
    required this.title,
    required this.summary,
    required this.sections,
    required this.promoBlocks,
    this.bannerUrl,
  });

  final String id;
  final String title;
  final String summary;
  final String? bannerUrl;
  final List<SHOActivityDetailSection> sections;
  final List<SHOActivityPromoBlock> promoBlocks;

  factory SHOActivityDetail.fromJson(Map<String, dynamic> json) {
    return SHOActivityDetail(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      bannerUrl: json['bannerUrl'] as String?,
      sections: (json['sections'] as List<dynamic>? ?? const [])
          .map(
            (e) => SHOActivityDetailSection.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
      promoBlocks: (json['promoBlocks'] as List<dynamic>? ?? const [])
          .map(
            (e) => SHOActivityPromoBlock.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
    );
  }
}

class SHOActivityLevel3Item {
  const SHOActivityLevel3Item({
    required this.title,
    required this.content,
    this.time,
  });

  final String title;
  final String content;
  final String? time;

  factory SHOActivityLevel3Item.fromJson(Map<String, dynamic> json) {
    return SHOActivityLevel3Item(
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      time: json['time'] as String?,
    );
  }
}

class SHOActivityLevel3Detail {
  const SHOActivityLevel3Detail({
    required this.id,
    required this.title,
    required this.summary,
    required this.items,
  });

  final String id;
  final String title;
  final String summary;
  final List<SHOActivityLevel3Item> items;

  factory SHOActivityLevel3Detail.fromJson(Map<String, dynamic> json) {
    return SHOActivityLevel3Detail(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      items: (json['items'] as List<dynamic>? ?? const [])
          .map(
            (e) => SHOActivityLevel3Item.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
    );
  }
}
