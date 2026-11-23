# UniBite GP1 Comprehensive QA Test Plan (`docs/qa/test_plan.md`)

## 1. Scope & Objectives
Verify all **GP1 Functional Requirements (FR-1 – FR-24, FR-51, FR-52)**, **Non-Functional Requirements (NFR-1 – NFR-9)**, **Design System & Color Ratio Rules (70/20/10, WCAG AA)**, **Motion System (60 fps, reduce-motion)**, **Bilingual RTL/LTR (Arabic & English)**, **Responsiveness (360×640 mobile through 1920px desktop web)**, and **End-to-End Integration Flows**.

## 2. Test Environments
- **Automated Dart/Flutter Test Runner (`flutter test`):** Unit, Widget, Golden, and End-to-End Flow Integration tests against real Hive temporary directories and Mockito nice mocks.
- **Responsive Viewport Matrix:**
  - Compact Mobile: `360 × 640`, `412 × 915`
  - Tablet Counter KDS: `840 × 1080`
  - Desktop Web Dashboard: `1280 × 800`, `1920 × 1080`
- **Locales:** English (`en`, LTR) and Arabic (`ar`, RTL) + 200% text scaling.

---

## 3. Requirement-to-Test Case Traceability Plan

| Req ID | Requirement Summary | Planned Test Cases |
|---|---|---|
| **FR-1** | Student register, login, logout, password reset (`123456`, salted hash) | `TC-AUTH-01`, `TC-AUTH-02`, `TC-AUTH-03`, `TC-AUTH-04` |
| **FR-2** | Simulated email/reset verification code `123456` | `TC-AUTH-02`, `TC-AUTH-03` |
| **FR-3** | Single role per user + router guards & privilege escalation block | `TC-SEC-01`, `TC-SEC-02`, `TC-SEC-03` |
| **FR-4** | System Admin creates/approves Cafeteria Admin accounts | `TC-SYS-03` |
| **FR-5** | Universities & campuses CRUD + deactivate; 1 campus per cafeteria | `TC-SYS-01`, `TC-SYS-02` |
| **FR-6** | Student onboarding campus selection; sees only selected campus cafeterias | `TC-ONB-01`, `TC-BROWSE-01` |
| **FR-7** | Cafeteria list with working hours & computed Open/Closed badge | `TC-BROWSE-01`, `TC-BROWSE-02` |
| **FR-8** | Menu by category with image, description, price | `TC-BROWSE-03` |
| **FR-9** | Search by cafeteria/meal name & category filter | `TC-BROWSE-04` |
| **FR-10** | Cafeteria Admin CRUD meals (name, price, image, category, description) | `TC-MENU-01` |
| **FR-11** | Mark meal available/unavailable; unavailable cannot be ordered | `TC-MENU-02`, `TC-CART-03` |
| **FR-12** | Cafeteria Admin sets working hours & timeouts; scoped to own cafeteria | `TC-MENU-03`, `TC-SEC-03` |
| **FR-13** | Cafeteria Admin creates Cafeteria Staff; staff cannot edit menu/hours/staff | `TC-STAFF-01`, `TC-SEC-02` |
| **FR-14–FR-18** | Cart (qty, note, edit/remove, undo), itemized total, ASAP/pre-order, single-cafeteria/closed blocks, cash & self-pickup only | `TC-CART-01`, `TC-CART-02`, `TC-CART-03`, `TC-CART-04`, `TC-CART-05` |
| **FR-19–FR-24** | Live 3-column board, sound/visual alert, accept/reject with reason, Preparing→Ready→Completed, auto-reject, walk-in, student cancel pending only, QR lookup | `TC-ORD-01`, `TC-ORD-02`, `TC-ORD-03`, `TC-ORD-04`, `TC-ORD-05`, `TC-ORD-06` |
| **FR-51, FR-52** | System Admin user activate/deactivate; approve/suspend cafeterias & owners | `TC-SYS-04`, `TC-SYS-05` |
| **NFR-1–NFR-9** | Auth speed & salted hash, data-entry uni add, local stream speed, AR/EN RTL, repository isolation, wake-lock & offline banner | `TC-NFR-01` through `TC-NFR-06` |
| **UX / Design / A11y** | 70/20/10 tokens, WCAG AA contrast, reduce-motion, 200% text scale, golden AR/EN snapshots, 5 usability tasks | `TC-UX-01` through `TC-UX-05`, `TC-USAB-01`–`TC-USAB-05` |
