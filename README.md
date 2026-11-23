# UniBite — GP1 (Phase 1)

**Your Campus, Your Food, Your Way.**

UniBite is a multi-university campus food-ordering platform built with **Flutter (Dart, null-safe)** using a single feature-first codebase with role-based routing across a mobile-first **Student UI** and responsive **Web Dashboards** (System Admin, Cafeteria Admin, Cafeteria Staff).

---

## 1. Tech Stack & Packages

- **Framework:** Flutter 3.38+ / Dart 3.10+ (Null-safe, Material 3)
- **State Management & DI:** `flutter_riverpod` (`^2.6.1`)
- **Navigation & Role Guards:** `go_router` (`^14.6.2`)
- **Localization & RTL:** `flutter_localizations`, `intl` (English LTR + Arabic RTL via `lib/l10n/app_en.arb` & `lib/l10n/app_ar.arb`)
- **Local Persistence (GP1 Mock Backend):** `hive` (`^2.2.3`), `hive_flutter` (`^1.1.0`)
- **Security Hashing:** `crypto` (`^3.0.6`) for salted SHA-256 password hashes (`<salt>$<digest>`)
- **Media, QR & Utilities:** `image_picker`, `qr_flutter`, `uuid`, `equatable`
- **Testing:** `flutter_test`, `mockito` (`^5.4.4`), `build_runner`
- **Zero Backend / Zero Firebase in GP1:** No Firebase packages are included in `pubspec.yaml`.

---

## 2. Project Folder Structure

```text
lib/
├── main.dart
├── l10n/
│   ├── app_en.arb
│   ├── app_ar.arb
│   └── app_localizations*.dart
├── core/
│   ├── database/
│   │   ├── local_storage_service.dart
│   │   └── seed_data.dart
│   ├── errors/app_exceptions.dart
│   ├── l10n/l10n_extensions.dart
│   ├── providers/repository_providers.dart
│   ├── router/app_router.dart
│   ├── theme/app_theme.dart
│   ├── utils/password_hasher.dart
│   └── widgets/
│       ├── demo_control_bar.dart
│       ├── meal_image_widget.dart
│       ├── offline_banner.dart
│       ├── state_views.dart
│       └── unibite_logo.dart
└── features/
    ├── auth/{data/local, domain/{entities, repositories}, presentation, README.md}
    ├── universities/{data/local, domain/{entities, repositories}, presentation, README.md}
    ├── cafeterias/{data/local, domain/{entities, repositories}, presentation, README.md}
    ├── meals/{data/local, domain/{entities, repositories}, presentation, README.md}
    ├── cart/{domain/entities, presentation, README.md}
    ├── orders/{data/local, domain/{entities, repositories, services}, presentation, README.md}
    └── users/{data/local, domain/repositories, presentation, README.md}
docs/
└── future_firebase_rules.md
test/
├── domain/order_status_validator_test.dart
├── services/{order_auto_reject_mock_test.dart, order_auto_reject_mock_test.mocks.dart}
├── data/local_repositories_test.dart
└── presentation/cart_and_checkout_widget_test.dart
```

---

## 3. Running the App

### Prerequisites
- Flutter SDK `>= 3.38.0`

### Install Dependencies & Generate Localizations
```sh
flutter pub get
flutter gen-l10n
```

### Run on Web (Recommended for Demo Mode & Dashboards)
```sh
flutter run -d chrome
```
*(In release mode, pass `--dart-define=DEMO_MODE=true` to keep the debug Switch Role bar enabled.)*

### Run on Mobile (Android / iOS)
```sh
flutter run
```

### Static Analysis & Automated Tests
```sh
dart analyze
flutter test
```

---

## 4. Seed Data & Demo Credentials

On first run (and whenever **Reset Demo** is tapped in the demo toolbar), Hive is seeded with:
- **2 Universities:** JUST, The University of Jordan (UJ)
- **4 Campuses:** JUST Main Campus, JUST Medical City Branch, UJ Amman Main Campus, UJ Aqaba Branch
- **3 Cafeterias:** Green Olive Grill (`JUST Main`), EngBites Express (`JUST Main`), Campus Roastery & Bakery (`UJ Main`)
- **10 Meals:** Across Sandwiches, Hot Meals, Salads, Beverages, and Desserts (including 1 unavailable meal for validation demos)
- **3 Sample Orders:** `UB-1001` (`ready`), `UB-1002` (`preparing`), `UB-1003` (`accepted`, walk-in)

| Role | Email | Password | Assigned Scope |
|---|---|---|---|
| **Student** | `student@just.edu.jo` | `Student@123` | JUST Main Campus |
| **Cafeteria Admin (1)** | `admin.olive@just.edu.jo` | `Cafe@123` | Green Olive Grill |
| **Cafeteria Admin (2)** | `admin.engbites@just.edu.jo` | `Cafe@123` | EngBites Express |
| **Cafeteria Admin (3)** | `admin.roastery@uj.edu.jo` | `Cafe@123` | Campus Roastery & Bakery |
| **Cafeteria Staff** | `staff.olive@just.edu.jo` | `Staff@123` | Green Olive Grill |
| **System Admin** | `sysadmin@unibite.edu` | `Admin@123` | Platform-wide |

- **Simulated Email Verification / Password Reset Code:** `123456`
- **Demo Mode Bar:** Visible in debug/demo builds to switch roles in 1 click, toggle AR/EN, toggle the simulated offline banner, trigger an immediate auto-reject sweep, or reset demo data.

---

## 5. Replacing Local Repositories with Firebase in GP2

Every feature defines an abstract repository interface in `domain/repositories/` and injects its concrete implementation through Riverpod in `lib/core/providers/repository_providers.dart`.

To migrate to Firebase in GP2 **without modifying any UI or domain code**:
1. Add `firebase_core`, `firebase_auth`, `cloud_firestore`, and `firebase_storage`.
2. Implement `FirebaseAuthRepository`, `FirestoreUniversityRepository`, `FirestoreCafeteriaRepository`, `FirestoreMealRepository`, `FirestoreOrderRepository`, and `FirestoreUserRepository` under `lib/features/<feature>/data/firebase/`.
3. Swap the 6 provider factories in `lib/core/providers/repository_providers.dart` to return the Firebase implementations.
4. Deploy the equivalent security rules documented in [docs/future_firebase_rules.md](docs/future_firebase_rules.md) and schedule `OrderAutoRejectService.runSweep()` as a Cloud Function.

---

## 6. GP1 Requirement Traceability Matrix

| ID | Description | Implementation Location |
|---|---|---|
| **FR-1, FR-2** | Register, login, logout, password reset (`123456` demo code, salted SHA-256 hash) | `LocalAuthRepository`, `PasswordHasher`, `LoginScreen`, `RegisterScreen`, `ResetPasswordScreen` |
| **FR-3, FR-4** | Single `AppUser.role`, router guards, System Admin creates/approves Cafeteria Admins | `UserRole`, `app_router.dart`, `LocalUserRepository`, `SystemAdminDashboardScreen` |
| **FR-5, FR-6, NFR-3** | Universities & campuses CRUD + deactivate by data entry; student campus onboarding | `LocalUniversityRepository`, `SystemAdminDashboardScreen`, `OnboardingScreen` |
| **FR-7–FR-9** | Cafeteria list with computed open/closed status, menu categories, search & filter | `Cafeteria.isOpenAt`, `StudentShellScreen`, `CafeteriaMenuScreen` |
| **FR-10–FR-12, NFR-6** | Cafeteria Admin CRUD meals, image upload, availability toggle, working hours, reactive streams | `LocalMealRepository`, `LocalCafeteriaRepository`, `CafeteriaAdminDashboardScreen` |
| **FR-13** | Cafeteria Admin creates Cafeteria Staff restricted strictly to order handling | `LocalUserRepository.createCafeteriaStaff`, `CafeteriaStaffDashboardScreen` |
| **FR-14–FR-18, NFR-7** | Cart, notes, itemized total, ASAP/pre-order, single-cafeteria/availability/closed guards, cash & self-pickup only | `CartNotifier`, `CartScreen`, `LocalOrderRepository.placeStudentOrder` |
| **FR-19–FR-24, NFR-8, NFR-9** | Live 3-column order board, repeating sound/visual alert, accept/reject with reason, auto-reject service, walk-in, QR lookup, student cancel while pending, wake lock badge, offline banner | `LiveOrderBoardWidget`, `OrderStatusValidator`, `OrderAutoRejectService`, `WalkInOrderView`, `QrLookupView`, `StudentOrdersScreen`, `OfflineBanner` |
| **FR-51, FR-52** | System Admin list/activate/deactivate any user; create/approve/suspend cafeterias & owners | `SystemAdminDashboardScreen`, `LocalUserRepository`, `LocalCafeteriaRepository` |
| **NFR-1, NFR-2, NFR-4, NFR-5** | Instant local auth, hashed passwords, cached local Hive streams, AR (RTL) & EN (LTR) localization | `LocalStorageService`, `app_en.arb`, `app_ar.arb`, `LocaleNotifier` |
