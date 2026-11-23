# Universities Feature

Provides multi-university and multi-campus management for System Admins and onboarding lookup streams for students.

## Structure
- `domain/entities/`: `University`, `Campus`
- `domain/repositories/`: `UniversityRepository`
- `data/local/`: `LocalUniversityRepository` (enforces `UserRole.systemAdmin` write checks)
- `presentation/`: `SystemAdminDashboardScreen` (Universities, Campuses, Cafeterias & Owners, All Users)

## GP2 Firebase Migration
Implement `FirestoreUniversityRepository implements UniversityRepository` backed by `/universities` and `/campuses`.
