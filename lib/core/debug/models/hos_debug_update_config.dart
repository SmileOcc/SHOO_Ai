/// Debug 版本更新覆盖配置（仅 Debug 包读取）。
class SHODebugUpdateConfig {
  const SHODebugUpdateConfig({
    this.overrideEnabled = false,
    this.latestVersion = '0.2.0',
    this.releaseNotes = '• New checkout flow\n• Performance improvements\n• Bug fixes',
    this.forceUpdate = false,
    this.updateUrl = 'https://shoo.app/download',
  });

  final bool overrideEnabled;
  final String latestVersion;
  final String releaseNotes;
  final bool forceUpdate;
  final String updateUrl;

  SHODebugUpdateConfig copyWith({
    bool? overrideEnabled,
    String? latestVersion,
    String? releaseNotes,
    bool? forceUpdate,
    String? updateUrl,
  }) {
    return SHODebugUpdateConfig(
      overrideEnabled: overrideEnabled ?? this.overrideEnabled,
      latestVersion: latestVersion ?? this.latestVersion,
      releaseNotes: releaseNotes ?? this.releaseNotes,
      forceUpdate: forceUpdate ?? this.forceUpdate,
      updateUrl: updateUrl ?? this.updateUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'overrideEnabled': overrideEnabled,
        'latestVersion': latestVersion,
        'releaseNotes': releaseNotes,
        'forceUpdate': forceUpdate,
        'updateUrl': updateUrl,
      };

  factory SHODebugUpdateConfig.fromJson(Map<String, dynamic> json) {
    return SHODebugUpdateConfig(
      overrideEnabled: json['overrideEnabled'] as bool? ?? false,
      latestVersion: json['latestVersion'] as String? ?? '0.2.0',
      releaseNotes: json['releaseNotes'] as String? ??
          '• New checkout flow\n• Performance improvements\n• Bug fixes',
      forceUpdate: json['forceUpdate'] as bool? ?? false,
      updateUrl: json['updateUrl'] as String? ?? 'https://shoo.app/download',
    );
  }
}
