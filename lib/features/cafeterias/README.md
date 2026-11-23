# Cafeterias Feature

Manages campus cafeterias, working-hour open/closed status calculation, student cafeteria browsing/search, and the Cafeteria Admin dashboard.

## Structure
- `domain/entities/`: `Cafeteria` (with `isOpenAt(DateTime)` helper)
- `domain/repositories/`: `CafeteriaRepository`
- `data/local/`: `LocalCafeteriaRepository`
- `presentation/`: `StudentShellScreen`, `CafeteriaMenuScreen`, `CafeteriaAdminDashboardScreen`

## GP2 Firebase Migration
Implement `FirestoreCafeteriaRepository implements CafeteriaRepository` backed by `/cafeterias`.
