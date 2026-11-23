import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:unibite/core/database/local_storage_service.dart';
import 'package:unibite/core/design_system/components.dart';
import 'package:unibite/core/providers/repository_providers.dart';
import 'package:unibite/features/auth/domain/entities/user_role.dart';
import 'package:unibite/features/cart/presentation/cart_notifier.dart';
import 'package:unibite/features/cart/presentation/cart_screen.dart';
import 'package:unibite/features/meals/domain/entities/meal.dart';
import 'package:unibite/l10n/app_localizations.dart';

void main() {
  late Directory tempDir;
  late LocalStorageService storage;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('unibite_widget_test_');
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

  Widget wrapWithApp(Widget child, ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
  }

  group('CartNotifier & CartScreen Widget Tests', () {
    testWidgets('shows empty state when cart has no items', (tester) async {
      final container = ProviderContainer(
        overrides: [localStorageServiceProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(wrapWithApp(const CartScreen(), container));
      await tester.pumpAndSettle();

      expect(find.text('Your cart is empty'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
      'enforces single cafeteria, updates quantity, shows cash only, and places order',
      (tester) async {
        final container = ProviderContainer(
          overrides: [localStorageServiceProvider.overrideWithValue(storage)],
        );
        addTearDown(container.dispose);

        // Sign in as seeded student.
        await tester.runAsync(() async {
          await container
              .read(authRepositoryProvider)
              .debugSwitchRole(UserRole.student);
        });

        final meals = storage.getMeals();
        final shawarma = meals.firstWhere((m) => m.id == 'meal_shawarma');
        final zinger = meals.firstWhere((m) => m.id == 'meal_zinger_plate');

        final notifier = container.read(cartProvider.notifier);
        final firstAdd = notifier.addItem(
          meal: shawarma,
          cafeteriaName: 'Green Olive Grill',
          quantity: 1,
          note: 'No pickles',
        );
        expect(firstAdd, CartAddResult.added);

        // Adding from a second cafeteria returns conflict unless explicitly cleared.
        final conflictAdd = notifier.addItem(
          meal: zinger,
          cafeteriaName: 'EngBites Express',
        );
        expect(conflictAdd, CartAddResult.differentCafeteriaConflict);

        var orderPlacedCalled = false;
        await tester.pumpWidget(
          wrapWithApp(
            CartScreen(onOrderPlaced: () => orderPlacedCalled = true),
            container,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Green Olive Grill'), findsOneWidget);
        expect(find.text('Chicken Shawarma Wrap'), findsOneWidget);
        expect(find.text('No pickles'), findsOneWidget);
        expect(find.text('Payment: Cash at Pickup Only'), findsOneWidget);
        expect(
          find.text('Fulfillment: Self-Pickup at Counter Only'),
          findsOneWidget,
        );
        expect(find.text('2.50 JOD'), findsWidgets);

        // Increment quantity from 1 to 2 via '+' icon button.
        await tester.tap(find.byIcon(LucideIcons.plus));
        await tester.pumpAndSettle();
        expect(find.text('5.00 JOD'), findsWidgets);

        // Switch to Pre-Order option and back to Order Now.
        await tester.tap(find.text('Pre-Order for Pickup Time'));
        await tester.pumpAndSettle();
        expect(find.text('Choose Pickup Time'), findsOneWidget);

        await tester.tap(find.text('Order Now (ASAP)'));
        await tester.pumpAndSettle();

        // Scroll to and tap Place Cash Order.
        final placeButton = find.byType(UbPrimaryButton).last;
        await tester.ensureVisible(placeButton);
        await tester.tap(placeButton);
        await tester.runAsync(
          () => Future.delayed(const Duration(milliseconds: 150)),
        );
        await tester.pumpAndSettle();

        // Dismiss the order confirmation dialog.
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();

        expect(orderPlacedCalled, isTrue);
        expect(container.read(cartProvider).isEmpty, isTrue);
        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets('blocks adding unavailable meals into CartNotifier', (
      tester,
    ) async {
      final notifier = CartNotifier();
      const unavailableMeal = Meal(
        id: 'meal_x',
        cafeteriaId: 'cafe_olive',
        name: 'Kunafa',
        description: 'Warm pastry',
        price: 1.8,
        imagePath: 'preset:dessert',
        category: 'Desserts',
        isAvailable: false,
      );

      final result = notifier.addItem(
        meal: unavailableMeal,
        cafeteriaName: 'Green Olive Grill',
      );
      expect(result, CartAddResult.unavailableMeal);
      expect(notifier.state.isEmpty, isTrue);
    });
  });
}
