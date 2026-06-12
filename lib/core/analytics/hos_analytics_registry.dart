import 'hos_analytics_event.dart';
import 'hos_analytics_field.dart';

/// 业务上报事件注册表（新增事件在此登记 key 与字段）。
abstract final class SHOAnalyticsRegistry {
  static const loginSuccess = SHOAnalyticsEventDef(
    key: 'login_success',
    title: 'Login success',
    description: 'User completed login',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'user_id',
        type: SHOAnalyticsFieldType.string,
        required: true,
        description: 'User id',
        example: 'u_10001',
      ),
      SHOAnalyticsFieldDef(
        name: 'method',
        type: SHOAnalyticsFieldType.string,
        description: 'Login method',
        example: 'phone_password',
      ),
    ],
  );

  static const logout = SHOAnalyticsEventDef(
    key: 'logout',
    title: 'Logout',
    description: 'User logged out',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'user_id',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'u_10001',
      ),
    ],
  );

  static const productView = SHOAnalyticsEventDef(
    key: 'product_view',
    title: 'Product view',
    description: 'User opened product detail',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'product_id',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'p_001',
      ),
      SHOAnalyticsFieldDef(
        name: 'source',
        type: SHOAnalyticsFieldType.string,
        description: 'Entry source',
        example: 'home_feed',
      ),
    ],
  );

  static const addToCart = SHOAnalyticsEventDef(
    key: 'add_to_cart',
    title: 'Add to cart',
    description: 'User added SKU to cart',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'product_id',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'p_001',
      ),
      SHOAnalyticsFieldDef(
        name: 'sku_id',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'sku_red_m',
      ),
      SHOAnalyticsFieldDef(
        name: 'quantity',
        type: SHOAnalyticsFieldType.intValue,
        required: true,
        example: 1,
      ),
    ],
  );

  static const checkoutStart = SHOAnalyticsEventDef(
    key: 'checkout_start',
    title: 'Checkout start',
    description: 'User entered checkout',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'item_count',
        type: SHOAnalyticsFieldType.intValue,
        required: true,
        example: 2,
      ),
      SHOAnalyticsFieldDef(
        name: 'amount',
        type: SHOAnalyticsFieldType.doubleValue,
        required: true,
        example: 199.0,
      ),
    ],
  );

  static const paymentSuccess = SHOAnalyticsEventDef(
    key: 'payment_success',
    title: 'Payment success',
    description: 'Order payment completed',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'order_id',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'o_90001',
      ),
      SHOAnalyticsFieldDef(
        name: 'amount',
        type: SHOAnalyticsFieldType.doubleValue,
        required: true,
        example: 199.0,
      ),
    ],
  );

  static const search = SHOAnalyticsEventDef(
    key: 'search',
    title: 'Search',
    description: 'User submitted search',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'keyword',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'hoodie',
      ),
      SHOAnalyticsFieldDef(
        name: 'result_count',
        type: SHOAnalyticsFieldType.intValue,
        example: 12,
      ),
    ],
  );

  static const appLaunch = SHOAnalyticsEventDef(
    key: 'app_launch',
    title: 'App launch',
    description: 'App cold start completed',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'cold_start',
        type: SHOAnalyticsFieldType.boolValue,
        example: true,
      ),
      SHOAnalyticsFieldDef(
        name: 'build_mode',
        type: SHOAnalyticsFieldType.string,
        example: 'debug',
      ),
    ],
  );

  static const appClose = SHOAnalyticsEventDef(
    key: 'app_close',
    title: 'App close',
    description: 'App moved to background or terminated',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'reason',
        type: SHOAnalyticsFieldType.string,
        required: true,
        description: 'paused / detached / hidden',
        example: 'paused',
      ),
    ],
  );

  static const appStartupTime = SHOAnalyticsEventDef(
    key: 'app_startup_time',
    title: 'App startup time',
    description: 'Cold start timing metrics',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'bootstrap_ms',
        type: SHOAnalyticsFieldType.intValue,
        required: true,
        example: 120,
      ),
      SHOAnalyticsFieldDef(
        name: 'first_frame_ms',
        type: SHOAnalyticsFieldType.intValue,
        required: true,
        example: 450,
      ),
      SHOAnalyticsFieldDef(
        name: 'bootstrap_to_first_frame_ms',
        type: SHOAnalyticsFieldType.intValue,
        example: 330,
      ),
    ],
  );

  static const shareProduct = SHOAnalyticsEventDef(
    key: 'share_product',
    title: 'Share product',
    description: 'User shared a product',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'product_id',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'p_001',
      ),
      SHOAnalyticsFieldDef(
        name: 'channel',
        type: SHOAnalyticsFieldType.string,
        example: 'system_share',
      ),
    ],
  );

  static const downloadItemClick = SHOAnalyticsEventDef(
    key: 'download_item_click',
    title: 'Download item click',
    description: 'User tapped a download list item',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'payload',
        type: SHOAnalyticsFieldType.string,
        required: true,
        description:
            'JSON: download_url, download_time, file_type, file_id, resource_name',
        example:
            '{"download_url":"https://example.com/a.zip","download_time":"2026-06-06T12:00:00.000Z","file_type":"zip","file_id":"task_1","resource_name":"music.zip"}',
      ),
    ],
  );

  static const musicPackExtract = SHOAnalyticsEventDef(
    key: 'music_pack_extract',
    title: 'Music pack extract',
    description: 'Music resources extracted from a download zip',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'payload',
        type: SHOAnalyticsFieldType.string,
        required: true,
        description:
            'JSON: resource_name, file_type, file_id, download_url, extract_paths',
        example:
            '{"resource_name":"music.zip","file_type":"zip","file_id":"task_1","download_url":"https://example.com/a.zip","extract_paths":["/path/audio.mp3"]}',
      ),
    ],
  );

  static const musicPackAlreadyExtracted = SHOAnalyticsEventDef(
    key: 'music_pack_already_extracted',
    title: 'Music pack already extracted',
    description: 'User opened a music pack that was already cached locally',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'payload',
        type: SHOAnalyticsFieldType.string,
        required: true,
        description:
            'JSON: resource_name, file_type, file_id, download_url, extract_paths',
        example:
            '{"resource_name":"music.zip","file_type":"zip","file_id":"task_1","download_url":"https://example.com/a.zip","extract_paths":["/path/audio.mp3"]}',
      ),
    ],
  );

  static final List<SHOAnalyticsEventDef> all = [
    appLaunch,
    appClose,
    appStartupTime,
    loginSuccess,
    logout,
    productView,
    addToCart,
    checkoutStart,
    paymentSuccess,
    search,
    shareProduct,
    downloadItemClick,
    musicPackExtract,
    musicPackAlreadyExtracted,
  ];

  static SHOAnalyticsEventDef? find(String key) {
    for (final event in all) {
      if (event.key == key) return event;
    }
    return null;
  }
}
