/// 运行环境枚举，通过 `--dart-define=ENV=dev|local|staging|prod` 注入。
enum SHOAppEnvironment {
  dev,
  local,
  staging,
  prod;

  static SHOAppEnvironment fromString(String value) {
    final lower = value.toLowerCase();
    if (lower == 'local') return SHOAppEnvironment.local;
    if (lower == 'staging') return SHOAppEnvironment.staging;
    if (lower == 'prod' || lower == 'production') return SHOAppEnvironment.prod;
    return SHOAppEnvironment.dev;
  }

  String get label => switch (this) {
        SHOAppEnvironment.dev => 'dev',
        SHOAppEnvironment.local => 'local',
        SHOAppEnvironment.staging => 'staging',
        SHOAppEnvironment.prod => 'prod',
      };

  /// 角标展示文案（开发 / 本地 / 预发 / 正式）。
  String get badgeLabel => switch (this) {
        SHOAppEnvironment.dev => '开发',
        SHOAppEnvironment.local => '本地',
        SHOAppEnvironment.staging => '预发',
        SHOAppEnvironment.prod => '正式',
      };

  bool get isProd => this == SHOAppEnvironment.prod;

  /// 连接本地 HTTP Mock Server，不走 Dio 内置拦截器。
  bool get usesLocalServer => this == SHOAppEnvironment.local;
}
