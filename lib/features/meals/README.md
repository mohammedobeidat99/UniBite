# Meals Feature

Handles menu items (`Meal`), availability toggling, image selection (bundled presets + `image_picker` base64 storage), and real-time menu streaming to students.

## Structure
- `domain/entities/`: `Meal`
- `domain/repositories/`: `MealRepository`
- `data/local/`: `LocalMealRepository` (rejects `CafeteriaStaff` and non-owning admins)

## GP2 Firebase Migration
Implement `FirestoreMealRepository implements MealRepository` backed by `/meals` and Firebase Storage for uploaded images.
