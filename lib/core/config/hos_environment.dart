/// 运行环境枚举，通过 `--dart-define=ENV=dev|staging|prod` 注入。
enum SHOAppEnvironment {
  dev,
  staging,
  prod;

  static SHOAppEnvironment fromString(String value) {
    final lower = value.toLowerCase();
    if (lower == 'staging') return SHOAppEnvironment.staging;
    if (lower == 'prod' || lower == 'production') return SHOAppEnvironment.prod;
    return SHOAppEnvironment.dev;
  }

  String get label => switch (this) {
        SHOAppEnvironment.dev => 'dev',
        SHOAppEnvironment.staging => 'staging',
        SHOAppEnvironment.prod => 'prod',
      };

  bool get isProd => this == SHOAppEnvironment.prod;
}
