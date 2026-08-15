abstract final class SHOAppConstants {
  static const String appName = 'SHOO';
  static const String appVersion = '0.4.0';

  static const String privacyPolicyUrl = 'https://shoo.app/privacy';
  static const String termsOfServiceUrl = 'https://shoo.app/terms';

  /// 本地 Mock API Server（`server/` 目录，`npm run dev`）
  /// 资源 URL 统一为 `{base}/{resource}/{fileName}`，如 `/download/xx.pdf`、`/music/xx.zip`
  static const String defaultLocalApiBaseUrl = 'http://127.0.0.1:8080/api/v1';

  static const int localMockServerPort = 3847;

  /// 活动页内嵌 Fallback Server（Node :3847 未启动时）
  static const int activityMockServerPort = 8888;

  static const String defaultDevApiBaseUrl = 'https://mock.shoo.local/api/v1';
  static const String defaultStagingApiBaseUrl =
      'https://api.staging.shoo.com/v1';
  static const String defaultProdApiBaseUrl = 'https://api.shoo.com/v1';

  static const Duration debounceDuration = Duration(milliseconds: 350);
  static const int defaultPageSize = 20;

  // Storage keys
  static const String themeModeKey = 'theme_mode';
  static const String localeKey = 'locale_code';
  static const String secureTokenKey = 'auth_token';
  static const String secureUserKey = 'auth_user_json';
  static const String secureAesKeyKey = 'aes_session_key';
  static const String secureSignSecretKey = 'request_sign_secret';
  static const String secureRsaPublicKeyKey = 'rsa_public_key_pem';
  static const String secureRsaModulusKey = 'rsa_modulus';
  static const String secureRsaExponentKey = 'rsa_exponent';
  static const String secureSm4KeyKey = 'sm4_session_key';
  static const String cartStorageKey = 'cart_snapshot';
  static const String searchHistoryKey = 'search_history_v1';
  static const int searchHistoryMax = 10;
  static const int listPageSize = 10;
  static const String selectedAddressIdKey = 'selected_address_id';
  static const String addressesStorageKey = 'addresses_v1';
  static const String debugEnvOverrideKey = 'debug_env_override';
  static const String debugShowEnvBadgeKey = 'debug_show_env_badge';
  static const String debugConsoleLogEnabledKey = 'debug_console_log_enabled';

  static const List<String> defaultSkuSizes = ['S', 'M', 'L', 'XL'];
}
