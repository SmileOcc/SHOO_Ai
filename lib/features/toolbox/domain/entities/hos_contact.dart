/// 通用联系人实体（百宝箱联系人列表）。
class SHOContact {
  const SHOContact({
    required this.id,
    required this.name,
    required this.pinyin,
    required this.letter,
    required this.phone,
    this.company = '',
    this.avatarUrl = '',
  });

  final String id;
  final String name;
  final String pinyin;
  final String letter;
  final String phone;
  final String company;
  final String avatarUrl;

  factory SHOContact.fromJson(Map<String, dynamic> json) {
    return SHOContact(
      id: json['id'] as String,
      name: json['name'] as String,
      pinyin: json['pinyin'] as String? ?? '',
      letter: (json['letter'] as String? ?? '#').toUpperCase(),
      phone: json['phone'] as String? ?? '',
      company: json['company'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
    );
  }

  String get displayInitial => name.isNotEmpty ? name.substring(0, 1) : '?';
}
