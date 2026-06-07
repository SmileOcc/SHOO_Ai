/// 业务上报字段类型。
enum SHOAnalyticsFieldType {
  string,
  intValue,
  doubleValue,
  boolValue,
  map,
  list,
}

/// 单条上报字段定义。
class SHOAnalyticsFieldDef {
  const SHOAnalyticsFieldDef({
    required this.name,
    required this.type,
    this.description = '',
    this.required = false,
    this.example,
  });

  final String name;
  final SHOAnalyticsFieldType type;
  final String description;
  final bool required;
  final Object? example;

  bool validate(Object? value) {
    if (value == null) return !required;
    return switch (type) {
      SHOAnalyticsFieldType.string => value is String,
      SHOAnalyticsFieldType.intValue => value is int,
      SHOAnalyticsFieldType.doubleValue => value is int || value is double,
      SHOAnalyticsFieldType.boolValue => value is bool,
      SHOAnalyticsFieldType.map => value is Map,
      SHOAnalyticsFieldType.list => value is List,
    };
  }
}
