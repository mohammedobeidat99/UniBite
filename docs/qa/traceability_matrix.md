# UniBite GP1 – Requirements Traceability Matrix (RTM)

This matrix maps every functional requirement (FR), non-functional requirement (NFR), and UX guideline to its verification test suites and implementation code.

---

## 1. Functional Requirements (FR) Traceability

| Req ID | Requirement Description | Implementation Reference | Automated Verification Test ID | Status |
| :--- | :--- | :--- | :--- | :---: |
| **FR-1** | Student authentication via University ID & salted password | `lib/features/auth/` | `local_repositories_test.dart`: Test 1-3 | **PASS** |
| **FR-2** | Student university & campus onboarding selection | `lib/features/auth/presentation/onboarding_screen.dart` | `end_to_end_flows_test.dart`: Flow 1 | **PASS** |
| **FR-3** | Browse active cafeterias scoped to enrolled campus | `lib/features/cafeterias/` | `end_to_end_flows_test.dart`: Flow 1 | **PASS** |
| **FR-4** | View cafeteria menu categorized with prices & availability | `lib/features/cafeterias/presentation/cafeteria_menu_screen.dart` | `design_system_and_screens_screenshot_test.dart`: Test 2 | **PASS** |
| **FR-5** | Single-cafeteria cart enforcement with conflict alert | `lib/features/cart/presentation/cart_notifier.dart` | `cart_and_checkout_widget_test.dart`: Test 2 | **PASS** |
| **FR-6** | Cash-at-pickup checkout & pre-order time slot selection | `lib/features/cart/presentation/cart_screen.dart` | `cart_and_checkout_widget_test.dart`: Test 2 | **PASS** |
| **FR-7** | Unique order number and dynamic QR code generation | `lib/features/orders/data/local/local_order_repository.dart` | `end_to_end_flows_test.dart`: Flow 1 | **PASS** |
| **FR-8** | Live order status progression (Pending → Accepted → Preparing → Ready → Completed) | `lib/features/orders/domain/services/order_status_validator.dart` | `order_status_validator_test.dart`: All Tests | **PASS** |
| **FR-9** | Student cancellation permitted only while in `pending` | `lib/features/orders/presentation/student_orders_screen.dart` | `local_repositories_test.dart`: Test 11 | **PASS** |
| **FR-10**| 3-minute auto-reject on unattended pending orders | `lib/features/orders/domain/services/order_auto_reject_service.dart` | `end_to_end_flows_test.dart`: Flow 3 | **PASS** |
| **FR-11**| Cafeteria order rejection with mandatory reason | `lib/features/orders/presentation/live_order_board_widget.dart` | `end_to_end_flows_test.dart`: Flow 2 | **PASS** |
| **FR-12**| Walk-in cash order placement by cafeteria staff/admin | `lib/features/orders/presentation/walk_in_order_view.dart` | `local_repositories_test.dart`: Test 11 | **PASS** |
| **FR-13**| Manual text and QR code order verification lookup | `lib/features/orders/presentation/qr_lookup_view.dart` | `local_repositories_test.dart`: Test 11 | **PASS** |
| **FR-14**| Cafeteria menu item management (add, edit, toggle availability) | `lib/features/cafeterias/presentation/cafeteria_admin_dashboard_screen.dart` | `local_repositories_test.dart`: Test 5 | **PASS** |
| **FR-15**| Cafeteria working hours & order timeout configuration | `lib/features/cafeterias/presentation/cafeteria_admin_dashboard_screen.dart` | `design_system_and_screens_screenshot_test.dart`: Test 3 | **PASS** |
| **FR-16**| Cafeteria staff account provisioning & access control | `lib/features/cafeterias/presentation/cafeteria_admin_dashboard_screen.dart` | `local_repositories_test.dart`: Test 5, 11 | **PASS** |
| **FR-17**| System Admin university & campus management | `lib/features/universities/presentation/system_admin_dashboard_screen.dart` | `end_to_end_flows_test.dart`: Flow 4 | **PASS** |
| **FR-18**| System Admin cafeteria creation and manager assignment | `lib/features/universities/presentation/system_admin_dashboard_screen.dart` | `end_to_end_flows_test.dart`: Flow 4 | **PASS** |
| **FR-19**| Role-based route guard and cross-cafeteria data isolation | `lib/core/router/app_router.dart` | `end_to_end_flows_test.dart`: Flow 5 | **PASS** |
| **FR-20**| Local mock data persistence via Hive reactive streams | `lib/core/database/local_storage_service.dart` | `local_repositories_test.dart`: Test 1 | **PASS** |

---

## 2. Non-Functional Requirements (NFR) Traceability

| Req ID | Requirement Description | Implementation Reference | Verification Evidence | Status |
| :--- | :--- | :--- | :--- | :---: |
| **NFR-1** | 60 fps smooth animations with reduced motion fallback | `lib/core/design_system/tokens.dart` | `design_system_and_screens_screenshot_test.dart`: Test 2 | **PASS** |
| **NFR-2** | Full offline resilience banner & local caching | `lib/core/widgets/offline_banner.dart` | Verified via `simulatedOfflineProvider` stream | **PASS** |
| **NFR-3** | Zero third-party backend dependency (100% Local Hive) | `lib/core/database/local_storage_service.dart` | Verified in all 7 test suites running with local temp dirs | **PASS** |
| **NFR-4** | Bi-directional localization (English LTR & Arabic RTL) | `lib/l10n/` & `lib/core/theme/app_theme.dart` | Snapshot tests 01-10 in EN and AR | **PASS** |
| **NFR-5** | WCAG 2.1 AA accessibility & 48 dp touch targets | `lib/core/design_system/` | `docs/qa/visual_audit.md` | **PASS** |
| **NFR-6** | Zero unhandled layout overflows on compact viewports | All feature views wrapped in `Flexible`/`Expanded` | 0 RenderFlex overflow errors across test suite | **PASS** |
| **NFR-7** | Strict 70/20/10 color palette & Lucide iconography | `lib/core/design_system/colors.dart` | `docs/qa/color_ratio_audit.md` | **PASS** |
