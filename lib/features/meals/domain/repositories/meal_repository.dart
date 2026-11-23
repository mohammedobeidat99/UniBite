/// @docImport 'package:unibite/core/errors/app_exceptions.dart';
library;

import 'package:unibite/features/auth/domain/entities/app_user.dart';
import 'package:unibite/features/meals/domain/entities/meal.dart';

/// Contract for watching and managing cafeteria menu items.
abstract class MealRepository {
  /// Watches all meals for [cafeteriaId], optionally filtering when [availableOnly] is `true`.
  Stream<List<Meal>> watchMealsForCafeteria(
    String cafeteriaId, {
    bool availableOnly = false,
  });

  /// Watches all meals across cafeterias for student global search.
  Stream<List<Meal>> watchAllMeals();

  /// Fetches the current list of meals for [cafeteriaId].
  Future<List<Meal>> getMealsForCafeteria(String cafeteriaId);

  /// Creates or updates [meal] on behalf of [actor].
  ///
  /// Throws an [UnauthorizedAccessException] if [actor] is not a Cafeteria Admin
  /// owning `meal.cafeteriaId` (e.g., Cafeteria Staff are rejected).
  Future<Meal> saveMeal(Meal meal, {required AppUser actor});

  /// Updates availability for [mealId] to [isAvailable] on behalf of [actor].
  ///
  /// Throws an [UnauthorizedAccessException] if [actor] is not a Cafeteria Admin
  /// owning the meal's cafeteria.
  Future<Meal> setMealAvailability({
    required String mealId,
    required bool isAvailable,
    required AppUser actor,
  });

  /// Deletes [mealId] on behalf of [actor].
  ///
  /// Throws an [UnauthorizedAccessException] if [actor] is not a Cafeteria Admin
  /// owning the meal's cafeteria.
  Future<void> deleteMeal({required String mealId, required AppUser actor});
}
