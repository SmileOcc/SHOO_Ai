import 'package:shoo/core/analytics/hos_analytics_event.dart';
import 'package:shoo/core/analytics/hos_analytics_field.dart';

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

  static const pageEnter = SHOAnalyticsEventDef(
    key: 'page_enter',
    title: 'Page enter',
    description: 'Page became visible (RouteAware.didPush)',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'page_name',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'SHOMusicPlayerPage',
      ),
      SHOAnalyticsFieldDef(
        name: 'route_path',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: '/toolbox/music',
      ),
      SHOAnalyticsFieldDef(
        name: 'route_uri',
        type: SHOAnalyticsFieldType.string,
        example: '/toolbox/music?trackId=t1',
      ),
      SHOAnalyticsFieldDef(
        name: 'previous_route_path',
        type: SHOAnalyticsFieldType.string,
        example: '/toolbox/downloads',
      ),
    ],
  );

  static const pageExit = SHOAnalyticsEventDef(
    key: 'page_exit',
    title: 'Page exit',
    description: 'Page removed from stack (RouteAware.didPop)',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'page_name',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'SHOMusicPlayerPage',
      ),
      SHOAnalyticsFieldDef(
        name: 'route_path',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: '/toolbox/music',
      ),
    ],
  );

  static const pageCover = SHOAnalyticsEventDef(
    key: 'page_cover',
    title: 'Page cover',
    description: 'Page hidden by route pushed on top (RouteAware.didPushNext)',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'page_name',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'SHODownloadListPage',
      ),
      SHOAnalyticsFieldDef(
        name: 'route_path',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: '/toolbox/downloads',
      ),
    ],
  );

  static const pageResume = SHOAnalyticsEventDef(
    key: 'page_resume',
    title: 'Page resume',
    description:
        'Page visible again after cover removed (RouteAware.didPopNext)',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'page_name',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'SHODownloadListPage',
      ),
      SHOAnalyticsFieldDef(
        name: 'route_path',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: '/toolbox/downloads',
      ),
    ],
  );

  static const routePush = SHOAnalyticsEventDef(
    key: 'route_push',
    title: 'Route push',
    description: 'Navigator stack push (NavigatorObserver.didPush)',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'navigator_id',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'root',
      ),
      SHOAnalyticsFieldDef(
        name: 'route_path',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: '/toolbox/music',
      ),
      SHOAnalyticsFieldDef(
        name: 'previous_route_path',
        type: SHOAnalyticsFieldType.string,
        example: '/toolbox',
      ),
    ],
  );

  static const routePop = SHOAnalyticsEventDef(
    key: 'route_pop',
    title: 'Route pop',
    description: 'Navigator stack pop (NavigatorObserver.didPop)',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'navigator_id',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'root',
      ),
      SHOAnalyticsFieldDef(
        name: 'route_path',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: '/toolbox/music',
      ),
      SHOAnalyticsFieldDef(
        name: 'previous_route_path',
        type: SHOAnalyticsFieldType.string,
        example: '/toolbox/downloads',
      ),
    ],
  );

  static const routeReplace = SHOAnalyticsEventDef(
    key: 'route_replace',
    title: 'Route replace',
    description: 'Navigator route replaced (NavigatorObserver.didReplace)',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'navigator_id',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'root',
      ),
      SHOAnalyticsFieldDef(
        name: 'route_path',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: '/toolbox/music',
      ),
    ],
  );

  static const routeRemove = SHOAnalyticsEventDef(
    key: 'route_remove',
    title: 'Route remove',
    description: 'Navigator route removed (NavigatorObserver.didRemove)',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'navigator_id',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'root',
      ),
      SHOAnalyticsFieldDef(
        name: 'route_path',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: '/toolbox/music',
      ),
    ],
  );

  static const tabSwitch = SHOAnalyticsEventDef(
    key: 'tab_switch',
    title: 'Tab switch',
    description: 'User switched bottom navigation tab (StatefulShellRoute)',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'from_index',
        type: SHOAnalyticsFieldType.intValue,
        required: true,
        example: 0,
      ),
      SHOAnalyticsFieldDef(
        name: 'to_index',
        type: SHOAnalyticsFieldType.intValue,
        required: true,
        example: 1,
      ),
      SHOAnalyticsFieldDef(
        name: 'from_route',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: '/',
      ),
      SHOAnalyticsFieldDef(
        name: 'to_route',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: '/category',
      ),
      SHOAnalyticsFieldDef(
        name: 'from_tab_id',
        type: SHOAnalyticsFieldType.string,
        required: true,
        description: 'home / category / cart / profile',
        example: 'home',
      ),
      SHOAnalyticsFieldDef(
        name: 'to_tab_id',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'category',
      ),
      SHOAnalyticsFieldDef(
        name: 'is_reselect',
        type: SHOAnalyticsFieldType.boolValue,
        description: 'Tapped the already active tab (pop branch to root)',
        example: false,
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

  static const deeplinkReceive = SHOAnalyticsEventDef(
    key: 'deeplink_receive',
    title: 'Deep link receive',
    description: 'App received a deep link URI from system or app_links',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'uri',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'shoo://flash-sale?activityId=activity_flash_001',
      ),
      SHOAnalyticsFieldDef(
        name: 'app_path',
        type: SHOAnalyticsFieldType.string,
        example: '/flash-sale?activityId=activity_flash_001',
      ),
      SHOAnalyticsFieldDef(
        name: 'action_type',
        type: SHOAnalyticsFieldType.string,
        example: 'flashSale',
      ),
      SHOAnalyticsFieldDef(
        name: 'source',
        type: SHOAnalyticsFieldType.string,
        required: true,
        description: 'initial_link / stream',
        example: 'stream',
      ),
      SHOAnalyticsFieldDef(
        name: 'supported',
        type: SHOAnalyticsFieldType.boolValue,
        example: true,
      ),
    ],
  );

  static const flashSaleNotificationReceive = SHOAnalyticsEventDef(
    key: 'flash_sale_notification_receive',
    title: 'Flash sale notification receive',
    description: 'App received flash sale reminder notification payload',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'raw_payload',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example:
            'session_1|p_1|商品名|https://img|2026-06-27T10:00:00|activity_flash_001',
      ),
      SHOAnalyticsFieldDef(
        name: 'session_id',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'session_1',
      ),
      SHOAnalyticsFieldDef(
        name: 'product_id',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'p_1',
      ),
      SHOAnalyticsFieldDef(
        name: 'activity_id',
        type: SHOAnalyticsFieldType.string,
        example: 'activity_flash_001',
      ),
      SHOAnalyticsFieldDef(
        name: 'title',
        type: SHOAnalyticsFieldType.string,
        example: '限量抢购商品',
      ),
      SHOAnalyticsFieldDef(
        name: 'source',
        type: SHOAnalyticsFieldType.string,
        required: true,
        description: 'cold_start / notification_tap / pending_queue',
        example: 'notification_tap',
      ),
    ],
  );

  static const flashSaleNotificationClick = SHOAnalyticsEventDef(
    key: 'flash_sale_notification_click',
    title: 'Flash sale notification click',
    description: 'User tapped flash sale reminder notification',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'raw_payload',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example:
            'session_1|p_1|商品名|https://img|2026-06-27T10:00:00|activity_flash_001',
      ),
      SHOAnalyticsFieldDef(
        name: 'session_id',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'session_1',
      ),
      SHOAnalyticsFieldDef(
        name: 'product_id',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'p_1',
      ),
      SHOAnalyticsFieldDef(
        name: 'activity_id',
        type: SHOAnalyticsFieldType.string,
        example: 'activity_flash_001',
      ),
      SHOAnalyticsFieldDef(
        name: 'source',
        type: SHOAnalyticsFieldType.string,
        required: true,
        description: 'cold_start / notification_tap',
        example: 'notification_tap',
      ),
    ],
  );

  static const flashSaleReminderPopupShow = SHOAnalyticsEventDef(
    key: 'flash_sale_reminder_popup_show',
    title: 'Flash sale reminder popup show',
    description: 'Foreground flash sale reminder popup displayed',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'session_id',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'session_1',
      ),
      SHOAnalyticsFieldDef(
        name: 'product_id',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'p_1',
      ),
      SHOAnalyticsFieldDef(
        name: 'activity_id',
        type: SHOAnalyticsFieldType.string,
        example: 'activity_flash_001',
      ),
      SHOAnalyticsFieldDef(
        name: 'trigger',
        type: SHOAnalyticsFieldType.string,
        required: true,
        description: 'foreground_poll / debug',
        example: 'foreground_poll',
      ),
    ],
  );

  static const flashSaleReminderPopupAction = SHOAnalyticsEventDef(
    key: 'flash_sale_reminder_popup_action',
    title: 'Flash sale reminder popup action',
    description: 'User interacted with flash sale reminder popup',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'session_id',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'session_1',
      ),
      SHOAnalyticsFieldDef(
        name: 'product_id',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'p_1',
      ),
      SHOAnalyticsFieldDef(
        name: 'action',
        type: SHOAnalyticsFieldType.string,
        required: true,
        description: 'go_flash_sale / dismiss',
        example: 'go_flash_sale',
      ),
    ],
  );

  static const pageLoadTime = SHOAnalyticsEventDef(
    key: 'page_load_time',
    title: 'Page load time',
    description: 'Page shell or content ready timing',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'page_name',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'coupon_list',
      ),
      SHOAnalyticsFieldDef(
        name: 'duration_ms',
        type: SHOAnalyticsFieldType.intValue,
        required: true,
        example: 320,
      ),
      SHOAnalyticsFieldDef(
        name: 'load_phase',
        type: SHOAnalyticsFieldType.string,
        required: true,
        description: 'first_frame / content_ready / webview_finished',
        example: 'content_ready',
      ),
      SHOAnalyticsFieldDef(
        name: 'route_path',
        type: SHOAnalyticsFieldType.string,
        example: '/coupons',
      ),
    ],
  );

  static const webViewPageLoad = SHOAnalyticsEventDef(
    key: 'webview_page_load',
    title: 'WebView page load',
    description: 'WebView onPageFinished or error timing',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'url',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'https://shoo.app/activity',
      ),
      SHOAnalyticsFieldDef(
        name: 'duration_ms',
        type: SHOAnalyticsFieldType.intValue,
        required: true,
        example: 850,
      ),
      SHOAnalyticsFieldDef(
        name: 'success',
        type: SHOAnalyticsFieldType.boolValue,
        required: true,
        example: true,
      ),
      SHOAnalyticsFieldDef(
        name: 'error_code',
        type: SHOAnalyticsFieldType.intValue,
        example: -1009,
      ),
    ],
  );

  static const pageRenderError = SHOAnalyticsEventDef(
    key: 'page_render_error',
    title: 'Page render error',
    description: 'Single page build failed and was caught by error boundary',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'page_name',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'order_detail',
      ),
      SHOAnalyticsFieldDef(
        name: 'error',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'Null check operator used on a null value',
      ),
      SHOAnalyticsFieldDef(
        name: 'route_path',
        type: SHOAnalyticsFieldType.string,
        example: '/orders/123',
      ),
    ],
  );

  static const bridgeError = SHOAnalyticsEventDef(
    key: 'bridge_error',
    title: 'WebView bridge error',
    description: 'Activity H5 JS bridge parse or dispatch failure',
    fields: [
      SHOAnalyticsFieldDef(
        name: 'page_name',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'activity',
      ),
      SHOAnalyticsFieldDef(
        name: 'error',
        type: SHOAnalyticsFieldType.string,
        required: true,
        example: 'invalid_json',
      ),
      SHOAnalyticsFieldDef(
        name: 'bridge_type',
        type: SHOAnalyticsFieldType.string,
        example: 'navigate',
      ),
      SHOAnalyticsFieldDef(
        name: 'bridge_action',
        type: SHOAnalyticsFieldType.string,
        example: 'openRoute',
      ),
    ],
  );

  static final List<SHOAnalyticsEventDef> all = [
    appLaunch,
    appClose,
    appStartupTime,
    pageEnter,
    pageExit,
    pageCover,
    pageResume,
    routePush,
    routePop,
    routeReplace,
    routeRemove,
    tabSwitch,
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
    deeplinkReceive,
    flashSaleNotificationReceive,
    flashSaleNotificationClick,
    flashSaleReminderPopupShow,
    flashSaleReminderPopupAction,
    pageLoadTime,
    webViewPageLoad,
    pageRenderError,
    bridgeError,
  ];

  static SHOAnalyticsEventDef? find(String key) {
    for (final event in all) {
      if (event.key == key) return event;
    }
    return null;
  }
}
