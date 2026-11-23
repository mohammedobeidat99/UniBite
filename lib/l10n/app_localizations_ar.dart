// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'UniBite';

  @override
  String get appTagline => 'حرمك الجامعي، طعامك، بطريقتك.';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get add => 'إضافة';

  @override
  String get confirm => 'تأكيد';

  @override
  String get close => 'إغلاق';

  @override
  String get search => 'بحث';

  @override
  String get all => 'الكل';

  @override
  String get active => 'فعّال';

  @override
  String get inactive => 'معطّل';

  @override
  String get suspended => 'موقوف';

  @override
  String get open => 'مفتوح';

  @override
  String get closed => 'مغلق';

  @override
  String get available => 'متوفر';

  @override
  String get unavailable => 'غير متوفر';

  @override
  String get currencyJod => 'د.أ';

  @override
  String get roleStudent => 'طالب';

  @override
  String get roleCafeteriaAdmin => 'مدير كافيتيريا';

  @override
  String get roleCafeteriaStaff => 'موظف كافيتيريا';

  @override
  String get roleSystemAdmin => 'مدير النظام';

  @override
  String get loginTitle => 'مرحباً بعودتك';

  @override
  String get loginSubtitle => 'سجّل الدخول بحسابك الجامعي للمتابعة.';

  @override
  String get emailLabel => 'البريد الجامعي';

  @override
  String get emailHint => 'name@university.edu';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get fullNameLabel => 'الاسم الكامل';

  @override
  String get phoneOptionalLabel => 'رقم الهاتف (اختياري)';

  @override
  String get verificationCodeLabel => 'رمز التحقق التجريبي (123456)';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get registerStudentLink => 'طالب جديد؟ أنشئ حساباً';

  @override
  String get forgotPasswordLink => 'نسيت كلمة المرور؟';

  @override
  String get registerTitle => 'تسجيل حساب طالب';

  @override
  String get registerSubtitle =>
      'استخدم رمز التحقق المحاكى 123456 لتأكيد بريدك الجامعي.';

  @override
  String get registerButton => 'إنشاء حساب طالب';

  @override
  String get resetPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get resetPasswordSubtitle =>
      'أدخل بريدك الإلكتروني والرمز التجريبي 123456 وكلمة المرور الجديدة.';

  @override
  String get resetPasswordButton => 'تحديث كلمة المرور';

  @override
  String get passwordResetSuccess =>
      'تم تحديث كلمة المرور. يمكنك الآن تسجيل الدخول.';

  @override
  String get sendDemoCodeInfo => 'رمز التحقق التجريبي هو 123456';

  @override
  String get demoQuickFillTitle => 'حسابات تجريبية سريعة (تعبئة بنقرة واحدة)';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب.';

  @override
  String get invalidEmail => 'أدخل بريداً إلكترونياً صحيحاً.';

  @override
  String get passwordTooShort => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل.';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get invalidPrice => 'أدخل سعراً موجباً صحيحاً.';

  @override
  String get invalidNumber => 'أدخل رقماً موجباً صحيحاً.';

  @override
  String get onboardingTitle => 'اختر حرمك الجامعي';

  @override
  String get onboardingSubtitle =>
      'اختر جامعتك والفرع الجامعي لعرض الكافيتيريات المتاحة.';

  @override
  String get selectUniversityLabel => 'الجامعة';

  @override
  String get selectCampusLabel => 'الفرع / الحرم الجامعي';

  @override
  String get continueButton => 'المتابعة إلى الكافيتيريات';

  @override
  String get noCampusesForUniversity => 'لا توجد فروع نشطة لهذه الجامعة.';

  @override
  String get demoBarTitle => 'وضع العرض التجريبي';

  @override
  String get switchRoleLabel => 'تبديل الدور';

  @override
  String get offlineToggleLabel => 'غير متصل';

  @override
  String get simulateOfflineTooltip => 'تبديل محاكاة انقطاع الاتصال';

  @override
  String get runAutoRejectNow => 'تشغيل الرفض التلقائي';

  @override
  String get resetDemoData => 'إعادة ضبط البيانات';

  @override
  String get resetDemoConfirmTitle => 'إعادة ضبط البيانات التجريبية؟';

  @override
  String get resetDemoConfirmBody =>
      'سيتم مسح التخزين المحلي واستعادة بيانات البداية لـ GP1.';

  @override
  String get demoDataResetSuccess =>
      'تم مسح التخزين المحلي وإعادة تعبئة البيانات.';

  @override
  String autoRejectCompletedCount(int count) {
    return 'تم فحص الطلبات المعلّقة: تم رفض $count تلقائياً.';
  }

  @override
  String get connectionLostBanner =>
      'انقطع الاتصال — يتم العمل بوضع التخزين المحلي المؤقت. ستتم المزامنة عند عودة الاتصال.';

  @override
  String get screenAwakeBadge => 'إبقاء الشاشة نشطة: مفعّل';

  @override
  String get navCafeterias => 'الكافيتيريات';

  @override
  String get navOrders => 'الطلبات';

  @override
  String get navCart => 'السلة';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get searchCafeteriasAndMealsHint => 'ابحث عن كافيتيريا أو وجبة...';

  @override
  String get noCafeteriasOnCampus =>
      'لا توجد كافيتيريات نشطة مسجلة في هذا الحرم حالياً.';

  @override
  String get noMatchingResults => 'لا توجد كافيتيريات أو وجبات مطابقة لبحثك.';

  @override
  String workingHoursFormat(String hours) {
    return 'ساعات العمل: $hours';
  }

  @override
  String prepTimeFormat(int minutes) {
    return 'التحضير ~$minutes د';
  }

  @override
  String get menuTitle => 'قائمة الطعام';

  @override
  String get noMealsInCategory => 'لا توجد وجبات في هذا التصنيف.';

  @override
  String get mealDetailsTitle => 'تفاصيل الوجبة';

  @override
  String get specialNoteLabel => 'ملاحظات خاصة (اختياري)';

  @override
  String get specialNoteHint => 'مثال: بدون مخلل، ثوم إضافي';

  @override
  String get quantityLabel => 'الكمية';

  @override
  String get addToCartButton => 'إضافة إلى السلة';

  @override
  String addedToCartMessage(String mealName) {
    return 'تمت إضافة $mealName إلى السلة.';
  }

  @override
  String get cafeteriaClosedOrderBlocked =>
      'هذه الكافيتيريا مغلقة حالياً ولا يمكن الطلب الفوري منها.';

  @override
  String get mealUnavailableBlocked => 'هذه الوجبة غير متوفرة حالياً.';

  @override
  String get differentCafeteriaTitle => 'بدء سلة جديدة؟';

  @override
  String get differentCafeteriaMessage =>
      'تحتوي سلتك على أصناف من كافيتيريا أخرى. يمكن أن يشمل الطلب كافيتيريا واحدة فقط. هل تريد مسح السلة وإضافة هذا الصنف؟';

  @override
  String get clearAndAddButton => 'مسح وإضافة';

  @override
  String get cartTitle => 'سلة الطلب';

  @override
  String get emptyCartTitle => 'سلتك فارغة';

  @override
  String get emptyCartSubtitle => 'تصفح كافيتيريات الحرم وأضف وجبات لبدء طلبك.';

  @override
  String get clearCartButton => 'إفراغ السلة';

  @override
  String get itemSubtotal => 'ملخص الأصناف';

  @override
  String get totalLabel => 'المجموع الكلي';

  @override
  String get pickupModeLabel => 'موعد الاستلام';

  @override
  String get orderNowOption => 'الطلب الآن (فوري)';

  @override
  String get preOrderOption => 'طلب مسبق لوقت محدد';

  @override
  String get choosePickupTime => 'اختر وقت الاستلام';

  @override
  String selectedPickupTime(String time) {
    return 'الاستلام الساعة $time';
  }

  @override
  String pickupTimeOutsideHours(String hours) {
    return 'يجب أن يكون وقت الاستلام المختار ضمن ساعات عمل الكافيتيريا ($hours).';
  }

  @override
  String get paymentMethodCashOnly => 'الدفع: نقداً عند الاستلام فقط';

  @override
  String get fulfillmentSelfPickupOnly =>
      'الاستلام: استلام شخصي من الكاونتر فقط';

  @override
  String get placeOrderButton => 'إرسال الطلب (دفع نقدي)';

  @override
  String orderPlacedSuccess(String orderNumber) {
    return 'تم إرسال الطلب $orderNumber! أظهر رمز QR عند الاستلام.';
  }

  @override
  String get studentOrdersTitle => 'طلباتي';

  @override
  String get noOrdersYet => 'لم تقم بإرسال أي طلبات بعد.';

  @override
  String get activeOrdersSection => 'الطلبات النشطة';

  @override
  String get pastOrdersSection => 'سجل الطلبات';

  @override
  String orderNumberLabel(String number) {
    return 'طلب #$number';
  }

  @override
  String get pickupQrCodeTitle => 'رمز الاستلام QR';

  @override
  String get cancelOrderButton => 'إلغاء الطلب';

  @override
  String get cancelOrderConfirm =>
      'هل تريد إلغاء هذا الطلب المعلّق قبل قبوله من الكافيتيريا؟';

  @override
  String rejectReasonLabel(String reason) {
    return 'السبب: $reason';
  }

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusAccepted => 'مقبول';

  @override
  String get statusPreparing => 'قيد التحضير';

  @override
  String get statusReady => 'جاهز للاستلام';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get statusCancelled => 'ملغي';

  @override
  String get orderTypeApp => 'طلب تطبيق';

  @override
  String get orderTypeWalkin => 'طلب كاونتر';

  @override
  String get settingsTitle => 'الإعدادات والحساب';

  @override
  String get languageLabel => 'اللغة / Language';

  @override
  String get englishLabel => 'English';

  @override
  String get arabicLabel => 'العربية';

  @override
  String get currentCampusLabel => 'الحرم الجامعي الحالي';

  @override
  String get changeCampusButton => 'تغيير الجامعة / الحرم';

  @override
  String get logoutButton => 'تسجيل الخروج';

  @override
  String get tabLiveBoard => 'لوحة الطلبات المباشرة';

  @override
  String get tabMenuManager => 'إدارة القائمة';

  @override
  String get tabWorkingHours => 'ساعات العمل والإعدادات';

  @override
  String get tabStaffAccounts => 'حسابات الموظفين';

  @override
  String get tabOrderHistory => 'سجل الطلبات';

  @override
  String get tabWalkInOrder => 'طلب كاونتر جديد';

  @override
  String get tabQrLookup => 'بحث QR / رقم الطلب';

  @override
  String get soundAlertOn => 'تنبيه الصوت: مفعّل';

  @override
  String get soundAlertMuted => 'تنبيه الصوت: صامت';

  @override
  String pendingAlertBanner(int count) {
    return 'يوجد $count طلب جديد بانتظار الرد!';
  }

  @override
  String get columnNew => 'جديد';

  @override
  String get columnPreparing => 'قيد التحضير';

  @override
  String get columnReady => 'جاهز';

  @override
  String get acceptOrderButton => 'قبول';

  @override
  String get rejectOrderButton => 'رفض';

  @override
  String get startPreparingButton => 'بدء التحضير';

  @override
  String get markReadyButton => 'جاهز للاستلام';

  @override
  String get completePickupButton => 'تسليم وإتمام';

  @override
  String autoRejectInSeconds(int seconds) {
    return 'رفض تلقائي خلال $seconds ث';
  }

  @override
  String get rejectOrderDialogTitle => 'رفض الطلب';

  @override
  String get rejectReasonInputLabel => 'سبب الرفض';

  @override
  String get rejectQuickOut => 'نفاد المكونات';

  @override
  String get rejectQuickBusy => 'ضغط عمل في المطبخ';

  @override
  String get rejectQuickClosing => 'اقترب وقت الإغلاق';

  @override
  String get walkInTitle => 'إنشاء طلب كاونتر مباشر';

  @override
  String get walkInSubtitle =>
      'اختر الوجبات المتوفرة لزبون يدفع نقداً عند الكاونتر.';

  @override
  String get createWalkInButton => 'إنشاء تذكرة الطلب';

  @override
  String get qrLookupTitle => 'التحقق من رمز QR أو رقم الطلب';

  @override
  String get qrLookupHint => 'أدخل رقم الطلب (مثل UB-1001) أو رمز QR';

  @override
  String get lookupButton => 'بحث عن الطلب';

  @override
  String get orderNotFound => 'لم يتم العثور على طلب مطابق في هذه الكافيتيريا.';

  @override
  String get quickReadyOrdersLabel => 'اختيار سريع للتجربة (الطلبات الجاهزة):';

  @override
  String get addMealButton => 'إضافة وجبة';

  @override
  String get editMealTitle => 'تعديل الوجبة';

  @override
  String get mealNameLabel => 'اسم الوجبة';

  @override
  String get mealCategoryLabel => 'التصنيف';

  @override
  String get mealPriceLabel => 'السعر (د.أ)';

  @override
  String get mealDescriptionLabel => 'الوصف';

  @override
  String get mealPhotoLabel => 'صورة الوجبة';

  @override
  String get pickImageButton => 'رفع صورة';

  @override
  String get orChoosePreset => 'أو اختر أيقونة طعام مدمجة:';

  @override
  String get workingHoursTitle => 'ساعات عمل الكافيتيريا ومهلة الرد';

  @override
  String get openingTimeLabel => 'وقت الافتتاح';

  @override
  String get closingTimeLabel => 'وقت الإغلاق';

  @override
  String get prepMinutesLabel => 'مدة التحضير (دقائق)';

  @override
  String get timeoutSecondsLabel => 'مهلة الرفض التلقائي (ثوانٍ)';

  @override
  String get saveSettingsButton => 'حفظ إعدادات الكافيتيريا';

  @override
  String get settingsSavedMessage => 'تم تحديث إعدادات الكافيتيريا.';

  @override
  String get staffAccountsTitle => 'حسابات موظفي الكافيتيريا';

  @override
  String get addStaffButton => 'إضافة حساب موظف';

  @override
  String get staffPermissionNote =>
      'يمكن للموظفين إدارة لوحة الطلبات وطلبات الكاونتر والتحقق من QR فقط، ولا يمكنهم تعديل القائمة أو الأسعار أو ساعات العمل أو الموظفين.';

  @override
  String get noStaffYet => 'لم يتم إنشاء حسابات موظفين لهذه الكافيتيريا بعد.';

  @override
  String get noHistoryYet => 'لا توجد طلبات سابقة بعد.';

  @override
  String get tabUniversities => 'الجامعات';

  @override
  String get tabCampuses => 'الفروع الجامعية';

  @override
  String get tabCafeterias => 'الكافيتيريات والمالكون';

  @override
  String get tabUsers => 'جميع المستخدمين';

  @override
  String get addUniversityButton => 'إضافة جامعة';

  @override
  String get universityNameLabel => 'اسم الجامعة';

  @override
  String get addCampusButton => 'إضافة فرع جامعي';

  @override
  String get campusNameLabel => 'اسم الفرع';

  @override
  String get campusLocationLabel => 'موقع الفرع';

  @override
  String get addCafeteriaButton => 'إنشاء كافيتيريا ومالك';

  @override
  String get cafeteriaNameLabel => 'اسم الكافيتيريا';

  @override
  String get ownerNameLabel => 'اسم المالك (مدير الكافيتيريا)';

  @override
  String get ownerEmailLabel => 'بريد دخول المالك';

  @override
  String get ownerPasswordLabel => 'كلمة مرور المالك المبدئية';

  @override
  String get filterByUniversity => 'تصفية حسب الجامعة';

  @override
  String get filterByRole => 'تصفية حسب الدور';

  @override
  String get allRoles => 'جميع الأدوار';

  @override
  String get categorySandwiches => 'سندويشات';

  @override
  String get categoryHotMeals => 'وجبات ساخنة';

  @override
  String get categorySalads => 'سلطات';

  @override
  String get categoryBeverages => 'مشروبات';

  @override
  String get categoryDesserts => 'حلويات';

  @override
  String get loginHeroHeadline => 'جوعان بين المحاضرات؟';

  @override
  String get loginHeroSubtitle => 'اطلب من كافيتيريا جامعتك وتخطَّ الطابور.';

  @override
  String get introSlide1Title => 'تخطَّ الطابور';

  @override
  String get introSlide1Body => 'اطلب مسبقاً واستلم وجبتك فور بدء الاستراحة.';

  @override
  String get introSlide2Title => 'اطلب قبل استراحتك';

  @override
  String get introSlide2Body => 'استلام فوري أو حجز موعد يناسب جدول محاضراتك.';

  @override
  String get introSlide3Title => 'استلم وانطلق';

  @override
  String get introSlide3Body => 'أظهر رمز QR وادفع نقداً عند الكاونتر.';

  @override
  String get skipButton => 'تخطي';

  @override
  String get nextButton => 'التالي';

  @override
  String get getStartedButton => 'ابدأ الآن';

  @override
  String get homeGreeting => 'جاهز لوجبتك؟';

  @override
  String get openNowSection => 'مفتوح الآن';

  @override
  String get allCafeteriasSection => 'جميع الكافيتيريات';

  @override
  String get searchUniversitiesHint => 'ابحث عن جامعة...';

  @override
  String get stepAccount => '١. الحساب';

  @override
  String get stepCampus => '٢. الحرم';

  @override
  String get passwordStrengthWeak => 'ضعيفة';

  @override
  String get passwordStrengthGood => 'جيدة';

  @override
  String get passwordStrengthStrong => 'قوية';

  @override
  String removedItemUndo(String item) {
    return 'تمت إزالة $item';
  }

  @override
  String get undoAction => 'تراجع';

  @override
  String get statusPlainPending => 'بانتظار تأكيد المطبخ';

  @override
  String get statusPlainAccepted => 'مقبول — في قائمة التحضير';

  @override
  String get statusPlainPreparing => 'قيد التحضير الآن';

  @override
  String get statusPlainReady => 'جاهز — أظهر رمز QR عند الكاونتر';

  @override
  String get statusPlainCompleted => 'تم الاستلام والدفع نقداً';

  @override
  String get statusPlainRejected => 'تم رفض الطلب من الكافيتيريا';

  @override
  String get statusPlainCancelled => 'تم الإلغاء قبل القبول';

  @override
  String get componentGalleryTitle => 'معرض المكوّنات';

  @override
  String get colorSystemLabel => 'نظام الألوان 70 / 20 / 10';

  @override
  String get buttonsAndControlsLabel => 'الأزرار والشارات والعدّاد';

  @override
  String get orderStepperGalleryLabel => 'متتبع حالة الطلب المتحرك';

  @override
  String get foodIllustrationsLabel => 'رسومات الطعام الموحّدة';

  @override
  String get liveConnectedBadge => 'متصل مباشرة';

  @override
  String elapsedMinutesLabel(int minutes) {
    return 'منذ $minutes د';
  }

  @override
  String get registerTermsLine =>
      'بإنشاء حساب فإنك توافق على شروط الدفع نقداً عند الاستلام.';
}
