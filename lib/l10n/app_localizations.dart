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

  /// No description provided for @settingsGroupGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGroupGeneral;

  /// No description provided for @settingsGroupAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsGroupAccount;

  /// No description provided for @settingsGroupAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsGroupAbout;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get settingsAbout;

  /// No description provided for @settingsAboutDescription.
  ///
  /// In en, this message translates to:
  /// **'SHOO is a fashion e-commerce app for young shoppers — curated trends, fast checkout, and reliable after-sales support.'**
  String get settingsAboutDescription;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTermsOfService;

  /// No description provided for @settingsCompanyName.
  ///
  /// In en, this message translates to:
  /// **'SHOO COMMERCE TECHNOLOGY PTE. LTD.'**
  String get settingsCompanyName;

  /// No description provided for @ordersAllShort.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get ordersAllShort;

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
  /// **'{appName} v{version} — Phase 3'**
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

  /// No description provided for @shareProductCard.
  ///
  /// In en, this message translates to:
  /// **'Share product card'**
  String get shareProductCard;

  /// No description provided for @shareLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get shareLinkCopied;

  /// No description provided for @imagePickerGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get imagePickerGallery;

  /// No description provided for @imagePickerCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get imagePickerCamera;

  /// No description provided for @imagePickerHint.
  ///
  /// In en, this message translates to:
  /// **'Up to {count} photos'**
  String imagePickerHint(int count);

  /// No description provided for @afterSaleEvidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Upload evidence photos'**
  String get afterSaleEvidenceLabel;

  /// No description provided for @reviewSubmitTitle.
  ///
  /// In en, this message translates to:
  /// **'Write a review'**
  String get reviewSubmitTitle;

  /// No description provided for @reviewSubmitContentLabel.
  ///
  /// In en, this message translates to:
  /// **'Your review'**
  String get reviewSubmitContentLabel;

  /// No description provided for @reviewSubmitContentHint.
  ///
  /// In en, this message translates to:
  /// **'Share your experience with this product'**
  String get reviewSubmitContentHint;

  /// No description provided for @reviewSubmitPhotosLabel.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get reviewSubmitPhotosLabel;

  /// No description provided for @reviewSubmitAction.
  ///
  /// In en, this message translates to:
  /// **'Submit review'**
  String get reviewSubmitAction;

  /// No description provided for @reviewSubmitContentRequired.
  ///
  /// In en, this message translates to:
  /// **'Please write your review'**
  String get reviewSubmitContentRequired;

  /// No description provided for @reviewSubmitSuccess.
  ///
  /// In en, this message translates to:
  /// **'Review submitted with {count} photo(s)'**
  String reviewSubmitSuccess(int count);

  /// No description provided for @logisticsLiveUpdates.
  ///
  /// In en, this message translates to:
  /// **'Live updates from native push'**
  String get logisticsLiveUpdates;

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

  /// No description provided for @updateDownloadProgress.
  ///
  /// In en, this message translates to:
  /// **'Downloading update... {percent}%'**
  String updateDownloadProgress(int percent);

  /// No description provided for @notFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get notFoundTitle;

  /// No description provided for @notFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'The page you are looking for does not exist.'**
  String get notFoundMessage;

  /// No description provided for @notFoundLocation.
  ///
  /// In en, this message translates to:
  /// **'Unknown route: {location}'**
  String notFoundLocation(String location);

  /// No description provided for @notFoundGoHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get notFoundGoHome;

  /// No description provided for @dialogClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get dialogClose;

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

  /// No description provided for @debugNativeEntry.
  ///
  /// In en, this message translates to:
  /// **'Native Bridge'**
  String get debugNativeEntry;

  /// No description provided for @debugNativeEntryHint.
  ///
  /// In en, this message translates to:
  /// **'Test MethodChannel, EventChannel, MessageChannel'**
  String get debugNativeEntryHint;

  /// No description provided for @debugNativeHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Native Bridge Debug'**
  String get debugNativeHubTitle;

  /// No description provided for @debugNativeHubHint.
  ///
  /// In en, this message translates to:
  /// **'Tap an example to invoke native code and inspect the response.'**
  String get debugNativeHubHint;

  /// No description provided for @debugNativeCategoryMethod.
  ///
  /// In en, this message translates to:
  /// **'MethodChannel — one-shot calls'**
  String get debugNativeCategoryMethod;

  /// No description provided for @debugNativeCategoryMessage.
  ///
  /// In en, this message translates to:
  /// **'BasicMessageChannel — bidirectional'**
  String get debugNativeCategoryMessage;

  /// No description provided for @debugNativeCategoryEvent.
  ///
  /// In en, this message translates to:
  /// **'EventChannel — continuous stream'**
  String get debugNativeCategoryEvent;

  /// No description provided for @debugNativeExamplePingTitle.
  ///
  /// In en, this message translates to:
  /// **'Ping'**
  String get debugNativeExamplePingTitle;

  /// No description provided for @debugNativeExamplePingDesc.
  ///
  /// In en, this message translates to:
  /// **'Call native `ping` and verify connectivity.'**
  String get debugNativeExamplePingDesc;

  /// No description provided for @debugNativeExampleVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'Platform version'**
  String get debugNativeExampleVersionTitle;

  /// No description provided for @debugNativeExampleVersionDesc.
  ///
  /// In en, this message translates to:
  /// **'Read OS version string from native side.'**
  String get debugNativeExampleVersionDesc;

  /// No description provided for @debugNativeExampleMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Message echo'**
  String get debugNativeExampleMessageTitle;

  /// No description provided for @debugNativeExampleMessageDesc.
  ///
  /// In en, this message translates to:
  /// **'Send a map via BasicMessageChannel and get echo reply.'**
  String get debugNativeExampleMessageDesc;

  /// No description provided for @debugNativeExampleEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Tick stream'**
  String get debugNativeExampleEventTitle;

  /// No description provided for @debugNativeExampleEventDesc.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to native EventChannel; receive tick every second.'**
  String get debugNativeExampleEventDesc;

  /// No description provided for @debugNativeRun.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get debugNativeRun;

  /// No description provided for @debugNativeStartStream.
  ///
  /// In en, this message translates to:
  /// **'Start stream'**
  String get debugNativeStartStream;

  /// No description provided for @debugNativeStopStream.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get debugNativeStopStream;

  /// No description provided for @debugNativeResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get debugNativeResult;

  /// No description provided for @debugNativeStreamLog.
  ///
  /// In en, this message translates to:
  /// **'Stream log'**
  String get debugNativeStreamLog;

  /// No description provided for @debugNativeWaiting.
  ///
  /// In en, this message translates to:
  /// **'Running…'**
  String get debugNativeWaiting;

  /// No description provided for @debugNativeNoResult.
  ///
  /// In en, this message translates to:
  /// **'Tap Run to invoke native code'**
  String get debugNativeNoResult;

  /// No description provided for @debugNativeStreamIdle.
  ///
  /// In en, this message translates to:
  /// **'Tap Start stream to listen'**
  String get debugNativeStreamIdle;

  /// No description provided for @debugNativeInputHint.
  ///
  /// In en, this message translates to:
  /// **'Message payload'**
  String get debugNativeInputHint;

  /// No description provided for @debugNativeCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get debugNativeCopy;

  /// No description provided for @debugNativeCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get debugNativeCopied;

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

  /// No description provided for @searchHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get searchHistoryTitle;

  /// No description provided for @searchHistoryClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get searchHistoryClear;

  /// No description provided for @searchHistoryCleared.
  ///
  /// In en, this message translates to:
  /// **'Search history cleared'**
  String get searchHistoryCleared;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get searchNoResults;

  /// No description provided for @pagedListNoMore.
  ///
  /// In en, this message translates to:
  /// **'No more items'**
  String get pagedListNoMore;

  /// No description provided for @reviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String reviewsCount(int count);

  /// No description provided for @cartIssuesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'{count} item(s) are no longer available'**
  String cartIssuesUnavailable(int count);

  /// No description provided for @cartIssuesPriceChanged.
  ///
  /// In en, this message translates to:
  /// **'{count} item price(s) updated'**
  String cartIssuesPriceChanged(int count);

  /// No description provided for @cartIssuesBoth.
  ///
  /// In en, this message translates to:
  /// **'{unavailable} unavailable, {changed} price updated'**
  String cartIssuesBoth(int unavailable, int changed);

  /// No description provided for @cartUnavailableBanner.
  ///
  /// In en, this message translates to:
  /// **'Some items are unavailable. Remove them to checkout.'**
  String get cartUnavailableBanner;

  /// No description provided for @cartRemoveUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Remove unavailable'**
  String get cartRemoveUnavailable;

  /// No description provided for @cartItemUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get cartItemUnavailable;

  /// No description provided for @cartItemPriceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Price updated'**
  String get cartItemPriceUpdated;

  /// No description provided for @paymentPollingStatus.
  ///
  /// In en, this message translates to:
  /// **'Confirming payment status...'**
  String get paymentPollingStatus;

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

  /// No description provided for @productBuyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get productBuyNow;

  /// No description provided for @productCustomerService.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get productCustomerService;

  /// No description provided for @productCartShort.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get productCartShort;

  /// No description provided for @productMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get productMore;

  /// No description provided for @productCustomerServiceHint.
  ///
  /// In en, this message translates to:
  /// **'Customer support coming soon (mock)'**
  String get productCustomerServiceHint;

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

  /// No description provided for @ordersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No orders in this category'**
  String get ordersEmpty;

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

  /// No description provided for @productAddToBagSuccess.
  ///
  /// In en, this message translates to:
  /// **'Added to your bag'**
  String get productAddToBagSuccess;

  /// No description provided for @skuSelectSize.
  ///
  /// In en, this message translates to:
  /// **'Select size'**
  String get skuSelectSize;

  /// No description provided for @skuSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get skuSizeLabel;

  /// No description provided for @skuQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get skuQuantity;

  /// No description provided for @cartSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get cartSelectAll;

  /// No description provided for @cartTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get cartTotalLabel;

  /// No description provided for @cartCheckout.
  ///
  /// In en, this message translates to:
  /// **'Checkout ({count})'**
  String cartCheckout(int count);

  /// No description provided for @cartRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove item?'**
  String get cartRemoveTitle;

  /// No description provided for @cartRemoveMessage.
  ///
  /// In en, this message translates to:
  /// **'This item will be removed from your bag.'**
  String get cartRemoveMessage;

  /// No description provided for @cartRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get cartRemoveConfirm;

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @checkoutAddressSection.
  ///
  /// In en, this message translates to:
  /// **'Shipping address'**
  String get checkoutAddressSection;

  /// No description provided for @checkoutAddAddress.
  ///
  /// In en, this message translates to:
  /// **'Tap to select an address'**
  String get checkoutAddAddress;

  /// No description provided for @checkoutNoAddress.
  ///
  /// In en, this message translates to:
  /// **'Please select a shipping address'**
  String get checkoutNoAddress;

  /// No description provided for @checkoutPlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get checkoutPlaceOrder;

  /// No description provided for @paymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentTitle;

  /// No description provided for @paymentMockTitle.
  ///
  /// In en, this message translates to:
  /// **'Mock Checkout'**
  String get paymentMockTitle;

  /// No description provided for @paymentMockHint.
  ///
  /// In en, this message translates to:
  /// **'This is a simulated payment. No real charge will be made.'**
  String get paymentMockHint;

  /// No description provided for @paymentPayNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get paymentPayNow;

  /// No description provided for @paymentSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get paymentSuccessTitle;

  /// No description provided for @paymentSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your order has been placed. Thank you for shopping!'**
  String get paymentSuccessMessage;

  /// No description provided for @paymentViewOrder.
  ///
  /// In en, this message translates to:
  /// **'View Order'**
  String get paymentViewOrder;

  /// No description provided for @paymentContinueShopping.
  ///
  /// In en, this message translates to:
  /// **'Continue Shopping'**
  String get paymentContinueShopping;

  /// No description provided for @addressListTitle.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addressListTitle;

  /// No description provided for @addressSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Address'**
  String get addressSelectTitle;

  /// No description provided for @profileAddresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get profileAddresses;

  /// No description provided for @profileCoupons.
  ///
  /// In en, this message translates to:
  /// **'Coupons'**
  String get profileCoupons;

  /// No description provided for @profileAfterSales.
  ///
  /// In en, this message translates to:
  /// **'After-Sales'**
  String get profileAfterSales;

  /// No description provided for @checkoutCouponSection.
  ///
  /// In en, this message translates to:
  /// **'Coupon'**
  String get checkoutCouponSection;

  /// No description provided for @couponSelectHint.
  ///
  /// In en, this message translates to:
  /// **'Select a coupon'**
  String get couponSelectHint;

  /// No description provided for @couponListTitle.
  ///
  /// In en, this message translates to:
  /// **'My Coupons'**
  String get couponListTitle;

  /// No description provided for @couponSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Coupon'**
  String get couponSelectTitle;

  /// No description provided for @couponNone.
  ///
  /// In en, this message translates to:
  /// **'No coupon'**
  String get couponNone;

  /// No description provided for @couponMinOrder.
  ///
  /// In en, this message translates to:
  /// **'Min. order {amount}'**
  String couponMinOrder(String amount);

  /// No description provided for @couponNotEligible.
  ///
  /// In en, this message translates to:
  /// **'Does not meet minimum order'**
  String get couponNotEligible;

  /// No description provided for @priceSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get priceSubtotal;

  /// No description provided for @priceDiscount.
  ///
  /// In en, this message translates to:
  /// **'Coupon discount'**
  String get priceDiscount;

  /// No description provided for @priceShipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get priceShipping;

  /// No description provided for @afterSaleListTitle.
  ///
  /// In en, this message translates to:
  /// **'After-Sales'**
  String get afterSaleListTitle;

  /// No description provided for @afterSaleApplyTitle.
  ///
  /// In en, this message translates to:
  /// **'Apply for After-Sales'**
  String get afterSaleApplyTitle;

  /// No description provided for @afterSaleApplyAction.
  ///
  /// In en, this message translates to:
  /// **'Apply for After-Sales'**
  String get afterSaleApplyAction;

  /// No description provided for @afterSaleTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Request type'**
  String get afterSaleTypeLabel;

  /// No description provided for @afterSaleTypeRefund.
  ///
  /// In en, this message translates to:
  /// **'Refund only'**
  String get afterSaleTypeRefund;

  /// No description provided for @afterSaleTypeReturnRefund.
  ///
  /// In en, this message translates to:
  /// **'Return & refund'**
  String get afterSaleTypeReturnRefund;

  /// No description provided for @afterSaleReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get afterSaleReasonLabel;

  /// No description provided for @afterSaleReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue...'**
  String get afterSaleReasonHint;

  /// No description provided for @afterSaleReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a reason'**
  String get afterSaleReasonRequired;

  /// No description provided for @afterSaleSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get afterSaleSubmit;

  /// No description provided for @afterSaleSubmitSuccess.
  ///
  /// In en, this message translates to:
  /// **'After-sales request submitted'**
  String get afterSaleSubmitSuccess;

  /// No description provided for @afterSaleGoOrders.
  ///
  /// In en, this message translates to:
  /// **'View Orders'**
  String get afterSaleGoOrders;

  /// No description provided for @afterSaleStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get afterSaleStatusPending;

  /// No description provided for @afterSaleStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get afterSaleStatusApproved;

  /// No description provided for @afterSaleStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get afterSaleStatusRejected;

  /// No description provided for @afterSaleStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get afterSaleStatusCompleted;
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
