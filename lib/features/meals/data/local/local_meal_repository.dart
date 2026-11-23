import 'package:unibite/core/database/local_storage_service.dart';
import 'package:unibite/core/errors/app_exceptions.dart';
import 'package:unibite/features/auth/domain/entities/app_user.dart';
import 'package:unibite/features/auth/domain/entities/user_role.dart';
import 'package:unibite/features/meals/domain/entities/meal.dart';
import 'package:unibite/features/meals/domain/repositories/meal_repository.dart';

/// Hive-backed local implementation of [MealRepository].
class LocalMealRepository implements MealRepository {
  /// Creates a [LocalMealRepository] backed by [_storage].
  LocalMealRepository(this._storage);

  final LocalStorageService _storage;

  @override
  Stream<List<Meal>> watchMealsForCafeteria(
    String cafeteriaId, {
    bool availableOnly = false,
  }) {
    return _storage.watchMeals().map(
      (meals) => meals.where((meal) {
        if (meal.cafeteriaId != cafeteriaId) return false;
        if (availableOnly && !meal.isAvailable) return false;
        return true;
      }).toList(),
    );
  }

  @override
  Stream<List<Meal>> watchAllMeals() => _storage.watchMeals();

  @override
  Future<List<Meal>> getMealsForCafeteria(String cafeteriaId) async {
    return _storage
        .getMeals()
        .where((meal) => meal.cafeteriaId == cafeteriaId)
        .toList();
  }

  @override
  Future<Meal> saveMeal(Meal meal, {required AppUser actor}) async {
    _requireMenuPermission(actor, meal.cafeteriaId);

    if (meal.name.trim().isEmpty) {
      throw const ValidationException('Meal name cannot be empty.');
    }
    if (meal.price <= 0) {
      throw const ValidationException('Meal price must be greater than zero.');
    }

    final sanitized = meal.copyWith(
      name: meal.name.trim(),
      description: meal.description.trim(),
    );
    await _storage.putMeal(sanitized);
    return sanitized;
  }

  @override
  Future<Meal> setMealAvailability({
    required String mealId,
    required bool isAvailable,
    required AppUser actor,
  }) async {
    final matching = _storage.getMeals().where((m) => m.id == mealId).toList();
    if (matching.isEmpty) {
      throw const ValidationException('Meal not found.');
    }
    final existing = matching.first;
    _requireMenuPermission(actor, existing.cafeteriaId);

    final updated = existing.copyWith(isAvailable: isAvailable);
    await _storage.putMeal(updated);
    return updated;
  }

  @override
  Future<void> deleteMeal({
    required String mealId,
    required AppUser actor,
  }) async {
    final matching = _storage.getMeals().where((m) => m.id == mealId).toList();
    if (matching.isEmpty) {
      throw const ValidationException('Meal not found.');
    }
    final existing = matching.first;
    _requireMenuPermission(actor, existing.cafeteriaId);
    await _storage.deleteMeal(mealId);
  }

  void _requireMenuPermission(AppUser actor, String cafeteriaId) {
    final isSystemAdmin = actor.role == UserRole.systemAdmin;
    final isOwningAdmin =
        actor.role == UserRole.cafeteriaAdmin &&
        actor.cafeteriaId == cafeteriaId;
    if (!actor.isActive || (!isSystemAdmin && !isOwningAdmin)) {
      throw const UnauthorizedAccessException(
        'Only the Cafeteria Admin of this cafeteria can edit meals or prices.',
      );
    }
  }
}
