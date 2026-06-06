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
  String get productDetailTitle => 'Product';

  @override
  String get productDescriptionTitle => 'Description';

  @override
  String get productAddToBag => 'Add to Bag';

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
