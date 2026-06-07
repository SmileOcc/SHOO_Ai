import 'hos_analytics_field.dart';

/// 业务上报事件定义：上报 key、字段、说明。
class SHOAnalyticsEventDef {
  const SHOAnalyticsEventDef({
    required this.key,
    required this.title,
    required this.fields,
    this.description = '',
    this.sampleParams,
  });

  final String key;
  final String title;
  final String description;
  final List<SHOAnalyticsFieldDef> fields;
  final Map<String, Object?>? sampleParams;

  Map<String, Object?> sampleOrDefault() {
    if (sampleParams != null && sampleParams!.isNotEmpty) {
      return Map<String, Object?>.from(sampleParams!);
    }
    final result = <String, Object?>{};
    for (final field in fields) {
      if (field.example != null) {
        result[field.name] = field.example;
      }
    }
    return result;
  }

  String? validateParams(Map<String, Object?> params) {
    for (final field in fields) {
      if (field.required && !params.containsKey(field.name)) {
        return 'Missing required field: ${field.name}';
      }
      final value = params[field.name];
      if (value != null && !field.validate(value)) {
        return 'Invalid type for field: ${field.name}';
      }
    }
    return null;
  }
}

/// 一次实际上报记录（用于 Debug 预览）。
class SHOAnalyticsRecord {
  const SHOAnalyticsRecord({
    required this.eventKey,
    required this.params,
    required this.timestamp,
    required this.backendIds,
    this.error,
  });

  final String eventKey;
  final Map<String, Object?> params;
  final DateTime timestamp;
  final List<String> backendIds;
  final String? error;

  SHOAnalyticsRecord copyWith({
    List<String>? backendIds,
    String? error,
  }) {
    return SHOAnalyticsRecord(
      eventKey: eventKey,
      params: params,
      timestamp: timestamp,
      backendIds: backendIds ?? this.backendIds,
      error: error ?? this.error,
    );
  }
}
