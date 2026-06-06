abstract final class SHOAppConstants {
  static const String appName = 'SHOO';
  static const String appVersion = '0.2.0';

  /// 本地 Mock API Server（`server/` 目录，`npm run dev`）
  static const String defaultLocalApiBaseUrl = 'http://127.0.0.1:3847/api/v1';

  static const String defaultDevApiBaseUrl = 'https://mock.shoo.local/api/v1';
  static const String defaultStagingApiBaseUrl = 'https://api.staging.shoo.com/v1';
  static const String defaultProdApiBaseUrl = 'https://api.shoo.com/v1';

  static const Duration debounceDuration = Duration(milliseconds: 350);
  static const int defaultPageSize = 20;

  // Storage keys
  static const String themeModeKey = 'theme_mode';
  static const String localeKey = 'locale_code';
  static const String secureTokenKey = 'auth_token';
}
