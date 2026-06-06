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

  bool get isProd => this == SHOAppEnvironment.prod;

  /// 连接本地 HTTP Mock Server，不走 Dio 内置拦截器。
  bool get usesLocalServer => this == SHOAppEnvironment.local;
}
