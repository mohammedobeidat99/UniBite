# UniBite GP1 – Screen & State Inventory

This inventory documents all screens, sheets, dialogs, snackbars, and states across all user roles for UniBite GP1.

---

## 1. Matrix Overview by Role

| Screen / Component | Route / Location | Student | Cafeteria Staff | Cafeteria Admin | System Admin | States Handled |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| **Splash Screen** | `/splash` | ✓ | ✓ | ✓ | ✓ | Initial, Animating, Navigating |
| **Intro / Onboarding** | `/intro` | ✓ | — | — | — | 3 Slides, Skip, Finish |
| **Campus Onboarding** | `/onboarding` | ✓ | — | — | — | University select, Campus select, Confirm |
| **Login Screen** | `/login` | ✓ | ✓ | ✓ | ✓ | Initial, Demo quick-fill chips, Loading, Error, Password visibility toggle |
| **Register Screen** | `/register` | ✓ | — | — | — | Form, Validation, Loading, Success dialog |
| **Password Reset** | `/reset-password` | ✓ | ✓ | ✓ | ✓ | Email input, Demo code `123456`, New password, Success |
| **Student Shell (Home)** | `/student` (Tab 0) | ✓ | — | — | — | Campus banner, Search, Category chips, Cafeteria cards, Empty, Pull-to-refresh |
| **Cafeteria Menu** | `/student/cafeteria/:id` | ✓ | — | — | — | Hero cover, Open/Closed pill, Category chips, Meal cards, Quick Add, Conflict Dialog |
| **Meal Details Sheet** | Modal Bottom Sheet | ✓ | — | — | — | Image, Allergens, Quantity Stepper, Note input, Add to Cart |
| **Cart & Checkout** | `/student` (Tab 1) | ✓ | — | — | — | Empty cart state, Item list, Pre-order time picker, Cash-at-pickup badge, Confirmation QR dialog |
| **Active Orders & History** | `/student` (Tab 2) | ✓ | — | — | — | Empty orders state, Active orders with live stepper & QR, Past orders history, Cancel order dialog |
| **Student Settings** | `/student` (Tab 3) | ✓ | — | — | — | Profile info, Language toggle (EN/AR), Campus re-selection, Sign Out |
| **Staff Live Board** | `/staff` | — | ✓ | ✓ | — | Screen Awake badge, Pending (audio alert & flash), Accepted, Preparing, Ready, Complete, Lookup sheet, Mute |
| **Walk-In Order Screen** | `/staff` / `/cafe-admin` | — | ✓ | ✓ | — | Category filter, Quantity counter, Cash total, Place order, QR modal |
| **Order QR Lookup** | Modal Bottom Sheet | — | ✓ | ✓ | — | Manual text code lookup, Scanned order details, Advance status |
| **Cafeteria Admin Web** | `/cafe-admin` | — | — | ✓ | — | NavigationRail (desktop) / Tabs (mobile), Live Board, Menu Manager, Hours & Settings, Staff Accounts |
| **Menu Manager Tab** | `/cafe-admin` (Tab 1) | — | — | ✓ | — | Meal list, Search, Toggle availability, Edit meal dialog, Add meal dialog, Delete confirm |
| **Hours & Settings Tab** | `/cafe-admin` (Tab 2) | — | — | ✓ | — | Working hours input, Order timeout picker (1-10 min), Save feedback |
| **Staff Accounts Tab** | `/cafe-admin` (Tab 3) | — | — | ✓ | — | Staff list, Add staff dialog, Deactivate staff, Role isolation |
| **System Admin Dashboard** | `/admin` | — | — | — | ✓ | Universities tab, Campuses tab, Cafeterias tab, Users tab, Create dialogs |

---

## 2. Standard State Coverage

Every dynamic list and form implements the complete 6-state resilience lifecycle:
1. **Loading State:** `UbSkeletonShimmer` or localized `CircularProgressIndicator` with test-environment protection.
2. **Empty State:** `EmptyStateView` with branded steam bowl artwork (`SteamEmptyIllustration`), localized title, and contextual subtitle.
3. **Error State:** `ErrorStateView` with localized message and retry action.
4. **Offline Mode:** Global top sticky banner `OfflineBanner` activated whenever `simulatedOfflineProvider` is toggled.
5. **Success State:** Tactile confirmation with `UbAnimatedCheck`, haptic feedback, and QR receipt.
6. **Disabled State:** Explicit contrast-compliant disabled tokens (`UniBiteColors.primary100`, `inkMuted`).
