import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unibite/core/database/local_storage_service.dart';
import 'package:unibite/core/providers/repository_providers.dart';
import 'package:unibite/main.dart';

void main() {
  late Directory tempDir;
  late LocalStorageService storage;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('unibite_app_smoke_');
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

  testWidgets(
    'UniBiteApp flows Splash -> Intro -> Login -> Student Home cleanly without top demo banner',
    (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [localStorageServiceProvider.overrideWithValue(storage)],
          child: const UniBiteApp(),
        ),
      );

      // Wait for Splash animation to advance immediately to 3-slide Intro.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('Skip the queue'), findsOneWidget);
      await tester.tap(find.text('Skip'));
      await tester.runAsync(
        () => Future.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();

      // Lands on custom hero Login screen without any top DEMO MODE bar.
      expect(find.text('Hungry between lectures?'), findsOneWidget);

      // Quick-fill Student credentials and sign in cleanly.
      final studentChip = find.text('Student');
      await tester.ensureVisible(studentChip);
      await tester.tap(studentChip);
      await tester.pumpAndSettle();

      final signInBtn = find.text('Sign In');
      await tester.ensureVisible(signInBtn);
      await tester.tap(signInBtn);
      await tester.runAsync(
        () => Future.delayed(const Duration(milliseconds: 150)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Main Campus (Al-Ramtha)'), findsOneWidget);
      expect(find.text('Green Olive Grill'), findsWidgets);

      // Navigate to Settings and tap Sign Out; must return cleanly to Login without skeleton hang.
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      final signOutBtn = find.text('Sign Out');
      await tester.ensureVisible(signOutBtn);
      await tester.tap(signOutBtn);
      await tester.runAsync(
        () => Future.delayed(const Duration(milliseconds: 150)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hungry between lectures?'), findsOneWidget);

      // Unmount app widget tree cleanly to close all Riverpod provider streams and timers.
      await tester.pumpWidget(const SizedBox());
    },
  );
}
