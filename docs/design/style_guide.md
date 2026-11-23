# UniBite Design System & Style Guide (`docs/design/style_guide.md`)

## 1. Brand Essence & Visual Motifs
- **Tagline:** *Your Campus, Your Food, Your Way.* / *حرمك الجامعي، طعامك، بطريقتك.*
- **Personality:** Fresh, youthful, fast, trustworthy, local, appetizing.
- **Brand Motifs Reused Across UI:**
  1. **Orange Swoosh Curve:** Diagonal/curved transition between dark emerald hero panels and white form sheets (`SwooshHeroPainter`).
  2. **Graduation Cap & Fork:** Layered vector silhouettes in hero headers and branded badges.
  3. **Speed Lines:** Motion accents in the animated splash sequence and progress transitions.
  4. **Leaf Accent:** Placed on the `"i"` of the **UniBite** wordmark; informs organic `20px` / `28px` rounded surfaces.

---

## 2. Color System — Concrete 70 / 20 / 10 Ratio

All colors are defined strictly in `lib/core/design_system/app_colors.dart` (`AppColors` with backward-compatible `UniBiteColors` alias). No hard-coded hex values or stock `Colors.*` are permitted in widget code.

### 70% Canvas & Base (Green Family & Crisp Surfaces)
| Token | Hex | Role & Usage |
|---|---|---|
| `green900` | `#0C2B18` | Splash background, web dashboard sidebar (264px), hero cards |
| `green700` | `#1B5E20` | Section headings, primary icons, selected navigation states |
| `green500` | `#2E7D32` | Ready order badges, success indicators |
| `green100` | `#E0EEDD` | Soft green chips, progress track, subtle badges |
| `green50` | `#F6F9F4` | **Screen canvas background** everywhere (never flat grey or sterile white) |
| `surface` | `#FFFFFF` | Cards, bottom sheets, text inputs |
| `outline` | `#E3EAE0` | Crisp 1px card and input borders |
| `ink` | `#111E16` | Primary body copy & **button text on orange** (passes AA contrast) |
| `inkSoft` | `#415347` | Secondary body copy |
| `inkMuted` | `#728478` | Captions, timestamps, working hours |

### 20% Secondary (Energy Orange)
| Token | Hex | Role & Usage |
|---|---|---|
| `orange` | `#FF6B00` | Primary CTAs (`Order`, `Add`, `Accept`), swoosh accents |
| `orangePressed` | `#E05D00` | Pressed state on orange buttons |
| `orangeSoft` | `#FFF2E8` | Soft peach tint for badges and highlights |
| `orangeText` | `#B84700` | High-contrast orange text on white (`5.49:1`) for prices and links |

### 10% Accent & Semantic
| Token | Hex | Role & Usage |
|---|---|---|
| `yellow` | `#FFB703` | `"Open now"` dot, pre-order pill, pending status |
| `onYellow` | `#3D2800` | Dark high-contrast ink on yellow |
| `danger` | `#D64545` | Errors, `"Rejected"` / `"Cancelled"` borders, offline alerts |
| `dangerSoft` | `#FDE8E8` | Soft red fill for error cards |
| `dangerText` | `#9E1C1C` | High-contrast text on danger cards |

---

## 3. Typography Hierarchy

- **Latin Font:** `Plus Jakarta Sans` (bundled in `assets/fonts/`)
- **Arabic Font:** `IBM Plex Sans Arabic` (bundled in `assets/fonts/`)
- **Arabic Optical Baseline Adjustments:** +1 sp size, `FontWeight.w500` minimum to maintain stroke weight legibility.
- **Scale:**
  - **Display:** 28 sp / line-height 36 / `FontWeight.w800`
  - **H1:** 22 sp / line-height 30 / `FontWeight.w700`
  - **H2:** 18 sp / line-height 26 / `FontWeight.w700`
  - **BodyL:** 16 sp / line-height 24 / `FontWeight.w500`
  - **BodyM:** 14 sp / line-height 22 / `FontWeight.w400` (w500 in Arabic)
  - **Caption:** 12 sp / line-height 16 / `FontWeight.w500`
  - **Button:** 15 sp / line-height 20 / `FontWeight.w800` / `color: AppColors.ink`
  - **Price:** 16 sp / line-height 20 / `FontWeight.w800` / `color: AppColors.orangeText`

---

## 4. Spacing Scale & Elevation (4-pt Grid)

- **Spacing Tokens:**
  - `xs4` = 4 dp (micro gap)
  - `sm8` = 8 dp (compact gap)
  - `md12` = 12 dp (standard gap)
  - `lg16` = 16 dp (card padding)
  - `xl20` = 20 dp (screen horizontal padding)
  - `xxl24` = 24 dp (section gap)
  - `xxxl32` = 32 dp (major vertical separation)
- **Shape Radii:**
  - `input / chip` = 14 dp
  - `button` = 16 dp (or full stadium pill `999 dp`)
  - `card` = 20 dp
  - `sheet / hero` = 28 dp
  - `pill` = 999 dp
- **Shadows (`AppShadow`):**
  - `soft`: `0 4px 14px rgba(12, 43, 24, 0.06)` (Cards & search inputs)
  - `raised`: `0 10px 24px rgba(12, 43, 24, 0.12)` (Floating bars, dialogs)

---

## 5. Circular Progress Language (Strict Standard)

- **Component:** `AppLoader`
- **Rule:** Circular everywhere. Zero linear progress bars across mobile and dashboard screens.
- **Sizes:**
  - Size 22: Button spinner (`AppLoader.button(color: AppColors.ink)`)
  - Size 24: Inline icon spinner (`AppLoader.small()`)
  - Size 40: Card / Section loader (`AppLoader.regular()`)
  - Size 56: Full-page loader (`AppLoader.large()`)
- **Determinate Countdown Ring:** `AppCountdownRing` (used on staff live order board for 3-minute auto-reject timeout).

---

## 6. Motion & Accessibility

- **Icon Family:** `LucideIcons` (clean 1.75px stroke); zero emoji icons.
- **Motion Timing:** `150ms` fast tap feedback, `260ms` normal transition, `420ms` slow hero/reveal.
- **Reduced Motion:** Checks `AppMotion.reduceMotion(context)` and disables translation animations.
- **Touch Target:** Minimum 48x48 dp on all interactive controls.
