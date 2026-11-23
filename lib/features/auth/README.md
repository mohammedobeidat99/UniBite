# Auth Feature

Handles GP1 authentication, student registration, simulated email/reset verification (`123456`), student campus onboarding, and debug demo role switching.

## Structure
- `domain/entities/`: `UserRole`, `AppUser`
- `domain/repositories/`: `AuthRepository`
- `data/local/`: `LocalAuthRepository` (salted SHA-256 hashes via `PasswordHasher`)
- `presentation/`: `LoginScreen`, `RegisterScreen`, `ResetPasswordScreen`, `OnboardingScreen`

## GP2 Firebase Migration
Implement `FirebaseAuthRepository implements AuthRepository` and override `authRepositoryProvider` in `lib/core/providers/repository_providers.dart`.
