class SHOBookshelfEntry {
  const SHOBookshelfEntry({
    required this.taskId,
    required this.addedAt,
  });

  final String taskId;
  final DateTime addedAt;

  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        'addedAt': addedAt.toIso8601String(),
      };

  factory SHOBookshelfEntry.fromJson(Map<String, dynamic> json) {
    return SHOBookshelfEntry(
      taskId: json['taskId'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }
}
