# UniBite GP1 – Evaluator Demonstration Script

Follow this step-by-step walkthrough to demonstrate the full functional, visual, and architectural capabilities of UniBite GP1.

---

## 1. Demo Credentials Reference

All seeded accounts use the password: `Password123!`

| Role | Name | Email | Associated Entity | Quick-Fill Chip |
| :--- | :--- | :--- | :--- | :---: |
| **Student** | Sarah Al-Majali | `student.sarah@unibite.edu` | JUST – Main Campus | `Student` |
| **Cafeteria Staff** | Zaid Mansoor | `staff.zaid@unibite.edu` | Green Olive Grill | `Staff` |
| **Cafeteria Admin** | Rami Haddad | `cafe.admin@unibite.edu` | Green Olive Grill | `Cafe Admin` |
| **System Admin** | Tariq Al-Mansoor | `sysadmin@unibite.edu` | Global Platform | `Sys Admin` |

---

## 2. Step-by-Step Evaluator Script

### Step 1: Launch & Splash Screen (NFR-1)
1. Run `flutter run -d chrome` or launch on an Android/iOS device.
2. Observe the custom animated brand mark: green graduation cap & fork inside the stylized 'U', orange swoosh curve, and fresh leaf badge.
3. Automatically transitions to the 3-slide introduction onboarding carousel.
4. Tap **Skip** or swipe through all 3 slides and tap **Get Started**.

### Step 2: Student Sign-In & Hero Header (FR-1, FR-2)
1. On the Login screen, tap the **Student** demo quick-fill chip. Notice the password field is auto-populated and can be toggled via the eye icon.
2. Tap **Sign In**.
3. View the Student Home Shell:
   - Green Swoosh Hero Banner with personalized greeting: *"Welcome, Sarah"*.
   - Active campus badge: *"Main Campus (Al-Ramtha)"*.
   - Category filtering chips: *All, Sandwiches, Hot Meals, Salads, Beverages, Desserts*.

### Step 3: Browse Menu & Single-Cafeteria Cart Enforcement (FR-3, FR-4, FR-5)
1. Tap on **Green Olive Grill**.
2. Notice the collapsing dark green cover with the live **Open** status pill.
3. Tap on **Falafel Supreme Sandwich**; view the bottom sheet with allergen disclosures and quantity counter. Tap **Add to Cart**.
4. Tap the back button; scroll down and select **EngBites Express**.
5. Tap Quick Add on **Crispy Zinger Plate**.
6. **Observe Conflict Dialog:** *"Clear existing cart from Green Olive Grill?"* (Proves FR-5 single-cafeteria enforcement). Tap **Cancel**.

### Step 4: Checkout & Dynamic QR Code Generation (FR-6, FR-7)
1. Tap the **Sticky Cart Bar** at the bottom of the screen.
2. In the Cart screen:
   - Notice the prominent badge: **Payment: Cash at Pickup Only** (Proves GP1 scope boundaries).
   - Test the quantity stepper (`+` / `-`).
   - Switch between **Order Now (ASAP)** and **Pre-Order for Pickup Time**.
3. Tap **Place Cash Order**.
4. Observe the animated green checkmark modal, order number (`UB-1004`), and high-resolution pickup QR code. Tap **Close**.

### Step 5: Live Order Progression & Tracking (FR-8, FR-9)
1. The student is navigated automatically to the **Orders** tab.
2. Notice the order is in **Pending** status with the pulsating orange stepper.
3. Tap **Cancel Order** to observe the student self-cancellation capability while pending.

### Step 6: Cafeteria Staff & Live Order Board (FR-8, FR-11, FR-12, FR-13)
1. Switch to the Staff account by navigating to **Settings** → **Sign Out**, then tap the **Staff** chip and tap **Sign In**.
2. View the 4-Column Live Kanban Board:
   - **Pending:** Audio beep alert active, visual card flash.
   - Tap **Accept** → order transitions into **Preparing**.
   - Tap **Mark Ready** → confetti sparkles appear, order moves to **Ready**.
   - Student shows their QR code; staff taps **Scan / Enter Pickup Code**, enters or scans the QR code, and completes the order.

### Step 7: Cafeteria Admin & System Admin Dashboards (FR-14, FR-15, FR-17, FR-18)
1. Sign in as **Cafe Admin**:
   - Access **Menu Manager**: toggle meal availability (Instant real-time update in student menu).
   - Access **Hours & Settings**: change order timeout from 3 minutes to 5 minutes.
2. Sign in as **Sys Admin**:
   - Create a new university, campus, or cafeteria on the fly with immediate persistence in local Hive storage.

### Step 8: Localization (English / Arabic RTL) (NFR-4)
1. On any screen or in Settings, tap the **Language Toggle** icon (globe/languages).
2. The entire interface immediately transforms into idiomatic Arabic:
   - High-quality Arabic typography using IBM Plex Sans Arabic.
   - Correct RTL layout mirroring (cards, badges, chevrons, forms).
