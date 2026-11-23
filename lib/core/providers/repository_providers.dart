import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unibite/core/database/local_storage_service.dart';
import 'package:unibite/core/design_system/tokens.dart';
import 'package:unibite/features/auth/data/local/local_auth_repository.dart';
import 'package:unibite/features/auth/domain/entities/app_user.dart';
import 'package:unibite/features/auth/domain/repositories/auth_repository.dart';
import 'package:unibite/features/cafeterias/data/local/local_cafeteria_repository.dart';
import 'package:unibite/features/cafeterias/domain/entities/cafeteria.dart';
import 'package:unibite/features/cafeterias/domain/repositories/cafeteria_repository.dart';
import 'package:unibite/features/meals/data/local/local_meal_repository.dart';
import 'package:unibite/features/meals/domain/entities/meal.dart';
import 'package:unibite/features/meals/domain/repositories/meal_repository.dart';
import 'package:unibite/features/orders/data/local/local_order_repository.dart';
import 'package:unibite/features/orders/domain/entities/order.dart';
import 'package:unibite/features/orders/domain/repositories/order_repository.dart';
import 'package:unibite/features/orders/domain/services/order_auto_reject_service.dart';
import 'package:unibite/features/universities/data/local/local_university_repository.dart';
import 'package:unibite/features/universities/domain/entities/campus.dart';
import 'package:unibite/features/universities/domain/entities/university.dart';
import 'package:unibite/features/universities/domain/repositories/university_repository.dart';
import 'package:unibite/features/users/data/local/local_user_repository.dart';
import 'package:unibite/features/users/domain/repositories/user_repository.dart';

/// Singleton [LocalStorageService] initialized in `main()` before `runApp`.
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError(
    'localStorageServiceProvider must be overridden with an initialized LocalStorageService.',
  );
});

/// Active authentication repository; swap to `FirebaseAuthRepository` in GP2.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return LocalAuthRepository(ref.watch(localStorageServiceProvider));
});

/// Active university and campus repository.
final universityRepositoryProvider = Provider<UniversityRepository>((ref) {
  return LocalUniversityRepository(ref.watch(localStorageServiceProvider));
});

/// Active cafeteria repository.
final cafeteriaRepositoryProvider = Provider<CafeteriaRepository>((ref) {
  return LocalCafeteriaRepository(ref.watch(localStorageServiceProvider));
});

/// Active meal menu repository.
final mealRepositoryProvider = Provider<MealRepository>((ref) {
  return LocalMealRepository(ref.watch(localStorageServiceProvider));
});

/// Active order repository.
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return LocalOrderRepository(ref.watch(localStorageServiceProvider));
});

/// Active administrative user repository.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return LocalUserRepository(ref.watch(localStorageServiceProvider));
});

/// Background auto-reject service polling every 30 seconds while the app runs.
final orderAutoRejectServiceProvider = Provider<OrderAutoRejectService>((ref) {
  final service = OrderAutoRejectService(
    ref.watch(orderRepositoryProvider),
    ref.watch(cafeteriaRepositoryProvider),
  );
  if (!UniBiteTokens.isTestEnvironment) {
    service.start();
  }
  ref.onDispose(service.stop);
  return service;
});

/// Reactive stream of the currently authenticated [AppUser].
final currentUserStreamProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).watchCurrentUser();
});

/// Current user value extracted synchronously for router guards and widgets.
final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(currentUserStreamProvider).valueOrNull ??
      ref.watch(localStorageServiceProvider).getSessionUser();
});

/// Whether simulated offline mode is enabled for demonstrating NFR-9 banners.
final simulatedOfflineProvider = StateProvider<bool>((ref) => false);

/// Riverpod notifier managing the active English/Arabic locale with Hive persistence.
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final storage = ref.watch(localStorageServiceProvider);
    return Locale(storage.getLocaleCode());
  }

  /// Switches the active application locale to [languageCode] (`'en'` or `'ar'`).
  Future<void> setLocale(String languageCode) async {
    final normalized = languageCode == 'ar' ? 'ar' : 'en';
    await ref.read(localStorageServiceProvider).setLocaleCode(normalized);
    state = Locale(normalized);
  }

  /// Toggles between English (`en`) and Arabic (`ar`).
  Future<void> toggleLocale() {
    return setLocale(state.languageCode == 'ar' ? 'en' : 'ar');
  }
}

/// Active [Locale] provider driving LTR/RTL directionality across the app.
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

/// Watches universities, optionally filtering to active universities.
final universitiesStreamProvider =
    StreamProvider.family<List<University>, bool>((ref, activeOnly) {
      return ref
          .watch(universityRepositoryProvider)
          .watchUniversities(activeOnly: activeOnly);
    });

/// Parameters for watching campuses filtered by university and active flag.
typedef CampusFilter = ({String? universityId, bool activeOnly});

/// Watches campus branches matching a [CampusFilter].
final campusesStreamProvider =
    StreamProvider.family<List<Campus>, CampusFilter>((ref, filter) {
      return ref
          .watch(universityRepositoryProvider)
          .watchCampuses(
            universityId: filter.universityId,
            activeOnly: filter.activeOnly,
          );
    });

/// Parameters for watching cafeterias filtered by campus and active flag.
typedef CafeteriaFilter = ({String? campusId, bool activeOnly});

/// Watches cafeterias matching a [CafeteriaFilter].
final cafeteriasStreamProvider =
    StreamProvider.family<List<Cafeteria>, CafeteriaFilter>((ref, filter) {
      return ref
          .watch(cafeteriaRepositoryProvider)
          .watchCafeterias(
            campusId: filter.campusId,
            activeOnly: filter.activeOnly,
          );
    });

/// Watches a single cafeteria by its identifier.
final cafeteriaByIdStreamProvider = StreamProvider.family<Cafeteria?, String>((
  ref,
  cafeteriaId,
) {
  return ref.watch(cafeteriaRepositoryProvider).watchCafeteriaById(cafeteriaId);
});

/// Watches all meals across all cafeterias (used for student global search).
final allMealsStreamProvider = StreamProvider<List<Meal>>((ref) {
  return ref.watch(mealRepositoryProvider).watchAllMeals();
});

/// Watches meals belonging to a single cafeteria.
final cafeteriaMealsStreamProvider = StreamProvider.family<List<Meal>, String>((
  ref,
  cafeteriaId,
) {
  return ref
      .watch(mealRepositoryProvider)
      .watchMealsForCafeteria(cafeteriaId, availableOnly: false);
});

/// Watches orders for a cafeteria scoped by the active authenticated user.
final cafeteriaOrdersStreamProvider =
    StreamProvider.family<List<Order>, String>((ref, cafeteriaId) {
      final actor = ref.watch(currentUserProvider);
      if (actor == null) return const Stream.empty();
      return ref
          .watch(orderRepositoryProvider)
          .watchOrdersForCafeteria(cafeteriaId, actor: actor);
    });

/// Watches orders placed by a student scoped by the active authenticated user.
final studentOrdersStreamProvider = StreamProvider.family<List<Order>, String>((
  ref,
  studentId,
) {
  final actor = ref.watch(currentUserProvider);
  if (actor == null) return const Stream.empty();
  return ref
      .watch(orderRepositoryProvider)
      .watchOrdersForStudent(studentId, actor: actor);
});

/// Watches users filtered by optional role or cafeteria scope.
typedef UserFilter = ({String? cafeteriaId});

/// Watches users matching a [UserFilter].
final usersStreamProvider = StreamProvider.family<List<AppUser>, UserFilter>((
  ref,
  filter,
) {
  return ref
      .watch(userRepositoryProvider)
      .watchUsers(cafeteriaId: filter.cafeteriaId);
});
