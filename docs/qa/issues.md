# UniBite GP1 – Comprehensive Defect & Fix Log

This log documents all defects identified during functional and visual audits, including root cause analyses, engineering resolutions, and automated regression re-test verifications.

---

## 1. Summary of Logged Issues

| Defect ID | Severity | Component | Summary | Status | Verified In |
| :--- | :--- | :--- | :--- | :---: | :--- |
| **BUG-001** | Critical | Router / Global | DemoControlBar Overlay crash & RenderFlex overflow in MaterialApp.builder | **FIXED** | Removed per user request |
| **BUG-002** | Major | Localization | `mealCategoryLabel` shadowed ARB extension method | **FIXED** | `lib/core/l10n/l10n_extensions.dart` |
| **BUG-003** | Major | Typography | Arabic Medium font asset truncated (24KB corrupted) | **FIXED** | Re-downloaded full 224KB font |
| **BUG-004** | Minor | Theme | Inline hardcoded colors in presentation widgets | **FIXED** | Refactored to `UniBiteColors.*` |
| **BUG-005** | Major | Presentation | 2.0px RenderFlex overflow in `CafeteriaMenuScreen` on compact mobile | **FIXED** | Replaced SliverPersistentHeader with intrinsic SliverToBoxAdapter |
| **BUG-006** | Critical | Auth / Shell | Black screen + skeleton shimmer card hang upon user logout | **FIXED** | Return `LoginScreen` synchronously on null user |
| **BUG-007** | Critical | Navigation | Duplicate Hero tags (`<default FloatingActionButton tag>`) in IndexedStack | **FIXED** | Set `heroTag: null` on all extended FABs |
| **BUG-008** | Major | Design System | 46-48px horizontal overflow in `UbSecondaryButton` on small screens | **FIXED** | Wrapped label in `Flexible` with ellipsis |
| **BUG-009** | Major | Testing / Data | Non-deterministic user sorting in `debugSwitchRole` picked wrong cafeteria admin | **FIXED** | Added optional `cafeteriaId` filter & deterministic sort |
| **BUG-010** | Major | Presentation | 90px horizontal overflow on cafeteria working hours row | **FIXED** | Wrapped text in `Expanded` with ellipsis |
| **BUG-011** | Critical | Animations | Infinite 500ms timer loop in `SplashScreen.build()` when `reduceMotion` was active | **FIXED** | Removed `addPostFrameCallback` from `build()`; set 50ms duration |
| **BUG-012** | Major | Design System | Stepper pulsing animation loop kept widget test runners active | **FIXED** | Added `!UniBiteTokens.isTestEnvironment` guard |
| **BUG-013** | Major | Services | OrderAutoRejectService periodic timer prevented test isolate exit | **FIXED** | Added `!UniBiteTokens.isTestEnvironment` before `service.start()` |
| **BUG-014** | Minor | Services | Platform channel stall on audio beep in headless test runners | **FIXED** | Guarded `SystemSound.play` with test check |
| **BUG-015** | Major | Database | Hive singleton lock conflict across multi-test isolate lifecycles | **FIXED** | Switched test suites to `setUpAll` for `storage.init()` |
| **BUG-016** | Major | Presentation | `LayoutBuilder does not support returning intrinsic dimensions` in AlertDialog | **FIXED** | Wrapped `QrImageView` in bounded `SizedBox` |

---

## 2. Detailed Technical Post-Mortems

### BUG-005: 2.0px RenderFlex Overflow in CafeteriaMenuScreen
- **Root Cause:** A fixed `SliverPersistentHeaderDelegate` used an exact `maxExtent` of `104.0 dp` with rigid vertical padding, which overflowed by 2.0 pixels on compact viewports (`328 dp` available width).
- **Fix:** Converted the persistent header into an intrinsic `SliverToBoxAdapter` containing an auto-sizing `Column`.
- **Re-test Evidence:** `renders Student Home, Menu & Orders cleanly at 360x640, scaled text & reduce-motion` passed with 0 layout overflow warnings.

### BUG-006: Shimmer Skeleton Hang on Sign Out
- **Root Cause:** When `ref.read(authRepositoryProvider).logout()` cleared the active session in Hive, `currentUserProvider` emitted `null`. The student shell continued displaying an active loading state that rebuilt skeleton placeholders indefinitely.
- **Fix:** In `StudentShellScreen.build()`, immediately return `const LoginScreen()` synchronously when `currentUserProvider == null`.
- **Re-test Evidence:** `app_shell_smoke_test.dart` verifies full login -> student dashboard -> settings -> sign out -> clean return to login screen.

### BUG-016: LayoutBuilder Intrinsic Dimensions Error in AlertDialog
- **Root Cause:** `QrImageView` internally utilizes a `LayoutBuilder` to determine canvas dimensions. When placed directly inside the `content` of an `AlertDialog`, Flutter's dialog layout measures intrinsic dimensions across its children, triggering `_RenderLayoutBuilder._debugThrowIfNotCheckingIntrinsics`.
- **Fix:** Wrapped the dialog content `Column` and `QrImageView` inside an explicit `SizedBox(width: 280)` and `SizedBox(width: 140, height: 140)`.
- **Re-test Evidence:** `cart_and_checkout_widget_test.dart` places a cash order, displays the QR confirmation modal, dismisses cleanly, and passes 100%.
