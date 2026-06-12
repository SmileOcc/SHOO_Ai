// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SHOO';

  @override
  String get tabShop => 'Shop';

  @override
  String get tabCategory => 'Category';

  @override
  String get categorySortAll => 'All';

  @override
  String get categorySortHot => 'Hot';

  @override
  String get categorySortNewest => 'New';

  @override
  String get categoryFilter => 'Filter';

  @override
  String get categoryFilterPriceRange => 'Price range';

  @override
  String get categoryFilterMinPrice => 'Min';

  @override
  String get categoryFilterMaxPrice => 'Max';

  @override
  String get categoryFilterPriceInvalid =>
      'Max price must be greater than min price';

  @override
  String get categoryFilterSort => 'Sort';

  @override
  String get categoryFilterSortDefault => 'Default';

  @override
  String get categoryFilterSortPriceHigh => 'Price: high to low';

  @override
  String get categoryFilterSortPriceLow => 'Price: low to high';

  @override
  String get tabBag => 'Bag';

  @override
  String get tabMe => 'Me';

  @override
  String get searchHint => 'Search styles, trends...';

  @override
  String get recommendedTitle => 'RECOMMENDED FOR YOU';

  @override
  String get cartEmptyTitle => 'Your bag is empty';

  @override
  String get cartEmptySubtitle => 'Add items to get started.';

  @override
  String get cartEmptyAction => 'Start Shopping';

  @override
  String get cartLoginTitle => 'Sign in required';

  @override
  String get cartLoginSubtitle =>
      'Sign in to view and manage items in your bag';

  @override
  String get cartLoginAction => 'Sign In';

  @override
  String get profileSignIn => 'Sign in / Register';

  @override
  String get profileSignInHint => 'Enjoy exclusive deals & faster checkout';

  @override
  String get profileOrders => 'Orders';

  @override
  String get profileServices => 'Services';

  @override
  String get profileSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageZh => '中文';

  @override
  String get settingsGroupGeneral => 'General';

  @override
  String get settingsGroupAccount => 'Account';

  @override
  String get settingsGroupAbout => 'About';

  @override
  String get settingsAbout => 'About Us';

  @override
  String get settingsAboutDescription =>
      'SHOO is a fashion e-commerce app for young shoppers — curated trends, fast checkout, and reliable after-sales support.';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsTermsOfService => 'Terms of Service';

  @override
  String get settingsCompanyName => 'SHOO COMMERCE TECHNOLOGY PTE. LTD.';

  @override
  String get ordersAllShort => 'All';

  @override
  String get loginTitle => 'Sign In';

  @override
  String get loginPhoneHint => 'Phone number';

  @override
  String get loginPasswordHint => 'Password';

  @override
  String get loginSubmit => 'Sign In';

  @override
  String get loginMockHint => 'Mock login — any phone/password works';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get noData => 'No data yet';

  @override
  String get loadFailed => 'Failed to load. Please retry.';

  @override
  String get logout => 'Log Out';

  @override
  String welcomeUser(String name) {
    return 'Hi, $name';
  }

  @override
  String versionLabel(String appName, String version) {
    return '$appName v$version — Phase 3';
  }

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationPhone => 'Enter a valid phone number';

  @override
  String get validationEmail => 'Enter a valid email';

  @override
  String validationMinLength(int length) {
    return 'At least $length characters';
  }

  @override
  String get offlineBanner =>
      'You are offline. Some features may be unavailable.';

  @override
  String get localServerBanner =>
      'Local mock server is not running. Start it: cd server && npm run dev';

  @override
  String get splashTagline => 'Fashion for everyone';

  @override
  String get onboardingTitle1 => 'Trending Styles';

  @override
  String get onboardingDesc1 => 'Discover the latest looks curated for you.';

  @override
  String get onboardingTitle2 => 'Fast Delivery';

  @override
  String get onboardingDesc2 => 'Track orders and enjoy quick shipping.';

  @override
  String get onboardingTitle3 => 'Exclusive Deals';

  @override
  String get onboardingDesc3 => 'Save more with coupons and flash sales.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Get Started';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerConfirmPassword => 'Confirm password';

  @override
  String get registerSubmit => 'Register';

  @override
  String get loginNoAccount => 'No account? Register';

  @override
  String get registerHasAccount => 'Already have an account? Sign in';

  @override
  String get registerPasswordMismatch => 'Passwords do not match';

  @override
  String get registerMockHint => 'Mock register — creates a local session';

  @override
  String get messageTitle => 'Messages';

  @override
  String get messageEmpty => 'No messages yet';

  @override
  String get profileMessages => 'Messages';

  @override
  String get profileShareDemo => 'Share Demo';

  @override
  String get profileCameraPermission => 'Camera Permission';

  @override
  String get debugPanelTitle => 'Debug Panel';

  @override
  String get debugPanelHint =>
      'Tap the top app bar 5 times quickly to open. Disabled in release builds.';

  @override
  String get debugEnvSection => 'Environment';

  @override
  String get debugResetEnv => 'Reset to build default';

  @override
  String get debugEnvRestarting => 'Switching environment, restarting app…';

  @override
  String get debugShowEnvBadge => 'Show environment badge';

  @override
  String get debugShowEnvBadgeHint =>
      'Display current env at top-right (9pt red text)';

  @override
  String envBadgeLabel(String env) {
    return 'Env: $env';
  }

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogConfirm => 'Confirm';

  @override
  String get settingsGroupDiagnostics => 'Diagnostics & data';

  @override
  String get settingsReportLogs => 'Report logs';

  @override
  String get settingsReportLogsHint => 'Export cached logs via system share';

  @override
  String get settingsReportLogsEmpty => 'No logs to report';

  @override
  String get settingsReportLogsConfirmTitle => 'Report logs';

  @override
  String get settingsReportLogsConfirmMessage =>
      'Export local log file via share sheet. Continue?';

  @override
  String get settingsReportLogsSuccess => 'Share sheet opened';

  @override
  String get settingsClearCache => 'Clear cache';

  @override
  String get settingsClearCacheHint => 'View and clear cache by category';

  @override
  String get settingsCacheTitle => 'Clear cache';

  @override
  String get settingsCacheTotal => 'Total cache size';

  @override
  String get settingsCacheLogs => 'App logs';

  @override
  String get settingsCacheLogsHint => 'Locally cached runtime logs';

  @override
  String get settingsCacheImages => 'Image cache';

  @override
  String get settingsCacheImagesHint => 'Network image disk cache';

  @override
  String get settingsCacheSearch => 'Search history';

  @override
  String get settingsCacheSearchHint => 'Recent search keywords';

  @override
  String get settingsCacheCart => 'Cart snapshot';

  @override
  String get settingsCacheCartHint => 'Local cart data';

  @override
  String get settingsCacheActivity => 'Activity prefetch';

  @override
  String get settingsCacheActivityHint =>
      'Marketing activity config and images';

  @override
  String get settingsCachePreferences => 'Other preferences';

  @override
  String get settingsCachePreferencesHint =>
      'Local prefs except theme and language';

  @override
  String get settingsCacheClearTitle => 'Clear cache';

  @override
  String settingsCacheClearMessage(String name) {
    return 'Clear \"$name\"?';
  }

  @override
  String get settingsCacheClearConfirm => 'Clear';

  @override
  String get settingsCacheClearAll => 'Clear all cache';

  @override
  String get settingsCacheClearAllTitle => 'Clear all cache';

  @override
  String get settingsCacheClearAllMessage =>
      'This will clear all local cache categories. Cannot be undone.';

  @override
  String get settingsCacheCleared => 'Cache cleared';

  @override
  String get debugClearCache => 'Clear local cache';

  @override
  String get debugCacheCleared => 'Cache cleared';

  @override
  String get sharePanelTitle => 'Share';

  @override
  String get shareSystem => 'Share via system';

  @override
  String get shareCopyLink => 'Copy link';

  @override
  String get shareWechat => 'WeChat';

  @override
  String get shareWechatMock => 'WeChat share (mock)';

  @override
  String get shareMore => 'More options';

  @override
  String get shareProductCard => 'Share product card';

  @override
  String get shareLinkCopied => 'Link copied';

  @override
  String get imagePickerGallery => 'Gallery';

  @override
  String get imagePickerCamera => 'Camera';

  @override
  String imagePickerHint(int count) {
    return 'Up to $count photos';
  }

  @override
  String get afterSaleEvidenceLabel => 'Upload evidence photos';

  @override
  String get reviewSubmitTitle => 'Write a review';

  @override
  String get reviewSubmitContentLabel => 'Your review';

  @override
  String get reviewSubmitContentHint =>
      'Share your experience with this product';

  @override
  String get reviewSubmitPhotosLabel => 'Photos';

  @override
  String get reviewSubmitAction => 'Submit review';

  @override
  String get reviewSubmitContentRequired => 'Please write your review';

  @override
  String reviewSubmitSuccess(int count) {
    return 'Review submitted with $count photo(s)';
  }

  @override
  String get logisticsLiveUpdates => 'Live updates from native push';

  @override
  String get updateTitle => 'Update Available';

  @override
  String updateNewVersion(String version) {
    return 'Version $version is available';
  }

  @override
  String get updateLater => 'Later';

  @override
  String get updateNow => 'Update Now';

  @override
  String updateDownloadProgress(int percent) {
    return 'Downloading update... $percent%';
  }

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get notFoundMessage => 'The page you are looking for does not exist.';

  @override
  String notFoundLocation(String location) {
    return 'Unknown route: $location';
  }

  @override
  String get notFoundGoHome => 'Back to home';

  @override
  String get dialogClose => 'Close';

  @override
  String get debugNetworkLogEntry => 'Network log debug';

  @override
  String get debugNetworkLogEntryHint =>
      'Configure request/response logging and API filters';

  @override
  String get debugNetworkLogTitle => 'Network log debug';

  @override
  String get debugNetworkLogHint =>
      'Changes apply immediately. Logs go to console and local log cache (DEBUG level).';

  @override
  String get debugNetworkLogEnabled => 'Enable network logging';

  @override
  String get debugNetworkLogEnabledHint => 'Turn off to suppress all API logs';

  @override
  String get debugNetworkLogRequest => 'Log request params';

  @override
  String get debugNetworkLogRequestHint => 'Includes query string and body';

  @override
  String get debugNetworkLogResponse => 'Log response body';

  @override
  String get debugNetworkLogResponseHint => 'Includes response data payload';

  @override
  String get debugNetworkLogMockRemote => 'Mock remote reporting';

  @override
  String get debugNetworkLogMockRemoteHint =>
      'When on, analytics and network logs are simulated locally only';

  @override
  String get debugNetworkLogRemoteHint =>
      'When Mock is off, logs go to local server (127.0.0.1:3847). In-app Mock API auto-targets local server. Android emulator: API_BASE_URL=http://10.0.2.2:3847/api/v1';

  @override
  String get debugNetworkLogFilterEnabled => 'Filter by API path';

  @override
  String get debugNetworkLogFilterEnabledHint =>
      'Only log APIs whose path contains listed keywords';

  @override
  String get debugNetworkLogFilterPaths => 'API path keywords';

  @override
  String get debugNetworkLogFilterPathsHint =>
      'One per line or comma-separated, e.g. /products, /banners';

  @override
  String get debugAnalyticsEntry => 'Business analytics';

  @override
  String get debugAnalyticsEntryHint =>
      'View event keys, fields, and preview reporting backends';

  @override
  String get debugAnalyticsTabEvents => 'Events';

  @override
  String get debugAnalyticsTabBackends => 'Backends';

  @override
  String get debugAnalyticsTabHistory => 'History';

  @override
  String get debugAnalyticsEventKey => 'Event key';

  @override
  String get debugAnalyticsFields => 'Fields';

  @override
  String get debugAnalyticsFire => 'Fire';

  @override
  String debugAnalyticsFired(String key) {
    return 'Fired: $key';
  }

  @override
  String get debugAnalyticsBackendsHint =>
      'Registered backends; extend via registerBackend()';

  @override
  String get debugAnalyticsBackendOn => 'On';

  @override
  String get debugAnalyticsBackendOff => 'Off';

  @override
  String get debugAnalyticsMockRemoteQueue => 'Mock remote queue';

  @override
  String get debugAnalyticsHistoryEmpty => 'No analytics records yet';

  @override
  String get debugAnalyticsClearHistory => 'Clear history';

  @override
  String get debugAnalyticsBackendsUsed => 'Backends';

  @override
  String get debugToolsSection => 'Debug Tools';

  @override
  String get debugUpdateEntry => 'Update Popup';

  @override
  String get debugUpdateEntryHint => 'Configure version, notes, force update';

  @override
  String get debugActivityEntry => 'Activity Popup';

  @override
  String get debugActivityEntryHint => 'Configure ad delay, schedule, prefetch';

  @override
  String get debugUpdateTitle => 'Update Debug';

  @override
  String get debugActivityTitle => 'Activity Debug';

  @override
  String get debugOverrideEnabled => 'Use debug override';

  @override
  String get debugOverrideHint => 'Enable override to preview';

  @override
  String get debugUpdateOverrideHint =>
      'When off, home uses normal API version check';

  @override
  String get debugActivityOverrideHint =>
      'When off, home uses normal API activity fetch';

  @override
  String get debugFlowNormal => 'Active: normal API flow';

  @override
  String get debugFlowOverride => 'Active: debug override';

  @override
  String get debugOverrideActiveNow =>
      'Debug override enabled — home will use this config';

  @override
  String get debugOverrideInactiveNow =>
      'Debug override disabled — home uses normal API flow';

  @override
  String get debugUpdateVersion => 'Latest version';

  @override
  String get debugUpdateNotes => 'Release notes';

  @override
  String get debugUpdateForce => 'Force update';

  @override
  String get debugUpdateUrl => 'Update URL';

  @override
  String get debugActivityDelay => 'Delay before popup (seconds)';

  @override
  String get debugActivityPopupTitle => 'Activity title';

  @override
  String get debugActivityDescription => 'Activity description';

  @override
  String get debugActivityDescScrollHint =>
      'Scrollable in popup when over 5 lines';

  @override
  String get debugActivityImageUrl => 'Image URL';

  @override
  String get debugActivityId => 'Activity ID';

  @override
  String get debugActivityLink => 'Deep link';

  @override
  String get debugActivityButton => 'Button text';

  @override
  String get debugActivityStartAt => 'Start date/time';

  @override
  String get debugActivityEndAt => 'End date/time';

  @override
  String get debugActivityDateUnset => 'Not set — always eligible';

  @override
  String get debugActivityPrefetch => 'Prefetch config & image';

  @override
  String get debugActivityPrefetchHint =>
      'Download image and cache config locally in advance';

  @override
  String get debugActivityMaxDaily => 'Max shows per day';

  @override
  String get debugNativeEntry => 'Native Bridge';

  @override
  String get debugNativeEntryHint =>
      'Test MethodChannel, EventChannel, MessageChannel';

  @override
  String get debugNativeHubTitle => 'Native Bridge Debug';

  @override
  String get debugNativeHubHint =>
      'Tap an example to invoke native code and inspect the response.';

  @override
  String get debugNativeCategoryMethod => 'MethodChannel — one-shot calls';

  @override
  String get debugNativeCategoryMessage =>
      'BasicMessageChannel — bidirectional';

  @override
  String get debugNativeCategoryEvent => 'EventChannel — continuous stream';

  @override
  String get debugNativeExamplePingTitle => 'Ping';

  @override
  String get debugNativeExamplePingDesc =>
      'Call native `ping` and verify connectivity.';

  @override
  String get debugNativeExampleVersionTitle => 'Platform version';

  @override
  String get debugNativeExampleVersionDesc =>
      'Read OS version string from native side.';

  @override
  String get debugNativeExampleMessageTitle => 'Message echo';

  @override
  String get debugNativeExampleMessageDesc =>
      'Send a map via BasicMessageChannel and get echo reply.';

  @override
  String get debugNativeExampleEventTitle => 'Tick stream';

  @override
  String get debugNativeExampleEventDesc =>
      'Subscribe to native EventChannel; receive tick every second.';

  @override
  String get debugNativeRun => 'Run';

  @override
  String get debugNativeStartStream => 'Start stream';

  @override
  String get debugNativeStopStream => 'Stop';

  @override
  String get debugNativeResult => 'Result';

  @override
  String get debugNativeStreamLog => 'Stream log';

  @override
  String get debugNativeWaiting => 'Running…';

  @override
  String get debugNativeNoResult => 'Tap Run to invoke native code';

  @override
  String get debugNativeStreamIdle => 'Tap Start stream to listen';

  @override
  String get debugNativeInputHint => 'Message payload';

  @override
  String get debugNativeCopy => 'Copy';

  @override
  String get debugNativeCopied => 'Copied to clipboard';

  @override
  String get debugSaveConfig => 'Save config';

  @override
  String get debugPreviewPopup => 'Preview popup';

  @override
  String get debugPreviewNoUpdate => 'No update available in current flow';

  @override
  String get debugPreviewNoActivity => 'No activity available in current flow';

  @override
  String get debugConfigSaved => 'Debug config saved';

  @override
  String get searchHotTitle => 'Trending searches';

  @override
  String get searchHistoryTitle => 'Recent searches';

  @override
  String get searchHistoryClear => 'Clear';

  @override
  String get searchHistoryCleared => 'Search history cleared';

  @override
  String get searchNoResults => 'No products found';

  @override
  String get pagedListNoMore => 'No more items';

  @override
  String reviewsCount(int count) {
    return '$count reviews';
  }

  @override
  String cartIssuesUnavailable(int count) {
    return '$count item(s) are no longer available';
  }

  @override
  String cartIssuesPriceChanged(int count) {
    return '$count item price(s) updated';
  }

  @override
  String cartIssuesBoth(int unavailable, int changed) {
    return '$unavailable unavailable, $changed price updated';
  }

  @override
  String get cartUnavailableBanner =>
      'Some items are unavailable. Remove them to checkout.';

  @override
  String get cartRemoveUnavailable => 'Remove unavailable';

  @override
  String get cartItemUnavailable => 'Unavailable';

  @override
  String get cartItemPriceUpdated => 'Price updated';

  @override
  String get paymentPollingStatus => 'Confirming payment status...';

  @override
  String get productDetailTitle => 'Product';

  @override
  String get productDetailLoading => 'Loading product details...';

  @override
  String get productDescriptionTitle => 'Description';

  @override
  String get productAddToBag => 'Add to Bag';

  @override
  String get productBuyNow => 'Buy Now';

  @override
  String get productCustomerService => 'Support';

  @override
  String get productCartShort => 'Cart';

  @override
  String get productMore => 'More';

  @override
  String get productCustomerServiceHint =>
      'Customer support coming soon (mock)';

  @override
  String get productAddToBagHint => 'Added to bag (mock)';

  @override
  String get reviewsTitle => 'Reviews';

  @override
  String get reviewsViewAll => 'View all';

  @override
  String get reviewsEmpty => 'No reviews yet';

  @override
  String get ordersTitle => 'My Orders';

  @override
  String get ordersAll => 'All Orders';

  @override
  String get ordersPendingPayment => 'Pending Payment';

  @override
  String get ordersShipped => 'Shipped';

  @override
  String get ordersReviews => 'Reviews';

  @override
  String get ordersToUse => 'To Use';

  @override
  String get ordersAfterSalesShort => 'Returns';

  @override
  String get profileFootprints => 'History';

  @override
  String get profileFavorites => 'Saved';

  @override
  String get profileFollowing => 'Following';

  @override
  String get profileDiscover => 'Discover';

  @override
  String get profileDiscoverBadge => 'New';

  @override
  String get profileFootprintsHint => 'Browsing history coming soon';

  @override
  String get profileFootprintsEmpty => 'No browsing history yet';

  @override
  String get profileActivityDelete => 'Delete';

  @override
  String get profileActivitySelectAll => 'Select all';

  @override
  String profileActivitySelected(int count) {
    return '$count selected';
  }

  @override
  String profileActivityDeleteSelected(int count) {
    return 'Delete ($count)';
  }

  @override
  String profileActivityDeleted(int count) {
    return 'Deleted $count items';
  }

  @override
  String get profileFollowingHint => 'Following list coming soon';

  @override
  String get profileCouponCenter => 'Coupons';

  @override
  String get profileCouponMore => 'More';

  @override
  String get profileCouponClaim => 'Claim';

  @override
  String get profileTabGuessYouLike => 'For You';

  @override
  String get profileTabMyFavorites => 'Saved';

  @override
  String get profileTabMyReviews => 'My Reviews';

  @override
  String get profileServiceNovelReading => 'Novels';

  @override
  String get profileServiceVideoPlayback => 'Videos';

  @override
  String get profileServiceToolbox => 'Toolbox';

  @override
  String get profileServiceCoupons => 'Coupons';

  @override
  String get profileServiceAfterSale => 'After-sale';

  @override
  String get profileServiceShare => 'Share';

  @override
  String get profileServiceMessages => 'Messages';

  @override
  String get profileServiceSearch => 'Search';

  @override
  String get profileFavoritesEmpty => 'No saved items yet';

  @override
  String get profileFavoriteAdded => 'Added to saved items';

  @override
  String get profileFavoriteRemoved => 'Removed from saved items';

  @override
  String get profileReviewsHint =>
      'Review your delivered orders and share feedback';

  @override
  String get ordersEmpty => 'No orders in this category';

  @override
  String orderMoreItems(int count) {
    return '+$count more';
  }

  @override
  String get orderDetailTitle => 'Order Detail';

  @override
  String get orderNoLabel => 'Order No.';

  @override
  String get orderStatusLabel => 'Status';

  @override
  String get orderCreatedAtLabel => 'Placed at';

  @override
  String get orderShippingAddress => 'Shipping address';

  @override
  String get orderItemsTitle => 'Items';

  @override
  String get orderTotalLabel => 'Total';

  @override
  String get orderStatusPendingPayment => 'Pending payment';

  @override
  String get orderStatusPaid => 'Paid';

  @override
  String get orderStatusShipped => 'Shipped';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get logisticsTitle => 'Track Package';

  @override
  String get logisticsCarrierLabel => 'Carrier';

  @override
  String get logisticsTrackingNoLabel => 'Tracking number';

  @override
  String get logisticsTimelineTitle => 'Shipment timeline';

  @override
  String get logisticsTrackAction => 'Track shipment';

  @override
  String get logisticsCopied => 'Tracking number copied';

  @override
  String get productAddToBagSuccess => 'Added to your bag';

  @override
  String get skuSelectSize => 'Select size';

  @override
  String get skuSizeLabel => 'Size';

  @override
  String get skuQuantity => 'Quantity';

  @override
  String get cartSelectAll => 'Select all';

  @override
  String get cartTotalLabel => 'Subtotal';

  @override
  String cartCheckout(int count) {
    return 'Checkout ($count)';
  }

  @override
  String get cartRemoveTitle => 'Remove item?';

  @override
  String get cartRemoveMessage => 'This item will be removed from your bag.';

  @override
  String get cartRemoveConfirm => 'Remove';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get checkoutAddressSection => 'Shipping address';

  @override
  String get checkoutAddAddress => 'Tap to select an address';

  @override
  String get checkoutNoAddress => 'Please select a shipping address';

  @override
  String get checkoutPlaceOrder => 'Place Order';

  @override
  String get paymentTitle => 'Payment';

  @override
  String get paymentMockTitle => 'Mock Checkout';

  @override
  String get paymentMockHint =>
      'This is a simulated payment. No real charge will be made.';

  @override
  String get paymentPayNow => 'Pay Now';

  @override
  String get paymentSuccessTitle => 'Payment Successful';

  @override
  String get paymentSuccessMessage =>
      'Your order has been placed. Thank you for shopping!';

  @override
  String get paymentViewOrder => 'View Order';

  @override
  String get paymentContinueShopping => 'Continue Shopping';

  @override
  String get addressListTitle => 'Addresses';

  @override
  String get addressSelectTitle => 'Select Address';

  @override
  String get addressEmpty => 'No addresses yet';

  @override
  String get addressDefaultTag => 'Default';

  @override
  String get addressAddNew => 'Add Address';

  @override
  String get addressDelete => 'Delete';

  @override
  String get addressDeleteConfirmTitle => 'Delete address';

  @override
  String get addressDeleteConfirmMessage =>
      'Are you sure you want to delete this address?';

  @override
  String get addressFormAddTitle => 'Add Address';

  @override
  String get addressFormEditTitle => 'Edit Address';

  @override
  String get addressNameLabel => 'Recipient';

  @override
  String get addressPhoneLabel => 'Phone';

  @override
  String get addressLine1Label => 'Street address';

  @override
  String get addressLine2Label => 'Apt / floor (optional)';

  @override
  String get addressCityLabel => 'City';

  @override
  String get addressRegionLabel => 'State / region';

  @override
  String get addressPostalCodeLabel => 'Postal code (optional)';

  @override
  String get addressSetDefault => 'Set as default';

  @override
  String get addressSaved => 'Address saved';

  @override
  String get toolboxTitle => 'Toolbox';

  @override
  String get toolboxGroupReading => 'Reading';

  @override
  String get toolboxGroupTools => 'Tools';

  @override
  String get toolboxBookshelf => 'My Bookshelf';

  @override
  String get toolboxVideoPlayback => 'Videos';

  @override
  String get toolboxMusicPlayback => 'Music';

  @override
  String get toolboxFileDownload => 'Downloads';

  @override
  String get toolboxComingSoon => 'Coming soon';

  @override
  String get downloadListTitle => 'Downloads';

  @override
  String get downloadTabAll => 'All';

  @override
  String get downloadTabDownloading => 'Downloading';

  @override
  String get downloadTabPaused => 'Paused';

  @override
  String get downloadTabCompleted => 'Completed';

  @override
  String get downloadAddTask => 'Add task';

  @override
  String get downloadEmpty => 'No download tasks';

  @override
  String get downloadTaskDialogTitle => 'New download';

  @override
  String get downloadUrlLabel => 'Download URL';

  @override
  String get downloadFileNameLabel => 'File name';

  @override
  String get downloadFileNameHint => 'Optional — inferred from URL if empty';

  @override
  String get downloadPriorityLabel => 'Priority download';

  @override
  String get downloadConfirmStart => 'Start download';

  @override
  String get downloadStatusDownloading => 'Downloading';

  @override
  String get downloadStatusPaused => 'Paused';

  @override
  String get downloadStatusCompleted => 'Completed';

  @override
  String get downloadActionDelete => 'Delete';

  @override
  String get downloadActionPause => 'Pause';

  @override
  String get downloadActionStart => 'Resume';

  @override
  String get downloadDeleteConfirmTitle => 'Delete download';

  @override
  String get downloadDeleteConfirmMessage =>
      'Delete this task and remove any downloaded file?';

  @override
  String get downloadTypeDoc => 'Document';

  @override
  String get downloadTypePdf => 'PDF';

  @override
  String get downloadTypeExcel => 'Spreadsheet';

  @override
  String get downloadTypeZip => 'Archive';

  @override
  String get downloadTypeMusicZip => 'Music pack';

  @override
  String get downloadTypeVideo => 'Video';

  @override
  String get downloadTypeAudio => 'Audio';

  @override
  String get downloadTypeOther => 'File';

  @override
  String get downloadActionCopyUrl => 'Copy URL';

  @override
  String get downloadUrlCopied => 'Download URL copied';

  @override
  String get downloadPreviewUnsupported => 'This file type cannot be previewed';

  @override
  String get downloadPreviewNotCompleted =>
      'Download not finished. Complete the download to preview';

  @override
  String get downloadPreviewFailed =>
      'Unable to open this file. Please try again later';

  @override
  String get downloadPreviewOk => 'OK';

  @override
  String get downloadBadgeExtracted => 'Extracted';

  @override
  String get downloadBadgeInMusicLibrary => 'In music';

  @override
  String get downloadBadgeInBookshelf => 'In bookshelf';

  @override
  String get downloadActionAddBookshelf => 'Add to bookshelf';

  @override
  String get downloadActionAddMusicLibrary => 'Add to music list';

  @override
  String get downloadAddedToMusicLibrary => 'Added to music list';

  @override
  String get musicInvalidTitle => 'Invalid music';

  @override
  String get musicInvalidMessage =>
      'Local extracted files were not found. Playback is unavailable.';

  @override
  String get txtReaderLoadingFile => 'Reading file…';

  @override
  String get txtReaderParsingChapters => 'Parsing chapters…';

  @override
  String get txtReaderPaginating => 'Formatting pages…';

  @override
  String get txtReaderChapters => 'Chapters';

  @override
  String get txtReaderFontSize => 'Font size';

  @override
  String txtReaderPageProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String txtReaderChapterPageProgress(int current, int total) {
    return 'Page $current / $total';
  }

  @override
  String get txtReaderLoadFailed => 'Failed to load file. Please try again';

  @override
  String get txtReaderRetry => 'Retry';

  @override
  String get txtReaderRemoveBookshelf => 'Remove from shelf';

  @override
  String get txtReaderRemovedBookshelf => 'Removed from shelf';

  @override
  String get txtReaderTaskMissing =>
      'Download task not found. It may have been deleted';

  @override
  String get txtReaderFontColor => 'Font color';

  @override
  String get txtReaderDarkMode => 'Dark mode';

  @override
  String get txtReaderAddBookshelf => 'Add to shelf';

  @override
  String get txtReaderAddedBookshelf => 'On shelf';

  @override
  String get txtReaderPrevChapter => 'Previous';

  @override
  String get txtReaderNextChapter => 'Next';

  @override
  String get txtReaderNight => 'Night';

  @override
  String get txtReaderSettingsLabel => 'Settings';

  @override
  String get txtReaderShare => 'Share';

  @override
  String get txtReaderBackground => 'Background';

  @override
  String get bookshelfTitle => 'My Bookshelf';

  @override
  String get bookshelfEmpty =>
      'Your shelf is empty. Add novels from the reader to see them here.';

  @override
  String get bookshelfUnread => 'Not started yet';

  @override
  String bookshelfReadingProgress(int chapter) {
    return 'Chapter $chapter';
  }

  @override
  String get bookshelfNotCompleted => 'Download not completed';

  @override
  String get bookshelfFileMissing => 'Local file removed';

  @override
  String get bookshelfUnknownTitle => 'Unknown novel';

  @override
  String get bookshelfRemoveAction => 'Remove';

  @override
  String get bookshelfRemoveConfirmTitle => 'Remove from shelf';

  @override
  String get bookshelfRemoveConfirmMessage =>
      'Remove this novel from your shelf? Reading progress will be kept.';

  @override
  String get bookshelfCleanupOrphansTitle => 'Clean up invalid entries';

  @override
  String bookshelfCleanupOrphansMessage(int count) {
    return '$count novels no longer have a matching download task';
  }

  @override
  String get bookshelfCleanupOrphansAction => 'Clean all';

  @override
  String get videoLibraryTitle => 'Videos';

  @override
  String get videoLibraryEmpty =>
      'No videos yet. Download locally or tap Online Play in the top right';

  @override
  String get videoLibraryGoDownloads => 'Go to Downloads';

  @override
  String get videoLibraryOnlinePlay => 'Online play';

  @override
  String get videoLibraryOnlinePlayTitle => 'Online play';

  @override
  String get videoLibraryOnlinePlayHint => 'Enter video URL (http/https)';

  @override
  String get videoLibraryOnlinePlayButton => 'Play';

  @override
  String get videoLibraryInvalidUrl => 'Enter a valid video URL';

  @override
  String get videoLibraryOnlineBadge => 'Online';

  @override
  String get videoLibraryOnlineReady => 'Streaming';

  @override
  String get videoLibraryCachedComplete => 'Cached';

  @override
  String videoLibraryCacheSize(String size) {
    return 'Cached $size';
  }

  @override
  String videoLibraryCacheProgress(
    String downloaded,
    String total,
    String percent,
  ) {
    return 'Cached $downloaded / $total · $percent%';
  }

  @override
  String videoLibraryLastPlayed(String time) {
    return 'Last played $time';
  }

  @override
  String get videoLibraryRemoveAction => 'Remove';

  @override
  String get videoLibraryRemoveConfirmTitle => 'Remove video';

  @override
  String get videoLibraryRemoveConfirmMessage =>
      'Remove this video from the list? Playback progress will be kept.';

  @override
  String get videoLibraryReady => 'Ready to play';

  @override
  String get videoLibraryNotCompleted => 'Video download not finished';

  @override
  String get videoLibraryFileMissing => 'Local video file removed';

  @override
  String videoPlayerComments(int count) {
    return 'Comments $count';
  }

  @override
  String get videoPlayerCommentEmpty =>
      'No comments yet. Be the first to comment';

  @override
  String get videoPlayerCommentHint => 'Write a friendly comment…';

  @override
  String get videoPlayerSendComment => 'Send';

  @override
  String get videoPlayerCommentAuthorMe => 'Me';

  @override
  String get videoPlayerFullscreen => 'Fullscreen';

  @override
  String get videoPlayerExitFullscreen => 'Exit fullscreen';

  @override
  String get videoPlayerVolume => 'Volume';

  @override
  String get videoPlayerDanmakuOn => 'Show danmaku';

  @override
  String get videoPlayerDanmakuOff => 'Hide danmaku';

  @override
  String get videoPlayerShare => 'Share';

  @override
  String get videoPlayerDownload => 'Download video';

  @override
  String get videoPlayerDownloadUnsupported =>
      'Download not supported yet. Try again later';

  @override
  String get videoPlayerDownloadStarted => 'Added to download queue';

  @override
  String get musicLibraryTitle => 'Music';

  @override
  String get musicLibraryEmpty => 'No music yet';

  @override
  String get musicLibraryLocalBadge => 'Local';

  @override
  String get musicLibraryOnlineBadge => 'Online';

  @override
  String get musicLibrarySortRecent => 'Recent';

  @override
  String get musicLibrarySortLiked => 'Liked';

  @override
  String get musicLibraryLikedBadge => 'Liked';

  @override
  String get musicPackAddToLibraryTitle => 'Add to music library';

  @override
  String get musicPackAddToLibraryMessage =>
      'Add this music pack to your music library?';

  @override
  String get musicPackAddToLibraryConfirm => 'Add';

  @override
  String get musicPackImporting => 'Extracting music, please wait…';

  @override
  String get musicLibraryNowPlayingBadge => 'Playing';

  @override
  String musicLibraryPlayCount(String count) {
    return '$count plays';
  }

  @override
  String musicLibraryLastPlayedDate(String time) {
    return 'Played $time';
  }

  @override
  String get musicLibraryRemoveAction => 'Remove';

  @override
  String get musicLibraryRemoveConfirmTitle => 'Delete local cache';

  @override
  String get musicLibraryRemoveConfirmMessage =>
      'Remove cached song files? The downloaded zip in the download list will not be affected.';

  @override
  String musicLibraryLastPlayed(String time) {
    return 'Last played $time';
  }

  @override
  String get musicPlayerNowPlaying => 'Now Playing';

  @override
  String get musicPlayerShowLyrics => 'Lyrics';

  @override
  String get musicPlayerShowCover => 'Cover';

  @override
  String get musicPlayerNoLyrics => 'No lyrics';

  @override
  String get musicPlayerTrackMissing => 'Track not found';

  @override
  String get musicPlayerDownloadSong => 'Download song';

  @override
  String get musicPlayerAlreadyDownloaded => 'Already downloaded';

  @override
  String get musicPlayerDownloadSuccess => 'Song cached locally';

  @override
  String get musicPlayerDownloadFailed =>
      'Cannot download yet. Please download the music resource zip first.';

  @override
  String get musicPlayerPlaylistTitle => 'Playlist';

  @override
  String get musicPlayerLikedPlaylistTitle => 'Liked Songs';

  @override
  String musicPlayerPlaylistCount(String count) {
    return '$count songs';
  }

  @override
  String get musicPlayerPlaylistEmpty => 'No songs in playlist';

  @override
  String get musicPlayerLikedPlaylistEmpty =>
      'No liked songs yet. Tap ♥ in the music library.';

  @override
  String get musicPlayerNoValidTracks =>
      'No playable tracks found. Playback paused.';

  @override
  String get musicPlayerMoreTitle => 'More';

  @override
  String get musicPlayerShare => 'Share';

  @override
  String get musicLibraryBuiltinBadge => 'Built-in';

  @override
  String get profileAddresses => 'Addresses';

  @override
  String get profileCoupons => 'Coupons';

  @override
  String get profileAfterSales => 'After-Sales';

  @override
  String get checkoutCouponSection => 'Coupon';

  @override
  String get couponSelectHint => 'Select a coupon';

  @override
  String get couponListTitle => 'My Coupons';

  @override
  String get couponSelectTitle => 'Select Coupon';

  @override
  String get couponNone => 'No coupon';

  @override
  String couponMinOrder(String amount) {
    return 'Min. order $amount';
  }

  @override
  String get couponNotEligible => 'Does not meet minimum order';

  @override
  String get priceSubtotal => 'Subtotal';

  @override
  String get priceDiscount => 'Coupon discount';

  @override
  String get priceShipping => 'Shipping';

  @override
  String get afterSaleListTitle => 'After-Sales';

  @override
  String get afterSaleApplyTitle => 'Apply for After-Sales';

  @override
  String get afterSaleApplyAction => 'Apply for After-Sales';

  @override
  String get afterSaleTypeLabel => 'Request type';

  @override
  String get afterSaleTypeRefund => 'Refund only';

  @override
  String get afterSaleTypeReturnRefund => 'Return & refund';

  @override
  String get afterSaleReasonLabel => 'Reason';

  @override
  String get afterSaleReasonHint => 'Describe the issue...';

  @override
  String get afterSaleReasonRequired => 'Please enter a reason';

  @override
  String get afterSaleSubmit => 'Submit Request';

  @override
  String get afterSaleSubmitSuccess => 'After-sales request submitted';

  @override
  String get afterSaleGoOrders => 'View Orders';

  @override
  String get afterSaleStatusPending => 'Pending review';

  @override
  String get afterSaleStatusApproved => 'Approved';

  @override
  String get afterSaleStatusRejected => 'Rejected';

  @override
  String get afterSaleStatusCompleted => 'Completed';
}
