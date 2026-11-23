# UniBite GP1 – Device & Screen Matrix Coverage

## 1. Verified Viewport Profiles

All core screens have been systematically evaluated and snapshot-verified across mobile and web/desktop breakpoints:

| Viewport Profile | Resolution | Orientation | Platform Profile | Verified Flows & Screens | Result |
| :--- | :---: | :---: | :--- | :--- | :---: |
| **Compact Mobile (Baseline)** | 360 × 640 | Portrait | Android small phone | Splash, Intro, Login, Student Shell, Cafeteria Menu, Hours Tab (mobile chips) | **PASS** (0 overflow) |
| **Standard Modern Mobile** | 412 × 915 | Portrait | Pixel 7 / Galaxy S23 | Full Student End-to-End Flow, Cart Checkout, Active Order QR, Staff Live Board | **PASS** (0 overflow) |
| **Tablet / Web Dashboard** | 1280 × 800 | Landscape | Chrome / Edge Web | Cafeteria Admin NavigationRail, Live 4-Column Board, System Admin Management | **PASS** (0 overflow) |

---

## 2. Platform Channels & Sensor Isolation

- **Headless Test Mocking:** Platform-specific channels (`SystemSound.play`, `HapticFeedback`, Audio players) are guarded with `UniBiteTokens.isTestEnvironment` to ensure deterministic execution across all CI and desktop developer environments.
- **Orientation Lock:** Mobile student views locked to Portrait; Cafeteria Admin & System Admin dashboards adapt responsively from mobile single-column tabs to widescreen dual-pane navigation.
- **Reduced Motion Simulation:** Verified with both `MediaQuery.disableAnimations = true` and `reduceMotion` tokens: all animations gracefully collapse to immediate transitions.
