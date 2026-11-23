import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:unibite/core/database/local_storage_service.dart';
import 'package:unibite/core/database/seed_data.dart';
import 'package:unibite/core/errors/app_exceptions.dart';
import 'package:unibite/features/auth/data/local/local_auth_repository.dart';
import 'package:unibite/features/auth/domain/entities/user_role.dart';
import 'package:unibite/features/cafeterias/data/local/local_cafeteria_repository.dart';
import 'package:unibite/features/cafeterias/domain/entities/cafeteria.dart';
import 'package:unibite/features/meals/data/local/local_meal_repository.dart';
import 'package:unibite/features/meals/domain/entities/meal.dart';
import 'package:unibite/features/orders/data/local/local_order_repository.dart';
import 'package:unibite/features/orders/domain/entities/order_item.dart';
import 'package:unibite/features/orders/domain/entities/order_status.dart';
import 'package:unibite/features/orders/domain/services/order_auto_reject_service.dart';
import 'package:unibite/features/universities/data/local/local_university_repository.dart';
import 'package:unibite/features/universities/domain/entities/campus.dart';
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
  late DateTime simulatedClock;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('unibite_e2e_');
    storage = LocalStorageService();
    await storage.init(testDirectoryPath: tempDir.path);
    simulatedClock = DateTime(2026, 11, 22, 13, 0, 0);

    authRepo = LocalAuthRepository(storage);
    universityRepo = LocalUniversityRepository(storage);
    cafeteriaRepo = LocalCafeteriaRepository(storage);
    mealRepo = LocalMealRepository(storage);
    orderRepo = LocalOrderRepository(storage, clock: () => simulatedClock);
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

  group('End-to-End Integration Flows', () {
    test(
      'Flow 1: Register -> select campus -> order -> staff accept/prepare/ready/complete -> student sees each status',
      () async {
        final registered = await authRepo.registerStudent(
          name: 'Sami Ali',
          email: 'sami@just.edu.jo',
          password: 'Password@123',
          phone: '0791112233',
          verificationCode: SeedData.demoVerificationCode,
        );
        final onboarded = await authRepo.updateStudentCampus(
          userId: registered.id,
          universityId: 'uni_just',
          campusId: 'camp_just_main',
        );
        expect(onboarded.hasCompletedOnboarding, isTrue);

        final campusCafes = await cafeteriaRepo
            .watchCafeterias(campusId: onboarded.campusId, activeOnly: true)
            .first;
        expect(campusCafes.any((c) => c.id == 'cafe_olive'), isTrue);

        final placed = await orderRepo.placeStudentOrder(
          cafeteriaId: 'cafe_olive',
          items: const [
            OrderItem(
              mealId: 'meal_shawarma',
              name: 'Chicken Shawarma Wrap',
              price: 2.50,
              qty: 2,
              note: 'No pickles',
            ),
          ],
          actor: onboarded,
        );
        expect(placed.status, OrderStatus.pending);

        final staff = await authRepo.debugSwitchRole(UserRole.cafeteriaStaff);
        await orderRepo.updateOrderStatus(
          orderId: placed.id,
          newStatus: OrderStatus.accepted,
          actor: staff,
        );
        await orderRepo.updateOrderStatus(
          orderId: placed.id,
          newStatus: OrderStatus.preparing,
          actor: staff,
        );
        await orderRepo.updateOrderStatus(
          orderId: placed.id,
          newStatus: OrderStatus.ready,
          actor: staff,
        );

        final qrLookup = await orderRepo.findOrderByCodeOrNumber(
          cafeteriaId: 'cafe_olive',
          query: placed.qrCode,
          actor: staff,
        );
        expect(qrLookup?.status, OrderStatus.ready);

        await orderRepo.updateOrderStatus(
          orderId: placed.id,
          newStatus: OrderStatus.completed,
          actor: staff,
        );

        final studentOrders = await orderRepo
            .watchOrdersForStudent(onboarded.id, actor: onboarded)
            .first;
        expect(studentOrders.first.status, OrderStatus.completed);
      },
    );

    test(
      'Flow 2: Cafeteria reject flow preserves reason for student',
      () async {
        final student = await authRepo.debugSwitchRole(UserRole.student);
        final order = await orderRepo.placeStudentOrder(
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

        final admin = await authRepo.debugSwitchRole(
          UserRole.cafeteriaAdmin,
          cafeteriaId: 'cafe_olive',
        );
        final rejected = await orderRepo.updateOrderStatus(
          orderId: order.id,
          newStatus: OrderStatus.rejected,
          rejectReason: 'Out of ingredients',
          actor: admin,
        );

        expect(rejected.status, OrderStatus.rejected);
        expect(rejected.rejectReason, 'Out of ingredients');
      },
    );

    test(
      'Flow 3: Auto-reject boundary test (2:59 intact, 3:00 auto-rejected)',
      () async {
        final student = await authRepo.debugSwitchRole(UserRole.student);
        final order = await orderRepo.placeStudentOrder(
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

        final serviceAt179 = OrderAutoRejectService(
          orderRepo,
          cafeteriaRepo,
          clock: () => simulatedClock.add(const Duration(seconds: 179)),
        );
        expect(await serviceAt179.runSweep(), 0);

        final serviceAt180 = OrderAutoRejectService(
          orderRepo,
          cafeteriaRepo,
          clock: () => simulatedClock.add(const Duration(seconds: 180)),
        );
        expect(await serviceAt180.runSweep(), 1);

        final updated = await orderRepo.watchOrderById(order.id).first;
        expect(updated?.status, OrderStatus.rejected);
        expect(updated?.rejectReason, 'No response');
      },
    );

    test(
      'Flow 4: System Admin creates university, campus, cafeteria, and owner without code change',
      () async {
        final sysAdmin = await authRepo.debugSwitchRole(UserRole.systemAdmin);

        await universityRepo.saveUniversity(
          const University(
            id: 'uni_htu',
            name: 'Al-Hussein Technical University (HTU)',
            logo: 'assets/images/logo.jpg',
            isActive: true,
          ),
          actor: sysAdmin,
        );
        await universityRepo.saveCampus(
          const Campus(
            id: 'camp_htu_amman',
            universityId: 'uni_htu',
            name: 'KHBP Campus',
            location: 'King Hussein Business Park',
            isActive: true,
          ),
          actor: sysAdmin,
        );
        final owner = await userRepo.createCafeteriaAdmin(
          name: 'Kareem Nabil',
          email: 'kareem@htu.edu.jo',
          password: 'Owner@123',
          universityId: 'uni_htu',
          campusId: 'camp_htu_amman',
          cafeteriaId: 'cafe_htu_1',
          actor: sysAdmin,
        );
        final cafe = await cafeteriaRepo.saveCafeteria(
          Cafeteria(
            id: 'cafe_htu_1',
            universityId: 'uni_htu',
            campusId: 'camp_htu_amman',
            name: 'Tech Fuel Cafe',
            logo: 'assets/images/logo.jpg',
            workingHours: '08:00-20:00',
            isActive: true,
            ownerId: owner.id,
          ),
          actor: sysAdmin,
        );

        expect(cafe.campusId, 'camp_htu_amman');
        final campuses = await universityRepo.getCampuses(
          universityId: 'uni_htu',
        );
        expect(campuses.length, 1);
      },
    );

    test(
      'Flow 5: Staff restrictions and cross-cafeteria isolation throw UnauthorizedAccessException',
      () async {
        final staff = await authRepo.debugSwitchRole(
          UserRole.cafeteriaStaff,
          cafeteriaId: 'cafe_olive',
        );
        final adminOlive = await authRepo.debugSwitchRole(
          UserRole.cafeteriaAdmin,
          cafeteriaId: 'cafe_olive',
        );

        expect(
          () => mealRepo.saveMeal(
            const Meal(
              id: 'm_blocked',
              cafeteriaId: 'cafe_olive',
              name: 'Staff Blocked',
              description: 'No access',
              price: 2.0,
              imagePath: 'preset:sandwich',
              category: 'Sandwiches',
              isAvailable: true,
            ),
            actor: staff,
          ),
          throwsA(isA<UnauthorizedAccessException>()),
        );

        expect(
          () => userRepo.createCafeteriaStaff(
            name: 'Unauthorized Staff',
            email: 'unauth@just.edu.jo',
            password: 'Password@123',
            cafeteriaId: 'cafe_olive',
            actor: staff,
          ),
          throwsA(isA<UnauthorizedAccessException>()),
        );

        // Cafeteria A admin cannot edit Cafeteria B menu.
        expect(
          () => mealRepo.setMealAvailability(
            mealId: 'meal_zinger_plate',
            isAvailable: false,
            actor: adminOlive,
          ),
          throwsA(isA<UnauthorizedAccessException>()),
        );
      },
    );
  });
}
