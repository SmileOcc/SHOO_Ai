class SHOCartMarqueeItem {
  const SHOCartMarqueeItem({
    required this.id,
    required this.text,
    required this.link,
  });

  final String id;
  final String text;
  final String link;

  factory SHOCartMarqueeItem.fromJson(Map<String, dynamic> json) {
    return SHOCartMarqueeItem(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      link: json['link'] as String? ?? '',
    );
  }
}
