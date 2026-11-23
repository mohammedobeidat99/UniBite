# Changelog — UniBite GP1

## [1.1.0] — Design System, Motion, UX Redesign & Full QA Release
### Added
- **Design System (`lib/core/design_system/`):** Strict 70/20/10 `UniBiteColors`, `UniBiteTokens`, `UniBiteTypography` (`Plus Jakarta Sans` + `IBM Plex Sans Arabic` bundled offline in `assets/fonts/`), `brand_artwork.dart` (`SwooshHeroPainter`, `SteamEmptyIllustration`, `AppetizingFoodPainter`, `YellowConfettiOverlay`), `components.dart`, and debug `ComponentGalleryScreen` (`/component-gallery`).
- **Motion & Brand Experience:** Sequenced skippable `SplashScreen` (`/splash`), 3-slide parallax `IntroOnboardingScreen` (`/intro`), searchable `OnboardingScreen` (`/onboarding`), custom swoosh hero `LoginScreen` with error shake & keyboard response, progressive 2-step `RegisterScreen` with password-strength meter.
- **Student & Dashboard UX Upgrades:** `UbFloatingPillNav`, `UbStickyCartBar`, collapsing menu header with `Hero` meal images, swipe-to-remove cart items with Undo snackbar, animated check-draw order confirmation, plain-language `UbOrderStatusStepper` with yellow confetti on `Ready`, `primary900` collapsible sidebar for Web Dashboards, inline QR lookup & pulsing urgent ticket borders on `LiveOrderBoardWidget`.
- **Documentation & QA Suite:** `docs/design/{research.md, style_guide.md, contrast.md, copy_deck.md}`, `ATTRIBUTIONS.md`, `docs/qa/{test_plan.md, test_report.md, bug_log.md}`, and real exported PNG screenshots in `docs/screenshots/`.
- **Automated Tests:** End-to-end integration tests, golden/screenshot tests in English & Arabic, responsive viewport tests, and accessibility/reduce-motion tests.

### Changed
- Removed the top `DemoControlBar` banner from `_AppShellChrome` per user request; quick demo credential fill chips remain conveniently available on `LoginScreen`.

## [1.0.0] — GP1 Functional Core
- Completed all GP1 functional and non-functional requirements (**FR-1 – FR-24, FR-51, FR-52, NFR-1 – NFR-9**) with Riverpod, `go_router` role guards, Hive local reactive repositories, AR/EN localizations, `OrderStatusValidator`, `OrderAutoRejectService`, `docs/future_firebase_rules.md`, and feature `README.md` files.
