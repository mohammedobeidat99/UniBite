import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'UniBite'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your Campus, Your Food, Your Way.'**
  String get appTagline;

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

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @suspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get suspended;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @currencyJod.
  ///
  /// In en, this message translates to:
  /// **'JOD'**
  String get currencyJod;

  /// No description provided for @roleStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get roleStudent;

  /// No description provided for @roleCafeteriaAdmin.
  ///
  /// In en, this message translates to:
  /// **'Cafeteria Admin'**
  String get roleCafeteriaAdmin;

  /// No description provided for @roleCafeteriaStaff.
  ///
  /// In en, this message translates to:
  /// **'Cafeteria Staff'**
  String get roleCafeteriaStaff;

  /// No description provided for @roleSystemAdmin.
  ///
  /// In en, this message translates to:
  /// **'System Admin'**
  String get roleSystemAdmin;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your campus account to continue.'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'University Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'name@university.edu'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @phoneOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number (Optional)'**
  String get phoneOptionalLabel;

  /// No description provided for @verificationCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Demo Verification Code (123456)'**
  String get verificationCodeLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// No description provided for @registerStudentLink.
  ///
  /// In en, this message translates to:
  /// **'New student? Create an account'**
  String get registerStudentLink;

  /// No description provided for @forgotPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordLink;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Student Registration'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the simulated verification code 123456 to verify your university email.'**
  String get registerSubtitle;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Create Student Account'**
  String get registerButton;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email, demo code 123456, and a new password.'**
  String get resetPasswordSubtitle;

  /// No description provided for @resetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordButton;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated. You can now sign in.'**
  String get passwordResetSuccess;

  /// No description provided for @sendDemoCodeInfo.
  ///
  /// In en, this message translates to:
  /// **'Demo verification code is 123456'**
  String get sendDemoCodeInfo;

  /// No description provided for @demoQuickFillTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Demo Accounts (One-Click Fill)'**
  String get demoQuickFillTitle;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get fieldRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @invalidPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid positive price.'**
  String get invalidPrice;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid positive number.'**
  String get invalidNumber;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Campus'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your university and campus branch to view nearby cafeterias.'**
  String get onboardingSubtitle;

  /// No description provided for @selectUniversityLabel.
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get selectUniversityLabel;

  /// No description provided for @selectCampusLabel.
  ///
  /// In en, this message translates to:
  /// **'Campus Branch'**
  String get selectCampusLabel;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue to Cafeterias'**
  String get continueButton;

  /// No description provided for @noCampusesForUniversity.
  ///
  /// In en, this message translates to:
  /// **'No active campuses found for this university.'**
  String get noCampusesForUniversity;

  /// No description provided for @demoBarTitle.
  ///
  /// In en, this message translates to:
  /// **'DEMO MODE'**
  String get demoBarTitle;

  /// No description provided for @switchRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Switch Role'**
  String get switchRoleLabel;

  /// No description provided for @offlineToggleLabel.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offlineToggleLabel;

  /// No description provided for @simulateOfflineTooltip.
  ///
  /// In en, this message translates to:
  /// **'Toggle simulated connection loss banner'**
  String get simulateOfflineTooltip;

  /// No description provided for @runAutoRejectNow.
  ///
  /// In en, this message translates to:
  /// **'Run Auto-Reject'**
  String get runAutoRejectNow;

  /// No description provided for @resetDemoData.
  ///
  /// In en, this message translates to:
  /// **'Reset Demo'**
  String get resetDemoData;

  /// No description provided for @resetDemoConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Demo Data?'**
  String get resetDemoConfirmTitle;

  /// No description provided for @resetDemoConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This clears local Hive storage and restores the initial GP1 seed data.'**
  String get resetDemoConfirmBody;

  /// No description provided for @demoDataResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Local storage cleared and re-seeded.'**
  String get demoDataResetSuccess;

  /// No description provided for @autoRejectCompletedCount.
  ///
  /// In en, this message translates to:
  /// **'Auto-reject checked pending orders: {count} rejected.'**
  String autoRejectCompletedCount(int count);

  /// No description provided for @connectionLostBanner.
  ///
  /// In en, this message translates to:
  /// **'Connection lost — operating in offline cache mode. Updates will sync on reconnect.'**
  String get connectionLostBanner;

  /// No description provided for @screenAwakeBadge.
  ///
  /// In en, this message translates to:
  /// **'Screen Wake Lock: ON'**
  String get screenAwakeBadge;

  /// No description provided for @navCafeterias.
  ///
  /// In en, this message translates to:
  /// **'Cafeterias'**
  String get navCafeterias;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @navCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get navCart;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @searchCafeteriasAndMealsHint.
  ///
  /// In en, this message translates to:
  /// **'Search cafeterias or meals...'**
  String get searchCafeteriasAndMealsHint;

  /// No description provided for @noCafeteriasOnCampus.
  ///
  /// In en, this message translates to:
  /// **'No active cafeterias are listed on this campus yet.'**
  String get noCafeteriasOnCampus;

  /// No description provided for @noMatchingResults.
  ///
  /// In en, this message translates to:
  /// **'No cafeterias or meals matched your search.'**
  String get noMatchingResults;

  /// No description provided for @workingHoursFormat.
  ///
  /// In en, this message translates to:
  /// **'Hours: {hours}'**
  String workingHoursFormat(String hours);

  /// No description provided for @prepTimeFormat.
  ///
  /// In en, this message translates to:
  /// **'~{minutes} min prep'**
  String prepTimeFormat(int minutes);

  /// No description provided for @menuTitle.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuTitle;

  /// No description provided for @noMealsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No meals found in this category.'**
  String get noMealsInCategory;

  /// No description provided for @mealDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal Details'**
  String get mealDetailsTitle;

  /// No description provided for @specialNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Special Instructions (Optional)'**
  String get specialNoteLabel;

  /// No description provided for @specialNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Extra garlic sauce, no pickles'**
  String get specialNoteHint;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @addToCartButton.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCartButton;

  /// No description provided for @addedToCartMessage.
  ///
  /// In en, this message translates to:
  /// **'Added {mealName} to cart.'**
  String addedToCartMessage(String mealName);

  /// No description provided for @cafeteriaClosedOrderBlocked.
  ///
  /// In en, this message translates to:
  /// **'This cafeteria is currently closed and cannot accept immediate orders.'**
  String get cafeteriaClosedOrderBlocked;

  /// No description provided for @mealUnavailableBlocked.
  ///
  /// In en, this message translates to:
  /// **'This meal is currently marked unavailable.'**
  String get mealUnavailableBlocked;

  /// No description provided for @differentCafeteriaTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a New Cart?'**
  String get differentCafeteriaTitle;

  /// No description provided for @differentCafeteriaMessage.
  ///
  /// In en, this message translates to:
  /// **'Your cart already has items from another cafeteria. Each order can only include one cafeteria. Clear current cart and add this item?'**
  String get differentCafeteriaMessage;

  /// No description provided for @clearAndAddButton.
  ///
  /// In en, this message translates to:
  /// **'Clear & Add'**
  String get clearAndAddButton;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Cart'**
  String get cartTitle;

  /// No description provided for @emptyCartTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get emptyCartTitle;

  /// No description provided for @emptyCartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse campus cafeterias and add meals to start an order.'**
  String get emptyCartSubtitle;

  /// No description provided for @clearCartButton.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart'**
  String get clearCartButton;

  /// No description provided for @itemSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Itemized Summary'**
  String get itemSubtotal;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @pickupModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup Option'**
  String get pickupModeLabel;

  /// No description provided for @orderNowOption.
  ///
  /// In en, this message translates to:
  /// **'Order Now (ASAP)'**
  String get orderNowOption;

  /// No description provided for @preOrderOption.
  ///
  /// In en, this message translates to:
  /// **'Pre-Order for Pickup Time'**
  String get preOrderOption;

  /// No description provided for @choosePickupTime.
  ///
  /// In en, this message translates to:
  /// **'Choose Pickup Time'**
  String get choosePickupTime;

  /// No description provided for @selectedPickupTime.
  ///
  /// In en, this message translates to:
  /// **'Pickup at {time}'**
  String selectedPickupTime(String time);

  /// No description provided for @pickupTimeOutsideHours.
  ///
  /// In en, this message translates to:
  /// **'Selected pickup time must be within the cafeteria working hours ({hours}).'**
  String pickupTimeOutsideHours(String hours);

  /// No description provided for @paymentMethodCashOnly.
  ///
  /// In en, this message translates to:
  /// **'Payment: Cash at Pickup Only'**
  String get paymentMethodCashOnly;

  /// No description provided for @fulfillmentSelfPickupOnly.
  ///
  /// In en, this message translates to:
  /// **'Fulfillment: Self-Pickup at Counter Only'**
  String get fulfillmentSelfPickupOnly;

  /// No description provided for @placeOrderButton.
  ///
  /// In en, this message translates to:
  /// **'Place Cash Order'**
  String get placeOrderButton;

  /// No description provided for @orderPlacedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order {orderNumber} placed! Show your QR code at pickup.'**
  String orderPlacedSuccess(String orderNumber);

  /// No description provided for @studentOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get studentOrdersTitle;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'You have not placed any orders yet.'**
  String get noOrdersYet;

  /// No description provided for @activeOrdersSection.
  ///
  /// In en, this message translates to:
  /// **'Active Orders'**
  String get activeOrdersSection;

  /// No description provided for @pastOrdersSection.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get pastOrdersSection;

  /// No description provided for @orderNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Order #{number}'**
  String orderNumberLabel(String number);

  /// No description provided for @pickupQrCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Pickup QR Code'**
  String get pickupQrCodeTitle;

  /// No description provided for @cancelOrderButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrderButton;

  /// No description provided for @cancelOrderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel this pending order before the cafeteria accepts it?'**
  String get cancelOrderConfirm;

  /// No description provided for @rejectReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String rejectReasonLabel(String reason);

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// No description provided for @statusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get statusPreparing;

  /// No description provided for @statusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready for Pickup'**
  String get statusReady;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @orderTypeApp.
  ///
  /// In en, this message translates to:
  /// **'App Order'**
  String get orderTypeApp;

  /// No description provided for @orderTypeWalkin.
  ///
  /// In en, this message translates to:
  /// **'Walk-In'**
  String get orderTypeWalkin;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings & Account'**
  String get settingsTitle;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language / اللغة'**
  String get languageLabel;

  /// No description provided for @englishLabel.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLabel;

  /// No description provided for @arabicLabel.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabicLabel;

  /// No description provided for @currentCampusLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Campus'**
  String get currentCampusLabel;

  /// No description provided for @changeCampusButton.
  ///
  /// In en, this message translates to:
  /// **'Change University / Campus'**
  String get changeCampusButton;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get logoutButton;

  /// No description provided for @tabLiveBoard.
  ///
  /// In en, this message translates to:
  /// **'Live Order Board'**
  String get tabLiveBoard;

  /// No description provided for @tabMenuManager.
  ///
  /// In en, this message translates to:
  /// **'Menu Manager'**
  String get tabMenuManager;

  /// No description provided for @tabWorkingHours.
  ///
  /// In en, this message translates to:
  /// **'Hours & Settings'**
  String get tabWorkingHours;

  /// No description provided for @tabStaffAccounts.
  ///
  /// In en, this message translates to:
  /// **'Staff Accounts'**
  String get tabStaffAccounts;

  /// No description provided for @tabOrderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get tabOrderHistory;

  /// No description provided for @tabWalkInOrder.
  ///
  /// In en, this message translates to:
  /// **'New Walk-In Order'**
  String get tabWalkInOrder;

  /// No description provided for @tabQrLookup.
  ///
  /// In en, this message translates to:
  /// **'QR / Order Lookup'**
  String get tabQrLookup;

  /// No description provided for @soundAlertOn.
  ///
  /// In en, this message translates to:
  /// **'Alert Sound: ON'**
  String get soundAlertOn;

  /// No description provided for @soundAlertMuted.
  ///
  /// In en, this message translates to:
  /// **'Alert Sound: Muted'**
  String get soundAlertMuted;

  /// No description provided for @pendingAlertBanner.
  ///
  /// In en, this message translates to:
  /// **'{count} new pending order(s) waiting for response!'**
  String pendingAlertBanner(int count);

  /// No description provided for @columnNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get columnNew;

  /// No description provided for @columnPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get columnPreparing;

  /// No description provided for @columnReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get columnReady;

  /// No description provided for @acceptOrderButton.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptOrderButton;

  /// No description provided for @rejectOrderButton.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectOrderButton;

  /// No description provided for @startPreparingButton.
  ///
  /// In en, this message translates to:
  /// **'Start Preparing'**
  String get startPreparingButton;

  /// No description provided for @markReadyButton.
  ///
  /// In en, this message translates to:
  /// **'Mark Ready'**
  String get markReadyButton;

  /// No description provided for @completePickupButton.
  ///
  /// In en, this message translates to:
  /// **'Complete Pickup'**
  String get completePickupButton;

  /// No description provided for @autoRejectInSeconds.
  ///
  /// In en, this message translates to:
  /// **'Auto-reject in {seconds}s'**
  String autoRejectInSeconds(int seconds);

  /// No description provided for @rejectOrderDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject Order'**
  String get rejectOrderDialogTitle;

  /// No description provided for @rejectReasonInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Rejection Reason'**
  String get rejectReasonInputLabel;

  /// No description provided for @rejectQuickOut.
  ///
  /// In en, this message translates to:
  /// **'Out of ingredients'**
  String get rejectQuickOut;

  /// No description provided for @rejectQuickBusy.
  ///
  /// In en, this message translates to:
  /// **'Kitchen overloaded'**
  String get rejectQuickBusy;

  /// No description provided for @rejectQuickClosing.
  ///
  /// In en, this message translates to:
  /// **'Closing soon'**
  String get rejectQuickClosing;

  /// No description provided for @walkInTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Walk-In Order'**
  String get walkInTitle;

  /// No description provided for @walkInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select available meals for an in-person customer paying cash at the counter.'**
  String get walkInSubtitle;

  /// No description provided for @createWalkInButton.
  ///
  /// In en, this message translates to:
  /// **'Create Walk-In Ticket'**
  String get createWalkInButton;

  /// No description provided for @qrLookupTitle.
  ///
  /// In en, this message translates to:
  /// **'Pickup QR & Order Number Lookup'**
  String get qrLookupTitle;

  /// No description provided for @qrLookupHint.
  ///
  /// In en, this message translates to:
  /// **'Enter order number (e.g. UB-1001) or scan QR payload'**
  String get qrLookupHint;

  /// No description provided for @lookupButton.
  ///
  /// In en, this message translates to:
  /// **'Find Order'**
  String get lookupButton;

  /// No description provided for @orderNotFound.
  ///
  /// In en, this message translates to:
  /// **'No order found matching that code in your cafeteria.'**
  String get orderNotFound;

  /// No description provided for @quickReadyOrdersLabel.
  ///
  /// In en, this message translates to:
  /// **'Quick Demo Select (Ready Orders):'**
  String get quickReadyOrdersLabel;

  /// No description provided for @addMealButton.
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get addMealButton;

  /// No description provided for @editMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Meal'**
  String get editMealTitle;

  /// No description provided for @mealNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Meal Name'**
  String get mealNameLabel;

  /// No description provided for @mealCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get mealCategoryLabel;

  /// No description provided for @mealPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price (JOD)'**
  String get mealPriceLabel;

  /// No description provided for @mealDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get mealDescriptionLabel;

  /// No description provided for @mealPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Meal Photo'**
  String get mealPhotoLabel;

  /// No description provided for @pickImageButton.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get pickImageButton;

  /// No description provided for @orChoosePreset.
  ///
  /// In en, this message translates to:
  /// **'Or select a bundled sample icon:'**
  String get orChoosePreset;

  /// No description provided for @workingHoursTitle.
  ///
  /// In en, this message translates to:
  /// **'Cafeteria Operating Hours & Timeouts'**
  String get workingHoursTitle;

  /// No description provided for @openingTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Opening Time'**
  String get openingTimeLabel;

  /// No description provided for @closingTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Closing Time'**
  String get closingTimeLabel;

  /// No description provided for @prepMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Prep Time (Minutes)'**
  String get prepMinutesLabel;

  /// No description provided for @timeoutSecondsLabel.
  ///
  /// In en, this message translates to:
  /// **'Auto-Reject Timeout (Seconds)'**
  String get timeoutSecondsLabel;

  /// No description provided for @saveSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Save Cafeteria Settings'**
  String get saveSettingsButton;

  /// No description provided for @settingsSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Cafeteria settings updated.'**
  String get settingsSavedMessage;

  /// No description provided for @staffAccountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Cafeteria Staff Accounts'**
  String get staffAccountsTitle;

  /// No description provided for @addStaffButton.
  ///
  /// In en, this message translates to:
  /// **'Add Staff Account'**
  String get addStaffButton;

  /// No description provided for @staffPermissionNote.
  ///
  /// In en, this message translates to:
  /// **'Staff accounts can manage live orders, walk-in orders, and QR pickups, but cannot edit menu items, prices, hours, or staff.'**
  String get staffPermissionNote;

  /// No description provided for @noStaffYet.
  ///
  /// In en, this message translates to:
  /// **'No staff accounts created for this cafeteria yet.'**
  String get noStaffYet;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No historical orders yet.'**
  String get noHistoryYet;

  /// No description provided for @tabUniversities.
  ///
  /// In en, this message translates to:
  /// **'Universities'**
  String get tabUniversities;

  /// No description provided for @tabCampuses.
  ///
  /// In en, this message translates to:
  /// **'Campuses'**
  String get tabCampuses;

  /// No description provided for @tabCafeterias.
  ///
  /// In en, this message translates to:
  /// **'Cafeterias & Owners'**
  String get tabCafeterias;

  /// No description provided for @tabUsers.
  ///
  /// In en, this message translates to:
  /// **'All Users'**
  String get tabUsers;

  /// No description provided for @addUniversityButton.
  ///
  /// In en, this message translates to:
  /// **'Add University'**
  String get addUniversityButton;

  /// No description provided for @universityNameLabel.
  ///
  /// In en, this message translates to:
  /// **'University Name'**
  String get universityNameLabel;

  /// No description provided for @addCampusButton.
  ///
  /// In en, this message translates to:
  /// **'Add Campus Branch'**
  String get addCampusButton;

  /// No description provided for @campusNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Campus Name'**
  String get campusNameLabel;

  /// No description provided for @campusLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Campus Location'**
  String get campusLocationLabel;

  /// No description provided for @addCafeteriaButton.
  ///
  /// In en, this message translates to:
  /// **'Create Cafeteria & Owner'**
  String get addCafeteriaButton;

  /// No description provided for @cafeteriaNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Cafeteria Name'**
  String get cafeteriaNameLabel;

  /// No description provided for @ownerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Owner (Cafeteria Admin) Name'**
  String get ownerNameLabel;

  /// No description provided for @ownerEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Owner Login Email'**
  String get ownerEmailLabel;

  /// No description provided for @ownerPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Owner Initial Password'**
  String get ownerPasswordLabel;

  /// No description provided for @filterByUniversity.
  ///
  /// In en, this message translates to:
  /// **'Filter by University'**
  String get filterByUniversity;

  /// No description provided for @filterByRole.
  ///
  /// In en, this message translates to:
  /// **'Filter by Role'**
  String get filterByRole;

  /// No description provided for @allRoles.
  ///
  /// In en, this message translates to:
  /// **'All Roles'**
  String get allRoles;

  /// No description provided for @categorySandwiches.
  ///
  /// In en, this message translates to:
  /// **'Sandwiches'**
  String get categorySandwiches;

  /// No description provided for @categoryHotMeals.
  ///
  /// In en, this message translates to:
  /// **'Hot Meals'**
  String get categoryHotMeals;

  /// No description provided for @categorySalads.
  ///
  /// In en, this message translates to:
  /// **'Salads'**
  String get categorySalads;

  /// No description provided for @categoryBeverages.
  ///
  /// In en, this message translates to:
  /// **'Beverages'**
  String get categoryBeverages;

  /// No description provided for @categoryDesserts.
  ///
  /// In en, this message translates to:
  /// **'Desserts'**
  String get categoryDesserts;

  /// No description provided for @loginHeroHeadline.
  ///
  /// In en, this message translates to:
  /// **'Hungry between lectures?'**
  String get loginHeroHeadline;

  /// No description provided for @loginHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Order fresh from campus & skip the queue.'**
  String get loginHeroSubtitle;

  /// No description provided for @introSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Skip the queue'**
  String get introSlide1Title;

  /// No description provided for @introSlide1Body.
  ///
  /// In en, this message translates to:
  /// **'Order ahead and grab your meal right when break starts.'**
  String get introSlide1Body;

  /// No description provided for @introSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Order before your break'**
  String get introSlide2Title;

  /// No description provided for @introSlide2Body.
  ///
  /// In en, this message translates to:
  /// **'Pick now or schedule an exact pickup slot between classes.'**
  String get introSlide2Body;

  /// No description provided for @introSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Pick up and go'**
  String get introSlide3Title;

  /// No description provided for @introSlide3Body.
  ///
  /// In en, this message translates to:
  /// **'Flash your QR ticket and pay cash at the counter.'**
  String get introSlide3Body;

  /// No description provided for @skipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipButton;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @getStartedButton.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStartedButton;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Ready for a bite?'**
  String get homeGreeting;

  /// No description provided for @openNowSection.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get openNowSection;

  /// No description provided for @allCafeteriasSection.
  ///
  /// In en, this message translates to:
  /// **'All cafeterias'**
  String get allCafeteriasSection;

  /// No description provided for @searchUniversitiesHint.
  ///
  /// In en, this message translates to:
  /// **'Search universities...'**
  String get searchUniversitiesHint;

  /// No description provided for @stepAccount.
  ///
  /// In en, this message translates to:
  /// **'1. Account'**
  String get stepAccount;

  /// No description provided for @stepCampus.
  ///
  /// In en, this message translates to:
  /// **'2. Campus'**
  String get stepCampus;

  /// No description provided for @passwordStrengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passwordStrengthWeak;

  /// No description provided for @passwordStrengthGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get passwordStrengthGood;

  /// No description provided for @passwordStrengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordStrengthStrong;

  /// No description provided for @removedItemUndo.
  ///
  /// In en, this message translates to:
  /// **'Removed {item}'**
  String removedItemUndo(String item);

  /// No description provided for @undoAction.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoAction;

  /// No description provided for @statusPlainPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for kitchen confirmation'**
  String get statusPlainPending;

  /// No description provided for @statusPlainAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted — queued next'**
  String get statusPlainAccepted;

  /// No description provided for @statusPlainPreparing.
  ///
  /// In en, this message translates to:
  /// **'Being prepared fresh'**
  String get statusPlainPreparing;

  /// No description provided for @statusPlainReady.
  ///
  /// In en, this message translates to:
  /// **'Ready — show your QR at counter'**
  String get statusPlainReady;

  /// No description provided for @statusPlainCompleted.
  ///
  /// In en, this message translates to:
  /// **'Picked up & paid in cash'**
  String get statusPlainCompleted;

  /// No description provided for @statusPlainRejected.
  ///
  /// In en, this message translates to:
  /// **'Declined by cafeteria'**
  String get statusPlainRejected;

  /// No description provided for @statusPlainCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled before acceptance'**
  String get statusPlainCancelled;

  /// No description provided for @componentGalleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Component Gallery'**
  String get componentGalleryTitle;

  /// No description provided for @colorSystemLabel.
  ///
  /// In en, this message translates to:
  /// **'70 / 20 / 10 Color System'**
  String get colorSystemLabel;

  /// No description provided for @buttonsAndControlsLabel.
  ///
  /// In en, this message translates to:
  /// **'Buttons, Pills & Steppers'**
  String get buttonsAndControlsLabel;

  /// No description provided for @orderStepperGalleryLabel.
  ///
  /// In en, this message translates to:
  /// **'Animated Order Stepper'**
  String get orderStepperGalleryLabel;

  /// No description provided for @foodIllustrationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Vector Food Artwork'**
  String get foodIllustrationsLabel;

  /// No description provided for @liveConnectedBadge.
  ///
  /// In en, this message translates to:
  /// **'Live Connected'**
  String get liveConnectedBadge;

  /// No description provided for @elapsedMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String elapsedMinutesLabel(int minutes);

  /// No description provided for @registerTermsLine.
  ///
  /// In en, this message translates to:
  /// **'By creating an account you agree to campus cash-at-pickup terms.'**
  String get registerTermsLine;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
