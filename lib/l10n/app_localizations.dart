import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'SHOO'**
  String get appName;

  /// No description provided for @tabShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get tabShop;

  /// No description provided for @tabCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get tabCategory;

  /// No description provided for @tabBag.
  ///
  /// In en, this message translates to:
  /// **'Bag'**
  String get tabBag;

  /// No description provided for @tabMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get tabMe;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search styles, trends...'**
  String get searchHint;

  /// No description provided for @recommendedTitle.
  ///
  /// In en, this message translates to:
  /// **'RECOMMENDED FOR YOU'**
  String get recommendedTitle;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your bag is empty'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add items to get started.'**
  String get cartEmptySubtitle;

  /// No description provided for @cartEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Start Shopping'**
  String get cartEmptyAction;

  /// No description provided for @profileSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in / Register'**
  String get profileSignIn;

  /// No description provided for @profileSignInHint.
  ///
  /// In en, this message translates to:
  /// **'Enjoy exclusive deals & faster checkout'**
  String get profileSignInHint;

  /// No description provided for @profileOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get profileOrders;

  /// No description provided for @profileServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get profileServices;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsLanguageZh.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get settingsLanguageZh;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginTitle;

  /// No description provided for @loginPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get loginPhoneHint;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordHint;

  /// No description provided for @loginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginSubmit;

  /// No description provided for @loginMockHint.
  ///
  /// In en, this message translates to:
  /// **'Mock login — any phone/password works'**
  String get loginMockHint;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noData;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load. Please retry.'**
  String get loadFailed;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String welcomeUser(String name);

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'{appName} v{version} — Phase 2'**
  String versionLabel(String appName, String version);

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// No description provided for @validationPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get validationPhone;

  /// No description provided for @validationEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get validationEmail;

  /// No description provided for @validationMinLength.
  ///
  /// In en, this message translates to:
  /// **'At least {length} characters'**
  String validationMinLength(int length);

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Some features may be unavailable.'**
  String get offlineBanner;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Fashion for everyone'**
  String get splashTagline;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Trending Styles'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Discover the latest looks curated for you.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Fast Delivery'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Track orders and enjoy quick shipping.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Exclusive Deals'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Save more with coupons and flash sales.'**
  String get onboardingDesc3;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingStart;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get registerConfirmPassword;

  /// No description provided for @registerSubmit.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerSubmit;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account? Register'**
  String get loginNoAccount;

  /// No description provided for @registerHasAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get registerHasAccount;

  /// No description provided for @registerPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get registerPasswordMismatch;

  /// No description provided for @registerMockHint.
  ///
  /// In en, this message translates to:
  /// **'Mock register — creates a local session'**
  String get registerMockHint;

  /// No description provided for @messageTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messageTitle;

  /// No description provided for @messageEmpty.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get messageEmpty;

  /// No description provided for @profileMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get profileMessages;

  /// No description provided for @profileShareDemo.
  ///
  /// In en, this message translates to:
  /// **'Share Demo'**
  String get profileShareDemo;

  /// No description provided for @profileCameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Camera Permission'**
  String get profileCameraPermission;

  /// No description provided for @debugPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Debug Panel'**
  String get debugPanelTitle;

  /// No description provided for @debugPanelHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the top app bar 5 times quickly to open. Disabled in release builds.'**
  String get debugPanelHint;

  /// No description provided for @debugEnvSection.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get debugEnvSection;

  /// No description provided for @debugResetEnv.
  ///
  /// In en, this message translates to:
  /// **'Reset to build default'**
  String get debugResetEnv;

  /// No description provided for @debugClearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear local cache'**
  String get debugClearCache;

  /// No description provided for @debugCacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get debugCacheCleared;

  /// No description provided for @sharePanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get sharePanelTitle;

  /// No description provided for @shareSystem.
  ///
  /// In en, this message translates to:
  /// **'Share via system'**
  String get shareSystem;

  /// No description provided for @shareCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get shareCopyLink;

  /// No description provided for @shareWechat.
  ///
  /// In en, this message translates to:
  /// **'WeChat'**
  String get shareWechat;

  /// No description provided for @shareWechatMock.
  ///
  /// In en, this message translates to:
  /// **'WeChat share (mock)'**
  String get shareWechatMock;

  /// No description provided for @shareMore.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get shareMore;

  /// No description provided for @updateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateTitle;

  /// No description provided for @updateNewVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version} is available'**
  String updateNewVersion(String version);

  /// No description provided for @updateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLater;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// No description provided for @debugToolsSection.
  ///
  /// In en, this message translates to:
  /// **'Debug Tools'**
  String get debugToolsSection;

  /// No description provided for @debugUpdateEntry.
  ///
  /// In en, this message translates to:
  /// **'Update Popup'**
  String get debugUpdateEntry;

  /// No description provided for @debugUpdateEntryHint.
  ///
  /// In en, this message translates to:
  /// **'Configure version, notes, force update'**
  String get debugUpdateEntryHint;

  /// No description provided for @debugActivityEntry.
  ///
  /// In en, this message translates to:
  /// **'Activity Popup'**
  String get debugActivityEntry;

  /// No description provided for @debugActivityEntryHint.
  ///
  /// In en, this message translates to:
  /// **'Configure ad delay, schedule, prefetch'**
  String get debugActivityEntryHint;

  /// No description provided for @debugUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Debug'**
  String get debugUpdateTitle;

  /// No description provided for @debugActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity Debug'**
  String get debugActivityTitle;

  /// No description provided for @debugOverrideEnabled.
  ///
  /// In en, this message translates to:
  /// **'Use debug override'**
  String get debugOverrideEnabled;

  /// No description provided for @debugOverrideHint.
  ///
  /// In en, this message translates to:
  /// **'Enable override to preview'**
  String get debugOverrideHint;

  /// No description provided for @debugUpdateOverrideHint.
  ///
  /// In en, this message translates to:
  /// **'When off, home uses normal API version check'**
  String get debugUpdateOverrideHint;

  /// No description provided for @debugActivityOverrideHint.
  ///
  /// In en, this message translates to:
  /// **'When off, home uses normal API activity fetch'**
  String get debugActivityOverrideHint;

  /// No description provided for @debugFlowNormal.
  ///
  /// In en, this message translates to:
  /// **'Active: normal API flow'**
  String get debugFlowNormal;

  /// No description provided for @debugFlowOverride.
  ///
  /// In en, this message translates to:
  /// **'Active: debug override'**
  String get debugFlowOverride;

  /// No description provided for @debugOverrideActiveNow.
  ///
  /// In en, this message translates to:
  /// **'Debug override enabled — home will use this config'**
  String get debugOverrideActiveNow;

  /// No description provided for @debugOverrideInactiveNow.
  ///
  /// In en, this message translates to:
  /// **'Debug override disabled — home uses normal API flow'**
  String get debugOverrideInactiveNow;

  /// No description provided for @debugUpdateVersion.
  ///
  /// In en, this message translates to:
  /// **'Latest version'**
  String get debugUpdateVersion;

  /// No description provided for @debugUpdateNotes.
  ///
  /// In en, this message translates to:
  /// **'Release notes'**
  String get debugUpdateNotes;

  /// No description provided for @debugUpdateForce.
  ///
  /// In en, this message translates to:
  /// **'Force update'**
  String get debugUpdateForce;

  /// No description provided for @debugUpdateUrl.
  ///
  /// In en, this message translates to:
  /// **'Update URL'**
  String get debugUpdateUrl;

  /// No description provided for @debugActivityDelay.
  ///
  /// In en, this message translates to:
  /// **'Delay before popup (seconds)'**
  String get debugActivityDelay;

  /// No description provided for @debugActivityPopupTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity title'**
  String get debugActivityPopupTitle;

  /// No description provided for @debugActivityDescription.
  ///
  /// In en, this message translates to:
  /// **'Activity description'**
  String get debugActivityDescription;

  /// No description provided for @debugActivityDescScrollHint.
  ///
  /// In en, this message translates to:
  /// **'Scrollable in popup when over 5 lines'**
  String get debugActivityDescScrollHint;

  /// No description provided for @debugActivityImageUrl.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get debugActivityImageUrl;

  /// No description provided for @debugActivityId.
  ///
  /// In en, this message translates to:
  /// **'Activity ID'**
  String get debugActivityId;

  /// No description provided for @debugActivityLink.
  ///
  /// In en, this message translates to:
  /// **'Deep link'**
  String get debugActivityLink;

  /// No description provided for @debugActivityButton.
  ///
  /// In en, this message translates to:
  /// **'Button text'**
  String get debugActivityButton;

  /// No description provided for @debugActivityStartAt.
  ///
  /// In en, this message translates to:
  /// **'Start date/time'**
  String get debugActivityStartAt;

  /// No description provided for @debugActivityEndAt.
  ///
  /// In en, this message translates to:
  /// **'End date/time'**
  String get debugActivityEndAt;

  /// No description provided for @debugActivityDateUnset.
  ///
  /// In en, this message translates to:
  /// **'Not set — always eligible'**
  String get debugActivityDateUnset;

  /// No description provided for @debugActivityPrefetch.
  ///
  /// In en, this message translates to:
  /// **'Prefetch config & image'**
  String get debugActivityPrefetch;

  /// No description provided for @debugActivityPrefetchHint.
  ///
  /// In en, this message translates to:
  /// **'Download image and cache config locally in advance'**
  String get debugActivityPrefetchHint;

  /// No description provided for @debugActivityMaxDaily.
  ///
  /// In en, this message translates to:
  /// **'Max shows per day'**
  String get debugActivityMaxDaily;

  /// No description provided for @debugSaveConfig.
  ///
  /// In en, this message translates to:
  /// **'Save config'**
  String get debugSaveConfig;

  /// No description provided for @debugPreviewPopup.
  ///
  /// In en, this message translates to:
  /// **'Preview popup'**
  String get debugPreviewPopup;

  /// No description provided for @debugPreviewNoUpdate.
  ///
  /// In en, this message translates to:
  /// **'No update available in current flow'**
  String get debugPreviewNoUpdate;

  /// No description provided for @debugPreviewNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity available in current flow'**
  String get debugPreviewNoActivity;

  /// No description provided for @debugConfigSaved.
  ///
  /// In en, this message translates to:
  /// **'Debug config saved'**
  String get debugConfigSaved;

  /// No description provided for @searchHotTitle.
  ///
  /// In en, this message translates to:
  /// **'Trending searches'**
  String get searchHotTitle;

  /// No description provided for @productDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get productDetailTitle;

  /// No description provided for @productDescriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get productDescriptionTitle;

  /// No description provided for @productAddToBag.
  ///
  /// In en, this message translates to:
  /// **'Add to Bag'**
  String get productAddToBag;

  /// No description provided for @productAddToBagHint.
  ///
  /// In en, this message translates to:
  /// **'Added to bag (mock)'**
  String get productAddToBagHint;

  /// No description provided for @reviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsTitle;

  /// No description provided for @reviewsViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get reviewsViewAll;

  /// No description provided for @reviewsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get reviewsEmpty;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get ordersTitle;

  /// No description provided for @ordersAll.
  ///
  /// In en, this message translates to:
  /// **'All Orders'**
  String get ordersAll;

  /// No description provided for @ordersPendingPayment.
  ///
  /// In en, this message translates to:
  /// **'Pending Payment'**
  String get ordersPendingPayment;

  /// No description provided for @ordersShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get ordersShipped;

  /// No description provided for @ordersReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get ordersReviews;

  /// No description provided for @orderMoreItems.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String orderMoreItems(int count);

  /// No description provided for @orderDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Detail'**
  String get orderDetailTitle;

  /// No description provided for @orderNoLabel.
  ///
  /// In en, this message translates to:
  /// **'Order No.'**
  String get orderNoLabel;

  /// No description provided for @orderStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get orderStatusLabel;

  /// No description provided for @orderCreatedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Placed at'**
  String get orderCreatedAtLabel;

  /// No description provided for @orderShippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Shipping address'**
  String get orderShippingAddress;

  /// No description provided for @orderItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get orderItemsTitle;

  /// No description provided for @orderTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get orderTotalLabel;

  /// No description provided for @orderStatusPendingPayment.
  ///
  /// In en, this message translates to:
  /// **'Pending payment'**
  String get orderStatusPendingPayment;

  /// No description provided for @orderStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get orderStatusPaid;

  /// No description provided for @orderStatusShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get orderStatusShipped;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// No description provided for @logisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Track Package'**
  String get logisticsTitle;

  /// No description provided for @logisticsCarrierLabel.
  ///
  /// In en, this message translates to:
  /// **'Carrier'**
  String get logisticsCarrierLabel;

  /// No description provided for @logisticsTrackingNoLabel.
  ///
  /// In en, this message translates to:
  /// **'Tracking number'**
  String get logisticsTrackingNoLabel;

  /// No description provided for @logisticsTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipment timeline'**
  String get logisticsTimelineTitle;

  /// No description provided for @logisticsTrackAction.
  ///
  /// In en, this message translates to:
  /// **'Track shipment'**
  String get logisticsTrackAction;

  /// No description provided for @logisticsCopied.
  ///
  /// In en, this message translates to:
  /// **'Tracking number copied'**
  String get logisticsCopied;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
