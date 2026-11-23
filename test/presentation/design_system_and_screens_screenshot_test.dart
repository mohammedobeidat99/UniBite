import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unibite/core/database/local_storage_service.dart';
import 'package:unibite/core/design_system/components.dart';
import 'package:unibite/core/providers/repository_providers.dart';
import 'package:unibite/core/theme/app_theme.dart';
import 'package:unibite/features/auth/domain/entities/user_role.dart';
import 'package:unibite/features/auth/presentation/login_screen.dart';
import 'package:unibite/features/cafeterias/presentation/cafeteria_admin_dashboard_screen.dart';
import 'package:unibite/features/cafeterias/presentation/cafeteria_menu_screen.dart';
import 'package:unibite/features/cafeterias/presentation/student_shell_screen.dart';
import 'package:unibite/features/orders/domain/entities/order_status.dart';
import 'package:unibite/features/universities/presentation/system_admin_dashboard_screen.dart';
import 'package:unibite/l10n/app_localizations.dart';

const bool _exportScreenshots = bool.fromEnvironment(
  'EXPORT_SCREENSHOTS',
  defaultValue: false,
);

void main() {
  late Directory tempDir;
  late LocalStorageService storage;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('unibite_screens_');
    storage = LocalStorageService();
    await storage.init(testDirectoryPath: tempDir.path);
  });

  tearDownAll(() async {
    await storage.dispose();
    try {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  Future<void> captureScreenshot(
    WidgetTester tester,
    GlobalKey boundaryKey,
    String filename,
  ) async {
    if (!_exportScreenshots) return;
    await tester.runAsync(() async {
      final boundary =
          boundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      final outDir = Directory('docs/screenshots');
      if (!outDir.existsSync()) outDir.createSync(recursive: true);
      File('docs/screenshots/$filename').writeAsBytesSync(bytes);
      final afterDir = Directory('docs/design/after');
      if (!afterDir.existsSync()) afterDir.createSync(recursive: true);
      File('docs/design/after/$filename').writeAsBytesSync(bytes);
    });
  }

  Widget wrapScreen({
    required Widget child,
    required ProviderContainer container,
    required GlobalKey boundaryKey,
    Locale locale = const Locale('en'),
    bool disableAnimations = false,
    double textScale = 1.0,
  }) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.lightTheme(languageCode: locale.languageCode),
        builder: (context, inner) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: disableAnimations,
            textScaler: TextScaler.linear(textScale),
          ),
          child: RepaintBoundary(key: boundaryKey, child: inner!),
        ),
        home: child,
      ),
    );
  }

  group('Visual, RTL, Responsive, Accessibility & Screenshot Suite', () {
    testWidgets('renders Login screen cleanly in EN and AR', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer(
        overrides: [localStorageServiceProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      final enKey = GlobalKey();
      await tester.pumpWidget(
        wrapScreen(
          child: const LoginScreen(),
          container: container,
          boundaryKey: enKey,
          locale: const Locale('en'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Hungry between lectures?'), findsOneWidget);
      await captureScreenshot(tester, enKey, '01_login_en.png');

      final arKey = GlobalKey();
      await tester.pumpWidget(
        wrapScreen(
          child: const LoginScreen(),
          container: container,
          boundaryKey: arKey,
          locale: const Locale('ar'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('جوعان بين المحاضرات؟'), findsOneWidget);
      await captureScreenshot(tester, arKey, '02_login_ar.png');
    });

    testWidgets(
      'renders Student Home, Menu & Orders cleanly at 360x640, scaled text & reduce-motion',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final container = ProviderContainer(
          overrides: [localStorageServiceProvider.overrideWithValue(storage)],
        );
        addTearDown(container.dispose);

        await tester.runAsync(() async {
          await container
              .read(authRepositoryProvider)
              .debugSwitchRole(UserRole.student);
        });

        final homeKey = GlobalKey();
        await tester.pumpWidget(
          wrapScreen(
            child: const StudentShellScreen(),
            container: container,
            boundaryKey: homeKey,
            disableAnimations: true,
            textScale: 1.5,
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
        expect(find.text('Green Olive Grill'), findsWidgets);
        await captureScreenshot(tester, homeKey, '03_student_home_en.png');

        final arHomeKey = GlobalKey();
        await tester.pumpWidget(
          wrapScreen(
            child: const StudentShellScreen(),
            container: container,
            boundaryKey: arHomeKey,
            locale: const Locale('ar'),
            disableAnimations: true,
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
        await captureScreenshot(tester, arHomeKey, '04_student_home_ar.png');

        final menuKey = GlobalKey();
        await tester.pumpWidget(
          wrapScreen(
            child: const CafeteriaMenuScreen(cafeteriaId: 'cafe_olive'),
            container: container,
            boundaryKey: menuKey,
            disableAnimations: true,
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
        expect(find.text('Falafel Supreme Sandwich'), findsOneWidget);
        await captureScreenshot(tester, menuKey, '05_cafeteria_menu_en.png');

        final ordersKey = GlobalKey();
        await tester.pumpWidget(
          wrapScreen(
            child: const StudentShellScreen(initialTab: 2),
            container: container,
            boundaryKey: ordersKey,
            disableAnimations: true,
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
        await captureScreenshot(tester, ordersKey, '06_student_orders_en.png');
      },
    );

    testWidgets(
      'renders Cafeteria Admin (including mobile Hours tab) & System Admin Dashboards without Hero or overflow errors',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final container = ProviderContainer(
          overrides: [localStorageServiceProvider.overrideWithValue(storage)],
        );
        addTearDown(container.dispose);

        await tester.runAsync(() async {
          await container
              .read(authRepositoryProvider)
              .debugSwitchRole(UserRole.cafeteriaAdmin);
        });

        final cafeKey = GlobalKey();
        await tester.pumpWidget(
          wrapScreen(
            child: const CafeteriaAdminDashboardScreen(),
            container: container,
            boundaryKey: cafeKey,
            disableAnimations: true,
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
        expect(find.text('Preparing'), findsWidgets);
        await captureScreenshot(
          tester,
          cafeKey,
          '07_cafeteria_dashboard_web_en.png',
        );

        final cafeArKey = GlobalKey();
        await tester.pumpWidget(
          wrapScreen(
            child: const CafeteriaAdminDashboardScreen(),
            container: container,
            boundaryKey: cafeArKey,
            locale: const Locale('ar'),
            disableAnimations: true,
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
        await captureScreenshot(
          tester,
          cafeArKey,
          '08_cafeteria_dashboard_web_ar.png',
        );

        // Verify compact mobile width with side-by-side UbSecondaryButton on Hours & Settings tab.
        tester.view.physicalSize = const Size(360, 640);
        await tester.pumpWidget(
          wrapScreen(
            child: const CafeteriaAdminDashboardScreen(),
            container: container,
            boundaryKey: GlobalKey(),
            disableAnimations: true,
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
        final hoursChip = find.text('Hours & Settings');
        await tester.ensureVisible(hoursChip);
        await tester.pumpAndSettle();
        await tester.tap(hoursChip);
        await tester.pumpAndSettle();
        expect(find.text('Save Cafeteria Settings'), findsOneWidget);

        // Restore 1280x800 for System Admin screenshot.
        tester.view.physicalSize = const Size(1280, 800);
        await tester.runAsync(() async {
          await container
              .read(authRepositoryProvider)
              .debugSwitchRole(UserRole.systemAdmin);
        });

        final sysKey = GlobalKey();
        await tester.pumpWidget(
          wrapScreen(
            child: const SystemAdminDashboardScreen(),
            container: container,
            boundaryKey: sysKey,
            disableAnimations: true,
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
        expect(
          find.text('Jordan University of Science & Technology (JUST)'),
          findsOneWidget,
        );
        await captureScreenshot(
          tester,
          sysKey,
          '09_system_admin_dashboard_web_en.png',
        );
      },
    );

    testWidgets(
      'verifies Golden snapshots of design system card in EN and AR',
      (tester) async {
        tester.view.physicalSize = const Size(480, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final container = ProviderContainer(
          overrides: [localStorageServiceProvider.overrideWithValue(storage)],
        );
        addTearDown(container.dispose);

        // Golden widget snapshot for core stepper + button card in EN & AR.
        final goldenCard = Material(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const UbOpenClosedPill(isOpen: true),
                const SizedBox(height: 12),
                const UbOrderStatusStepper(status: OrderStatus.ready),
                const SizedBox(height: 12),
                UbPrimaryButton(label: 'Place Cash Order', onPressed: () {}),
              ],
            ),
          ),
        );

        final goldenKeyEn = GlobalKey();
        await tester.pumpWidget(
          wrapScreen(
            child: Scaffold(body: Center(child: goldenCard)),
            container: container,
            boundaryKey: goldenKeyEn,
            locale: const Locale('en'),
            disableAnimations: true,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(UbOpenClosedPill), findsOneWidget);
        expect(find.byType(UbOrderStatusStepper), findsOneWidget);
        expect(find.byType(UbPrimaryButton), findsOneWidget);
        await captureScreenshot(
          tester,
          goldenKeyEn,
          '09_design_system_card_en.png',
        );

        final goldenKeyAr = GlobalKey();
        await tester.pumpWidget(
          wrapScreen(
            child: Scaffold(body: Center(child: goldenCard)),
            container: container,
            boundaryKey: goldenKeyAr,
            locale: const Locale('ar'),
            disableAnimations: true,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(UbOpenClosedPill), findsOneWidget);
        expect(find.byType(UbOrderStatusStepper), findsOneWidget);
        expect(find.byType(UbPrimaryButton), findsOneWidget);
        await captureScreenshot(
          tester,
          goldenKeyAr,
          '10_design_system_card_ar.png',
        );
      },
    );
  });
}
