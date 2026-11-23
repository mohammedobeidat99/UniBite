# UniBite GP1 QA Test Execution Report (`docs/qa/test_report.md`)

## 1. Executive Summary
- **Execution Date:** 2026-11-22
- **Build Scope:** UniBite GP1 (Student Mobile + Web Dashboards + Design System + Motion + AR/EN RTL)
- **Automated Test Suites:**
  - `test/domain/order_status_validator_test.dart` (Unit — order state machine & actor scopes)
  - `test/services/order_auto_reject_mock_test.dart` (Unit — Mockito nice mocks for `OrderAutoRejectService`)
  - `test/data/local_repositories_test.dart` (Unit — Hive local repositories, salted password hashing, validation, scoping)
  - `test/integration/end_to_end_flows_test.dart` (Integration — 5 complete multi-role end-to-end flows)
  - `test/presentation/cart_and_checkout_widget_test.dart` (Widget — cart, single-cafeteria rule, pre-order, cash checkout)
  - `test/presentation/app_shell_smoke_test.dart` (Widget — Splash → Intro → Login → Student Home navigation)
  - `test/presentation/design_system_and_screens_screenshot_test.dart` (Widget + Golden + Screenshot export in EN & AR, `360x640` mobile, `1280x800` desktop web, reduce-motion, scaled text)
- **Open Critical/Major Bugs:** `0` (`BUG-001` through `BUG-005` fixed and closed in `docs/qa/bug_log.md`).

---

## 2. Requirement Traceability Matrix (FR-1–FR-24, FR-51/52, NFR-1–NFR-9)

| Req ID | Test Case ID | Role | Preconditions | Steps | Expected & Actual Result | Status | Evidence |
|---|---|---|---|---|---|---|---|
| **FR-1, FR-2** | `TC-AUTH-01`..`04` | Student / All | Seeded Hive store | Register student with valid/invalid email, weak pass, wrong code `000000` vs `123456`; login right/wrong; reset password; logout. | Wrong inputs & code `000000` rejected; valid `123456` creates salted SHA-256 hash & resets password; login/logout succeed. | **Pass** | `local_repositories_test.dart`, `01_login_en.png` |
| **FR-3, FR-4** | `TC-SEC-01`..`03` | All Roles | Signed-in accounts per role | Attempt cross-role routing, staff editing meals/hours/staff, Cafeteria A admin editing Cafeteria B meals. | Router guards isolate routes; `UnauthorizedAccessException` thrown in repository layer for all escalation attempts. | **Pass** | `end_to_end_flows_test.dart`, `local_repositories_test.dart` |
| **FR-5, FR-6, NFR-3** | `TC-SYS-01`..`03`, `TC-ONB-01` | System Admin, Student | System Admin signed in | Create new university (HTU), branch campus, cafeteria, and Cafeteria Admin by data entry; student picks campus at onboarding. | Added without code changes; student onboarding saves university/campus and shows only that campus's cafeterias. | **Pass** | `end_to_end_flows_test.dart`, `09_system_admin_dashboard_web_en.png` |
| **FR-7, FR-8, FR-9** | `TC-BROWSE-01`..`04` | Student | Campus selected | View cafeteria list with hours & open/closed pill, filter by category, search cafeteria/meal names. | Open/closed computed dynamically; search & category filters return matching campus items; closed cafeterias muted. | **Pass** | `03_student_home_en.png`, `04_student_home_ar.png`, `05_cafeteria_menu_en.png` |
| **FR-10, FR-11, FR-12, NFR-6** | `TC-MENU-01`..`03` | Cafeteria Admin | Admin signed in | CRUD meals, toggle availability, update working hours (`HH:mm-HH:mm`) & timeout; observe student stream. | Student streams reflect availability & hours immediately; staff blocked from edits. | **Pass** | `local_repositories_test.dart`, `07_cafeteria_dashboard_web_en.png` |
| **FR-13** | `TC-STAFF-01` | Cafeteria Admin / Staff | Admin creates Staff | Create `CafeteriaStaff` user; verify staff dashboard tabs and repository rejections. | Staff sees only Live Board, Walk-In, QR Lookup; meal/hour/staff edits throw `UnauthorizedAccessException`. | **Pass** | `end_to_end_flows_test.dart`, `CafeteriaStaffDashboardScreen` |
| **FR-14–FR-18, NFR-7** | `TC-CART-01`..`05` | Student | Active menu loaded | Add items with notes, update qty, swipe-to-remove + undo, mix cafeterias, add unavailable meal, order closed cafeteria, ASAP vs pre-order, cash checkout. | Single-cafeteria rule enforced; unavailable & closed blocked; total exact; payment = `'cash'` self-pickup only. | **Pass** | `cart_and_checkout_widget_test.dart`, `local_repositories_test.dart` |
| **FR-19–FR-24, NFR-8, NFR-9** | `TC-ORD-01`..`06` | Staff, Admin, Student | Pending, preparing, ready orders | Monitor 3-column board + pulsing ring/sound alert + mute; reject with reason; progress Preparing→Ready→Completed; auto-reject at `2:59` vs `3:00`; walk-in; QR lookup; student cancel pending only; offline banner. | All transitions validated by `OrderStatusValidator`; auto-reject triggers at `>= timeout` (`"No response"`); QR & walk-in work; student cancels only while pending. | **Pass** | `order_status_validator_test.dart`, `order_auto_reject_mock_test.dart`, `06_student_orders_en.png`, `07_cafeteria_dashboard_web_en.png` |
| **FR-51, FR-52** | `TC-SYS-04`, `TC-SYS-05` | System Admin | Seeded users & cafeterias | Filter users by role, toggle user active state, suspend/approve cafeterias & owners. | Deactivated user blocked from login; suspended cafeteria hidden from students. | **Pass** | `local_repositories_test.dart`, `09_system_admin_dashboard_web_en.png` |
| **NFR-1, NFR-2, NFR-4, NFR-5** | `TC-NFR-01`..`06` | All | Local Hive DB | Inspect `passwordHash` values, switch EN/AR mid-session, test RTL mirroring, verify offline banner & local speed. | All passwords stored as `salt$sha256`; UI mirrors cleanly in AR/RTL (`02_login_ar.png`, `04_student_home_ar.png`, `08_cafeteria_dashboard_web_ar.png`). | **Pass** | `design_system_and_screens_screenshot_test.dart` |

---

## 3. Usability Test Scenarios (5 Core Student Tasks)

| Task ID | Scenario | Target Taps / Time | Observed Friction & Fix | Result |
|---|---|---|---|---|
| **USAB-01** | Find an open cafeteria on campus | ≤ 2 taps / < 5 s | Added dedicated `"Open now"` section with yellow accent dot at top of Home. | **Pass** |
| **USAB-02** | Order a meal with a note (repeat flow) | ≤ 4 taps / < 15 s | Added quick `+` button on meal cards + sticky bottom cart bar + 1-tap `Place Cash Order`. | **Pass** |
| **USAB-03** | Schedule a pre-order for a break slot | ≤ 5 taps / < 20 s | Added segmented `Order Now` / `Pre-Order` toggle + time picker validated against working hours. | **Pass** |
| **USAB-04** | Track order status & present pickup QR | ≤ 2 taps / < 4 s | Plain-language stepper copy (`"Ready — show your QR at counter"`) + instant QR card on Orders tab. | **Pass** |
| **USAB-05** | Cancel a pending order before acceptance | ≤ 3 taps / < 6 s | Red `Cancel Order` outlined pill visible exclusively on `pending` orders with confirmation dialog. | **Pass** |

---

## 4. Non-Functional, Accessibility, Responsive & Visual Audits
- **Color Tokens & Ratio Audit (`70 / 20 / 10`):** Verified zero raw `Color(0x...)` literals outside `lib/core/design_system/colors.dart`; all text pairings meet WCAG AA (`docs/design/contrast.md`).
- **Golden Snapshots:** `test/goldens/design_system_card_en.png` and `test/goldens/design_system_card_ar.png` verify bilingual rendering of core pill, stepper, and orange CTA components.
- **Responsive & Accessibility:** Verified `360×640` mobile (including `1.5×` text scaling & `disableAnimations: true` reduce-motion), `412×915` phone, and `1280×800` web dashboards (EN & AR) with zero layout overflows after `BUG-005` fix.
- **Screenshots Exported:** All 10 rendered UI screenshots saved under `docs/screenshots/`.
