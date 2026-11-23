# UniBite – Design Critique & Pre-Redesign Audit

**Date:** 2026-11-23  
**Audit Scope:** Full Visual Layer (Mobile EN/AR + Web Dashboards)  
**Baseline Snapshots:** Saved in `docs/design/before/`  

---

## 1. Executive Summary

While the functional engine of UniBite GP1 (Phase 1) is rock-solid with zero defects and 100% test coverage, the visual design language in the baseline build is overly utilitarian, inconsistent in elevation and border styling, and lacks the appetizing, premium feel expected of modern consumer food apps (e.g., Talabat, Careem, Uber Eats, Deliveroo).

---

## 2. Screen-by-Screen Critique

### 1. Splash & Auth (Login, Register, Forgot Password)
- **Before Score:** 6.5 / 10
- **Deficiencies:**
  - Login card feels flat with standard greyish/greenish container borders.
  - Logo placement lacks energetic framing; missing subtle leaf brand accents and appetizing gradient flourishes.
  - Form fields use standard borders without floating labels or subtle soft-focus halos.
  - Primary button text lacks strong contrast pop against vibrant orange.
- **Redesign Actions:**
  - Establish deep `green900` + `green700` brand background with layered circular motifs.
  - Implement 20dp rounded input containers with 1px `outline` (`#E3EAE0`) and gentle focus transitions.
  - Primary button: Orange gradient with high-contrast `ink` bold typography.

### 2. Student Home (`student_home_screen.dart` / `student_shell_screen.dart`)
- **Before Score:** 6.0 / 10
- **Deficiencies:**
  - Campus hero header is plain text on a solid block rather than a lush, branded card with cafeteria search integration.
  - Search bar is detached from the header rather than overlapping smoothly (-26dp card overlap).
  - Category filter chips use basic rounded rectangles with harsh borders rather than smooth pill filters with count badges.
  - Cafeteria cards lack image framing, appetizing badges, or crisp status indicators (open/closed/prep time).
- **Redesign Actions:**
  - Redesign shell header with deep emerald green hero card, university selector, and floating overlapping search input.
  - Redesign cafeteria cards with 20dp border radius, soft multi-layer shadow, distinct wait-time badges, and rating stars.

### 3. Cafeteria Menu & Meal Details (`cafeteria_menu_screen.dart`)
- **Before Score:** 6.0 / 10
- **Deficiencies:**
  - Header is static and lacks modern collapsing app bar behavior with rich imagery.
  - Meal item cards are dense; price text does not pop; dietary badges (vegetarian, spicy) are plain text tags.
  - Bottom cart bar looks like a standard sticky button instead of a floating pill/card bar with live price breakdown.
  - Meal detail sheet looks like a generic dialog rather than a bottom sheet with quantity stepper and add-to-cart bar.
- **Redesign Actions:**
  - Rich meal card layout with thumbnail framing, 16/20 w800 price styling, and clean dietary icons.
  - Redesign bottom cart bar as a floating rounded container (28dp radius) with item counter badge and total price.

### 4. Cart & Checkout (`cart_screen.dart`)
- **Before Score:** 6.5 / 10
- **Deficiencies:**
  - Segmented control for pickup vs. pre-order looks like standard Flutter toggle buttons.
  - Order summary card lacks receipt-like separation (dashed divider, clear subtotal/tax/total hierarchy).
  - Quantity steppers are basic text buttons rather than soft tactile pill steppers.
- **Redesign Actions:**
  - Custom sliding pill segmented control with haptic tap feedback.
  - Clean order summary card with 1px outline, clear price breakdowns, and sticky checkout action.

### 5. Order Tracking & History (`student_orders_screen.dart`)
- **Before Score:** 6.0 / 10
- **Deficiencies:**
  - Order status stepper is generic and horizontal; active state doesn't have an animated circular prep ring.
  - QR pickup code is small and lacks a dedicated pickup card presentation.
- **Redesign Actions:**
  - Prominent order status card with circular progress prep indicator and clean timestamp badges.
  - High-contrast QR card with tap-to-expand modal and clear pickup instructions.

### 6. Staff Live Order Board (`live_order_board_widget.dart`)
- **Before Score:** 7.0 / 10
- **Deficiencies:**
  - Order cards use uniform outlines without clear 4px color-coded status strip indicators.
  - Auto-reject countdown timer uses plain text instead of an immediate circular countdown ring.
- **Redesign Actions:**
  - 4px status left border (orange for Pending, yellow for In Prep, green for Ready).
  - Circular determinate countdown ring in the top right for pending orders.
  - Distinct action buttons (Accept / Reject / Mark Ready).

### 7. Web Admin Dashboards (`cafeteria_admin_dashboard_screen.dart`, `system_admin_dashboard_screen.dart`)
- **Before Score:** 7.0 / 10
- **Deficiencies:**
  - Navigation drawer is standard light surface; doesn't feel like a high-density operations workstation.
  - Metric stat cards lack micro-trend badges and crisp icon containers.
- **Redesign Actions:**
  - Fixed 264px `green900` sidebar with crisp navigation icons, active indicator pills, and user profile badge.
  - Modern metric KPI cards with colored icon bubbles and elevated summary tables.

---

## 3. Systematic Redesign Plan

1. **Tokens & Theme Foundation:**
   - Define exact `AppColors` (70% green/canvas, 20% surface/ink, 10% orange accent).
   - Define `AppText` with Jakarta Sans / IBM Plex Sans Arabic.
   - Define `AppSpacing` (4-pt grid tokens, radii, shadows).
   - Define `AppLoader` (circular only, test-environment safe).
2. **Component Library:**
   - Standardize all cards, buttons, steppers, status pills, and empty states.
3. **Screen Restyling:**
   - Apply systematic component recipes across all mobile and web screens.
4. **Validation:**
   - Design linter script to enforce zero raw colors or ad-hoc styles.
   - Automated screenshots and scorecard rating >= 9/10 across all screens.
