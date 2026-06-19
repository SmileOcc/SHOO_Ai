class SHOVideoComment {
  const SHOVideoComment({
    required this.id,
    required this.videoId,
    required this.content,
    required this.createdAt,
    required this.authorName,
  });

  final String id;
  final String videoId;
  final String content;
  final DateTime createdAt;
  final String authorName;

  Map<String, dynamic> toJson() => {
        'id': id,
        'videoId': videoId,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'authorName': authorName,
      };

  factory SHOVideoComment.fromJson(Map<String, dynamic> json) {
    return SHOVideoComment(
      id: json['id'] as String,
      videoId: json['videoId'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      authorName: json['authorName'] as String? ?? '',
    );
  }
}
