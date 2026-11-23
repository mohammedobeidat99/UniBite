import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:unibite/core/database/local_storage_service.dart';
import 'package:unibite/core/database/seed_data.dart';
import 'package:unibite/core/errors/app_exceptions.dart';
import 'package:unibite/core/utils/password_hasher.dart';
import 'package:unibite/features/auth/data/local/local_auth_repository.dart';
import 'package:unibite/features/auth/domain/entities/user_role.dart';
import 'package:unibite/features/cafeterias/data/local/local_cafeteria_repository.dart';
import 'package:unibite/features/meals/data/local/local_meal_repository.dart';
import 'package:unibite/features/meals/domain/entities/meal.dart';
import 'package:unibite/features/orders/data/local/local_order_repository.dart';
import 'package:unibite/features/orders/domain/entities/order_item.dart';
import 'package:unibite/features/orders/domain/entities/order_status.dart';
import 'package:unibite/features/orders/domain/entities/order_type.dart';
import 'package:unibite/features/universities/data/local/local_university_repository.dart';
import 'package:unibite/features/universities/domain/entities/university.dart';
import 'package:unibite/features/users/data/local/local_user_repository.dart';

void main() {
  late Directory tempDir;
  late LocalStorageService storage;
  late LocalAuthRepository authRepo;
  late LocalUniversityRepository universityRepo;
  late LocalCafeteriaRepository cafeteriaRepo;
  late LocalMealRepository mealRepo;
  late LocalOrderRepository orderRepo;
  late LocalUserRepository userRepo;
  late DateTime simulatedNow;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('unibite_test_');
    storage = LocalStorageService();
    await storage.init(testDirectoryPath: tempDir.path);
    simulatedNow = DateTime(2026, 11, 22, 13, 0);

    authRepo = LocalAuthRepository(storage);
    universityRepo = LocalUniversityRepository(storage);
    cafeteriaRepo = LocalCafeteriaRepository(storage);
    mealRepo = LocalMealRepository(storage);
    orderRepo = LocalOrderRepository(storage, clock: () => simulatedNow);
    userRepo = LocalUserRepository(storage);
  });

  tearDown(() async {
    await storage.dispose();
    try {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  group('Seed data & LocalAuthRepository', () {
    test('seeds required entities and hashes passwords without plain text', () {
      expect(storage.getUniversities().length, 2);
      expect(storage.getCampuses().length, 4);
      expect(storage.getCafeterias().length, 3);
      expect(storage.getMeals().length, 10);

      final users = storage.getUsers();
      expect(users.any((u) => u.role == UserRole.student), isTrue);
      expect(users.any((u) => u.role == UserRole.cafeteriaAdmin), isTrue);
      expect(users.any((u) => u.role == UserRole.cafeteriaStaff), isTrue);
      expect(users.any((u) => u.role == UserRole.systemAdmin), isTrue);

      for (final user in users) {
        expect(user.passwordHash.contains('\$'), isTrue);
        expect(user.passwordHash, isNot('Student@123'));
        expect(user.passwordHash, isNot('Admin@123'));
      }
      expect(
        PasswordHasher.verifyPassword(
          'Student@123',
          users.firstWhere((u) => u.role == UserRole.student).passwordHash,
        ),
        isTrue,
      );
    });

    test('authenticates seeded users and rejects invalid passwords', () async {
      final student = await authRepo.login(
        email: 'student@just.edu.jo',
        password: 'Student@123',
      );
      expect(student.role, UserRole.student);

      expect(
        () => authRepo.login(
          email: 'student@just.edu.jo',
          password: 'WrongPassword',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test(
      'registers student and resets password with demo code 123456 only',
      () async {
        expect(
          () => authRepo.registerStudent(
            name: 'Ahmad',
            email: 'ahmad@just.edu.jo',
            password: 'Secret@123',
            verificationCode: '000000',
          ),
          throwsA(isA<AuthException>()),
        );

        final created = await authRepo.registerStudent(
          name: 'Ahmad',
          email: 'ahmad@just.edu.jo',
          password: 'Secret@123',
          verificationCode: SeedData.demoVerificationCode,
        );
        expect(created.role, UserRole.student);

        await authRepo.resetPassword(
          email: 'ahmad@just.edu.jo',
          verificationCode: SeedData.demoVerificationCode,
          newPassword: 'NewSecret@123',
        );

        final loggedIn = await authRepo.login(
          email: 'ahmad@just.edu.jo',
          password: 'NewSecret@123',
        );
        expect(loggedIn.id, created.id);
      },
    );
  });

  group('Access Control & Repository Operations', () {
    test(
      'only System Admin can create universities and deactivate users',
      () async {
        final sysAdmin = await authRepo.debugSwitchRole(UserRole.systemAdmin);
        final student = storage.getUsers().firstWhere(
          (u) => u.role == UserRole.student,
        );

        expect(
          () => universityRepo.saveUniversity(
            const University(
              id: 'uni_yarmouk',
              name: 'Yarmouk University',
              logo: 'assets/images/logo.jpg',
              isActive: true,
            ),
            actor: student,
          ),
          throwsA(isA<UnauthorizedAccessException>()),
        );

        final created = await universityRepo.saveUniversity(
          const University(
            id: 'uni_yarmouk',
            name: 'Yarmouk University',
            logo: 'assets/images/logo.jpg',
            isActive: true,
          ),
          actor: sysAdmin,
        );
        expect(created.name, 'Yarmouk University');

        final deactivated = await userRepo.setUserActive(
          userId: student.id,
          isActive: false,
          actor: sysAdmin,
        );
        expect(deactivated.isActive, isFalse);
      },
    );

    test('Cafeteria Staff cannot edit meals or working hours', () async {
      final cafeAdmin = storage.getUsers().firstWhere(
        (u) =>
            u.role == UserRole.cafeteriaAdmin && u.cafeteriaId == 'cafe_olive',
      );
      final cafeStaff = storage.getUsers().firstWhere(
        (u) =>
            u.role == UserRole.cafeteriaStaff && u.cafeteriaId == 'cafe_olive',
      );

      expect(
        () => mealRepo.saveMeal(
          const Meal(
            id: 'meal_hacked',
            cafeteriaId: 'cafe_olive',
            name: 'Unauthorized Meal',
            description: 'Test',
            price: 1.0,
            imagePath: 'preset:sandwich',
            category: 'Sandwiches',
            isAvailable: true,
          ),
          actor: cafeStaff,
        ),
        throwsA(isA<UnauthorizedAccessException>()),
      );

      expect(
        () => cafeteriaRepo.updateWorkingHours(
          cafeteriaId: 'cafe_olive',
          workingHours: '09:00-17:00',
          actor: cafeStaff,
        ),
        throwsA(isA<UnauthorizedAccessException>()),
      );

      final updatedMeal = await mealRepo.setMealAvailability(
        mealId: 'meal_shawarma',
        isAvailable: false,
        actor: cafeAdmin,
      );
      expect(updatedMeal.isAvailable, isFalse);
    });

    test(
      'enforces order validation, cancellation, walk-in, and auto-reject',
      () async {
        final student = storage.getUsers().firstWhere(
          (u) => u.role == UserRole.student,
        );
        final cafeAdmin = storage.getUsers().firstWhere(
          (u) =>
              u.role == UserRole.cafeteriaAdmin &&
              u.cafeteriaId == 'cafe_olive',
        );
        final cafeStaff = storage.getUsers().firstWhere(
          (u) =>
              u.role == UserRole.cafeteriaStaff &&
              u.cafeteriaId == 'cafe_olive',
        );

        // Unavailable meal blocked.
        expect(
          () => orderRepo.placeStudentOrder(
            cafeteriaId: 'cafe_olive',
            items: const [
              OrderItem(
                mealId: 'meal_kunafa_cup',
                name: 'Warm Kunafa Cup',
                price: 1.80,
                qty: 1,
              ),
            ],
            actor: student,
          ),
          throwsA(isA<ValidationException>()),
        );

        // Mixing meals from another cafeteria blocked.
        expect(
          () => orderRepo.placeStudentOrder(
            cafeteriaId: 'cafe_olive',
            items: const [
              OrderItem(
                mealId: 'meal_zinger_plate',
                name: 'Crispy Zinger Plate',
                price: 3.40,
                qty: 1,
              ),
            ],
            actor: student,
          ),
          throwsA(isA<ValidationException>()),
        );

        // Valid cash order succeeds and student can cancel while pending.
        final placed = await orderRepo.placeStudentOrder(
          cafeteriaId: 'cafe_olive',
          items: const [
            OrderItem(
              mealId: 'meal_shawarma',
              name: 'Chicken Shawarma Wrap',
              price: 2.50,
              qty: 2,
            ),
          ],
          actor: student,
        );
        expect(placed.total, 5.00);
        expect(placed.paymentMethod, 'cash');
        expect(placed.status, OrderStatus.pending);

        final cancelled = await orderRepo.cancelOrder(
          orderId: placed.id,
          actor: student,
        );
        expect(cancelled.status, OrderStatus.cancelled);

        // Walk-in order by staff starts accepted and can be found via QR.
        final walkIn = await orderRepo.createWalkInOrder(
          cafeteriaId: 'cafe_olive',
          items: const [
            OrderItem(
              mealId: 'meal_falafel',
              name: 'Falafel Supreme Sandwich',
              price: 1.25,
              qty: 1,
            ),
          ],
          actor: cafeStaff,
        );
        expect(walkIn.type, OrderType.walkin);
        expect(walkIn.status, OrderStatus.accepted);

        final lookedUp = await orderRepo.findOrderByCodeOrNumber(
          cafeteriaId: 'cafe_olive',
          query: walkIn.qrCode,
          actor: cafeStaff,
        );
        expect(lookedUp?.id, walkIn.id);

        // Place another pending order and trigger auto-reject after 3 minutes.
        final timedOrder = await orderRepo.placeStudentOrder(
          cafeteriaId: 'cafe_olive',
          items: const [
            OrderItem(
              mealId: 'meal_shawarma',
              name: 'Chicken Shawarma Wrap',
              price: 2.50,
              qty: 1,
            ),
          ],
          actor: student,
        );

        final rejectedCount = await orderRepo.autoRejectTimedOutOrders(
          cafeteriaTimeoutsSeconds: {'cafe_olive': 180},
          now: simulatedNow.add(const Duration(minutes: 4)),
        );
        expect(rejectedCount, 1);

        final afterSweep = await orderRepo.watchOrderById(timedOrder.id).first;
        expect(afterSweep?.status, OrderStatus.rejected);
        expect(afterSweep?.rejectReason, 'No response');

        // Closed cafeteria blocks immediate orders.
        await cafeteriaRepo.updateWorkingHours(
          cafeteriaId: 'cafe_olive',
          workingHours: '08:00-10:00',
          actor: cafeAdmin,
        );
        expect(
          () => orderRepo.placeStudentOrder(
            cafeteriaId: 'cafe_olive',
            items: const [
              OrderItem(
                mealId: 'meal_shawarma',
                name: 'Chicken Shawarma Wrap',
                price: 2.50,
                qty: 1,
              ),
            ],
            actor: student,
          ),
          throwsA(isA<ValidationException>()),
        );
      },
    );
  });
}
