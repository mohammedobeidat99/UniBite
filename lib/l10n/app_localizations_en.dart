// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'UniBite';

  @override
  String get appTagline => 'Your Campus, Your Food, Your Way.';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get search => 'Search';

  @override
  String get all => 'All';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get suspended => 'Suspended';

  @override
  String get open => 'Open';

  @override
  String get closed => 'Closed';

  @override
  String get available => 'Available';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get currencyJod => 'JOD';

  @override
  String get roleStudent => 'Student';

  @override
  String get roleCafeteriaAdmin => 'Cafeteria Admin';

  @override
  String get roleCafeteriaStaff => 'Cafeteria Staff';

  @override
  String get roleSystemAdmin => 'System Admin';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginSubtitle => 'Sign in with your campus account to continue.';

  @override
  String get emailLabel => 'University Email';

  @override
  String get emailHint => 'name@university.edu';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get phoneOptionalLabel => 'Mobile Number (Optional)';

  @override
  String get verificationCodeLabel => 'Demo Verification Code (123456)';

  @override
  String get loginButton => 'Sign In';

  @override
  String get registerStudentLink => 'New student? Create an account';

  @override
  String get forgotPasswordLink => 'Forgot password?';

  @override
  String get registerTitle => 'Student Registration';

  @override
  String get registerSubtitle =>
      'Use the simulated verification code 123456 to verify your university email.';

  @override
  String get registerButton => 'Create Student Account';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get resetPasswordSubtitle =>
      'Enter your email, demo code 123456, and a new password.';

  @override
  String get resetPasswordButton => 'Reset Password';

  @override
  String get passwordResetSuccess => 'Password updated. You can now sign in.';

  @override
  String get sendDemoCodeInfo => 'Demo verification code is 123456';

  @override
  String get demoQuickFillTitle => 'Quick Demo Accounts (One-Click Fill)';

  @override
  String get fieldRequired => 'This field is required.';

  @override
  String get invalidEmail => 'Enter a valid email address.';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get invalidPrice => 'Enter a valid positive price.';

  @override
  String get invalidNumber => 'Enter a valid positive number.';

  @override
  String get onboardingTitle => 'Choose Your Campus';

  @override
  String get onboardingSubtitle =>
      'Select your university and campus branch to view nearby cafeterias.';

  @override
  String get selectUniversityLabel => 'University';

  @override
  String get selectCampusLabel => 'Campus Branch';

  @override
  String get continueButton => 'Continue to Cafeterias';

  @override
  String get noCampusesForUniversity =>
      'No active campuses found for this university.';

  @override
  String get demoBarTitle => 'DEMO MODE';

  @override
  String get switchRoleLabel => 'Switch Role';

  @override
  String get offlineToggleLabel => 'Offline';

  @override
  String get simulateOfflineTooltip =>
      'Toggle simulated connection loss banner';

  @override
  String get runAutoRejectNow => 'Run Auto-Reject';

  @override
  String get resetDemoData => 'Reset Demo';

  @override
  String get resetDemoConfirmTitle => 'Reset Demo Data?';

  @override
  String get resetDemoConfirmBody =>
      'This clears local Hive storage and restores the initial GP1 seed data.';

  @override
  String get demoDataResetSuccess => 'Local storage cleared and re-seeded.';

  @override
  String autoRejectCompletedCount(int count) {
    return 'Auto-reject checked pending orders: $count rejected.';
  }

  @override
  String get connectionLostBanner =>
      'Connection lost — operating in offline cache mode. Updates will sync on reconnect.';

  @override
  String get screenAwakeBadge => 'Screen Wake Lock: ON';

  @override
  String get navCafeterias => 'Cafeterias';

  @override
  String get navOrders => 'Orders';

  @override
  String get navCart => 'Cart';

  @override
  String get navSettings => 'Settings';

  @override
  String get searchCafeteriasAndMealsHint => 'Search cafeterias or meals...';

  @override
  String get noCafeteriasOnCampus =>
      'No active cafeterias are listed on this campus yet.';

  @override
  String get noMatchingResults => 'No cafeterias or meals matched your search.';

  @override
  String workingHoursFormat(String hours) {
    return 'Hours: $hours';
  }

  @override
  String prepTimeFormat(int minutes) {
    return '~$minutes min prep';
  }

  @override
  String get menuTitle => 'Menu';

  @override
  String get noMealsInCategory => 'No meals found in this category.';

  @override
  String get mealDetailsTitle => 'Meal Details';

  @override
  String get specialNoteLabel => 'Special Instructions (Optional)';

  @override
  String get specialNoteHint => 'e.g., Extra garlic sauce, no pickles';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get addToCartButton => 'Add to Cart';

  @override
  String addedToCartMessage(String mealName) {
    return 'Added $mealName to cart.';
  }

  @override
  String get cafeteriaClosedOrderBlocked =>
      'This cafeteria is currently closed and cannot accept immediate orders.';

  @override
  String get mealUnavailableBlocked =>
      'This meal is currently marked unavailable.';

  @override
  String get differentCafeteriaTitle => 'Start a New Cart?';

  @override
  String get differentCafeteriaMessage =>
      'Your cart already has items from another cafeteria. Each order can only include one cafeteria. Clear current cart and add this item?';

  @override
  String get clearAndAddButton => 'Clear & Add';

  @override
  String get cartTitle => 'Your Cart';

  @override
  String get emptyCartTitle => 'Your cart is empty';

  @override
  String get emptyCartSubtitle =>
      'Browse campus cafeterias and add meals to start an order.';

  @override
  String get clearCartButton => 'Clear Cart';

  @override
  String get itemSubtotal => 'Itemized Summary';

  @override
  String get totalLabel => 'Total';

  @override
  String get pickupModeLabel => 'Pickup Option';

  @override
  String get orderNowOption => 'Order Now (ASAP)';

  @override
  String get preOrderOption => 'Pre-Order for Pickup Time';

  @override
  String get choosePickupTime => 'Choose Pickup Time';

  @override
  String selectedPickupTime(String time) {
    return 'Pickup at $time';
  }

  @override
  String pickupTimeOutsideHours(String hours) {
    return 'Selected pickup time must be within the cafeteria working hours ($hours).';
  }

  @override
  String get paymentMethodCashOnly => 'Payment: Cash at Pickup Only';

  @override
  String get fulfillmentSelfPickupOnly =>
      'Fulfillment: Self-Pickup at Counter Only';

  @override
  String get placeOrderButton => 'Place Cash Order';

  @override
  String orderPlacedSuccess(String orderNumber) {
    return 'Order $orderNumber placed! Show your QR code at pickup.';
  }

  @override
  String get studentOrdersTitle => 'My Orders';

  @override
  String get noOrdersYet => 'You have not placed any orders yet.';

  @override
  String get activeOrdersSection => 'Active Orders';

  @override
  String get pastOrdersSection => 'Order History';

  @override
  String orderNumberLabel(String number) {
    return 'Order #$number';
  }

  @override
  String get pickupQrCodeTitle => 'Pickup QR Code';

  @override
  String get cancelOrderButton => 'Cancel Order';

  @override
  String get cancelOrderConfirm =>
      'Cancel this pending order before the cafeteria accepts it?';

  @override
  String rejectReasonLabel(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get statusPending => 'Pending';

  @override
  String get statusAccepted => 'Accepted';

  @override
  String get statusPreparing => 'Preparing';

  @override
  String get statusReady => 'Ready for Pickup';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get orderTypeApp => 'App Order';

  @override
  String get orderTypeWalkin => 'Walk-In';

  @override
  String get settingsTitle => 'Settings & Account';

  @override
  String get languageLabel => 'Language / اللغة';

  @override
  String get englishLabel => 'English';

  @override
  String get arabicLabel => 'العربية';

  @override
  String get currentCampusLabel => 'Current Campus';

  @override
  String get changeCampusButton => 'Change University / Campus';

  @override
  String get logoutButton => 'Sign Out';

  @override
  String get tabLiveBoard => 'Live Order Board';

  @override
  String get tabMenuManager => 'Menu Manager';

  @override
  String get tabWorkingHours => 'Hours & Settings';

  @override
  String get tabStaffAccounts => 'Staff Accounts';

  @override
  String get tabOrderHistory => 'Order History';

  @override
  String get tabWalkInOrder => 'New Walk-In Order';

  @override
  String get tabQrLookup => 'QR / Order Lookup';

  @override
  String get soundAlertOn => 'Alert Sound: ON';

  @override
  String get soundAlertMuted => 'Alert Sound: Muted';

  @override
  String pendingAlertBanner(int count) {
    return '$count new pending order(s) waiting for response!';
  }

  @override
  String get columnNew => 'New';

  @override
  String get columnPreparing => 'Preparing';

  @override
  String get columnReady => 'Ready';

  @override
  String get acceptOrderButton => 'Accept';

  @override
  String get rejectOrderButton => 'Reject';

  @override
  String get startPreparingButton => 'Start Preparing';

  @override
  String get markReadyButton => 'Mark Ready';

  @override
  String get completePickupButton => 'Complete Pickup';

  @override
  String autoRejectInSeconds(int seconds) {
    return 'Auto-reject in ${seconds}s';
  }

  @override
  String get rejectOrderDialogTitle => 'Reject Order';

  @override
  String get rejectReasonInputLabel => 'Rejection Reason';

  @override
  String get rejectQuickOut => 'Out of ingredients';

  @override
  String get rejectQuickBusy => 'Kitchen overloaded';

  @override
  String get rejectQuickClosing => 'Closing soon';

  @override
  String get walkInTitle => 'Create Walk-In Order';

  @override
  String get walkInSubtitle =>
      'Select available meals for an in-person customer paying cash at the counter.';

  @override
  String get createWalkInButton => 'Create Walk-In Ticket';

  @override
  String get qrLookupTitle => 'Pickup QR & Order Number Lookup';

  @override
  String get qrLookupHint =>
      'Enter order number (e.g. UB-1001) or scan QR payload';

  @override
  String get lookupButton => 'Find Order';

  @override
  String get orderNotFound =>
      'No order found matching that code in your cafeteria.';

  @override
  String get quickReadyOrdersLabel => 'Quick Demo Select (Ready Orders):';

  @override
  String get addMealButton => 'Add Meal';

  @override
  String get editMealTitle => 'Edit Meal';

  @override
  String get mealNameLabel => 'Meal Name';

  @override
  String get mealCategoryLabel => 'Category';

  @override
  String get mealPriceLabel => 'Price (JOD)';

  @override
  String get mealDescriptionLabel => 'Description';

  @override
  String get mealPhotoLabel => 'Meal Photo';

  @override
  String get pickImageButton => 'Upload Photo';

  @override
  String get orChoosePreset => 'Or select a bundled sample icon:';

  @override
  String get workingHoursTitle => 'Cafeteria Operating Hours & Timeouts';

  @override
  String get openingTimeLabel => 'Opening Time';

  @override
  String get closingTimeLabel => 'Closing Time';

  @override
  String get prepMinutesLabel => 'Prep Time (Minutes)';

  @override
  String get timeoutSecondsLabel => 'Auto-Reject Timeout (Seconds)';

  @override
  String get saveSettingsButton => 'Save Cafeteria Settings';

  @override
  String get settingsSavedMessage => 'Cafeteria settings updated.';

  @override
  String get staffAccountsTitle => 'Cafeteria Staff Accounts';

  @override
  String get addStaffButton => 'Add Staff Account';

  @override
  String get staffPermissionNote =>
      'Staff accounts can manage live orders, walk-in orders, and QR pickups, but cannot edit menu items, prices, hours, or staff.';

  @override
  String get noStaffYet => 'No staff accounts created for this cafeteria yet.';

  @override
  String get noHistoryYet => 'No historical orders yet.';

  @override
  String get tabUniversities => 'Universities';

  @override
  String get tabCampuses => 'Campuses';

  @override
  String get tabCafeterias => 'Cafeterias & Owners';

  @override
  String get tabUsers => 'All Users';

  @override
  String get addUniversityButton => 'Add University';

  @override
  String get universityNameLabel => 'University Name';

  @override
  String get addCampusButton => 'Add Campus Branch';

  @override
  String get campusNameLabel => 'Campus Name';

  @override
  String get campusLocationLabel => 'Campus Location';

  @override
  String get addCafeteriaButton => 'Create Cafeteria & Owner';

  @override
  String get cafeteriaNameLabel => 'Cafeteria Name';

  @override
  String get ownerNameLabel => 'Owner (Cafeteria Admin) Name';

  @override
  String get ownerEmailLabel => 'Owner Login Email';

  @override
  String get ownerPasswordLabel => 'Owner Initial Password';

  @override
  String get filterByUniversity => 'Filter by University';

  @override
  String get filterByRole => 'Filter by Role';

  @override
  String get allRoles => 'All Roles';

  @override
  String get categorySandwiches => 'Sandwiches';

  @override
  String get categoryHotMeals => 'Hot Meals';

  @override
  String get categorySalads => 'Salads';

  @override
  String get categoryBeverages => 'Beverages';

  @override
  String get categoryDesserts => 'Desserts';

  @override
  String get loginHeroHeadline => 'Hungry between lectures?';

  @override
  String get loginHeroSubtitle => 'Order fresh from campus & skip the queue.';

  @override
  String get introSlide1Title => 'Skip the queue';

  @override
  String get introSlide1Body =>
      'Order ahead and grab your meal right when break starts.';

  @override
  String get introSlide2Title => 'Order before your break';

  @override
  String get introSlide2Body =>
      'Pick now or schedule an exact pickup slot between classes.';

  @override
  String get introSlide3Title => 'Pick up and go';

  @override
  String get introSlide3Body =>
      'Flash your QR ticket and pay cash at the counter.';

  @override
  String get skipButton => 'Skip';

  @override
  String get nextButton => 'Next';

  @override
  String get getStartedButton => 'Get Started';

  @override
  String get homeGreeting => 'Ready for a bite?';

  @override
  String get openNowSection => 'Open now';

  @override
  String get allCafeteriasSection => 'All cafeterias';

  @override
  String get searchUniversitiesHint => 'Search universities...';

  @override
  String get stepAccount => '1. Account';

  @override
  String get stepCampus => '2. Campus';

  @override
  String get passwordStrengthWeak => 'Weak';

  @override
  String get passwordStrengthGood => 'Good';

  @override
  String get passwordStrengthStrong => 'Strong';

  @override
  String removedItemUndo(String item) {
    return 'Removed $item';
  }

  @override
  String get undoAction => 'Undo';

  @override
  String get statusPlainPending => 'Waiting for kitchen confirmation';

  @override
  String get statusPlainAccepted => 'Accepted — queued next';

  @override
  String get statusPlainPreparing => 'Being prepared fresh';

  @override
  String get statusPlainReady => 'Ready — show your QR at counter';

  @override
  String get statusPlainCompleted => 'Picked up & paid in cash';

  @override
  String get statusPlainRejected => 'Declined by cafeteria';

  @override
  String get statusPlainCancelled => 'Cancelled before acceptance';

  @override
  String get componentGalleryTitle => 'Component Gallery';

  @override
  String get colorSystemLabel => '70 / 20 / 10 Color System';

  @override
  String get buttonsAndControlsLabel => 'Buttons, Pills & Steppers';

  @override
  String get orderStepperGalleryLabel => 'Animated Order Stepper';

  @override
  String get foodIllustrationsLabel => 'Vector Food Artwork';

  @override
  String get liveConnectedBadge => 'Live Connected';

  @override
  String elapsedMinutesLabel(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String get registerTermsLine =>
      'By creating an account you agree to campus cash-at-pickup terms.';
}
