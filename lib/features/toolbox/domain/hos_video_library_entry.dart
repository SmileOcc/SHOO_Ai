enum SHOVideoLibrarySource {
  local,
  network,
}

class SHOVideoLibraryEntry {
  const SHOVideoLibraryEntry({
    required this.id,
    required this.source,
    required this.displayName,
    required this.addedAt,
    this.taskId,
    this.url,
    this.linkedDownloadTaskId,
  });

  final String id;
  final SHOVideoLibrarySource source;
  final String displayName;
  final DateTime addedAt;
  final String? taskId;
  final String? url;
  final String? linkedDownloadTaskId;

  bool get isNetwork => source == SHOVideoLibrarySource.network;
  bool get isLocal => source == SHOVideoLibrarySource.local;

  static const localIdPrefix = 'vl_local_';

  static String localEntryId(String taskId) => '$localIdPrefix$taskId';

  static String? taskIdFromEntryId(String entryId) {
    if (!entryId.startsWith(localIdPrefix)) return null;
    final taskId = entryId.substring(localIdPrefix.length);
    return taskId.isEmpty ? null : taskId;
  }

  SHOVideoLibraryEntry copyWith({
    String? displayName,
    String? linkedDownloadTaskId,
  }) {
    return SHOVideoLibraryEntry(
      id: id,
      source: source,
      displayName: displayName ?? this.displayName,
      addedAt: addedAt,
      taskId: taskId,
      url: url,
      linkedDownloadTaskId: linkedDownloadTaskId ?? this.linkedDownloadTaskId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'source': source.name,
        'displayName': displayName,
        'addedAt': addedAt.toIso8601String(),
        'taskId': taskId,
        'url': url,
        'linkedDownloadTaskId': linkedDownloadTaskId,
      };

  factory SHOVideoLibraryEntry.fromJson(Map<String, dynamic> json) {
    return SHOVideoLibraryEntry(
      id: json['id'] as String,
      source: SHOVideoLibrarySource.values.byName(json['source'] as String),
      displayName: json['displayName'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
      taskId: json['taskId'] as String?,
      url: json['url'] as String?,
      linkedDownloadTaskId: json['linkedDownloadTaskId'] as String?,
    );
  }

  factory SHOVideoLibraryEntry.local({
    required String taskId,
    required String displayName,
  }) {
    return SHOVideoLibraryEntry(
      id: localEntryId(taskId),
      source: SHOVideoLibrarySource.local,
      taskId: taskId,
      displayName: displayName,
      addedAt: DateTime.now(),
    );
  }

  factory SHOVideoLibraryEntry.network({
    required String url,
    required String displayName,
  }) {
    return SHOVideoLibraryEntry(
      id: 'vl_net_${DateTime.now().millisecondsSinceEpoch}',
      source: SHOVideoLibrarySource.network,
      url: url,
      displayName: displayName,
      addedAt: DateTime.now(),
    );
  }
}
