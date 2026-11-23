# UniBite – Design References & Inspiration Index

**Date:** 2026-11-23  
**Benchmarking Targets:** Talabat, Careem Food, Deliveroo, Uber Eats, Toast POS, Square KDS  

---

## 1. Visual Benchmarks & Inspiration Sources

### 1. Consumer Food Delivery (Talabat & Deliveroo)
- **Palette Discipline:** Restrained 70/20/10 distribution. Canvas is a warm/green off-white (`#F6F9F4`), never pure `#FFFFFF` or sterile `#F0F0F0`.
- **Card Geometry:** Generous 20dp radii with subtle 1px border (`#E3EAE0`) and soft, multi-layer ambient shadow (`blur: 14, offset: (0, 4), opacity: 0.06`).
- **Meal Item Rows:** Horizontal split with 84x84 rounded food photography, bold primary item title, truncated 2-line description, and distinct 16/20 w800 orange price highlight.
- **Sticky Cart Bar:** Floating pill-shaped bottom bar (28dp radius) with bold item counter badge and total checkout price sliding smoothly into view.

### 2. Kitchen Display & Operator POS (Toast POS & Square KDS)
- **Live Order Board:** High-contrast 3-column Kanban layout designed for 10-foot counter readability.
- **Status Edge Bars:** 4px color-coded left border (Orange = Pending, Yellow = Preparing, Green = Ready) allowing cafeteria staff to assess priority instantly.
- **Determinate Circular Countdown Ring:** Circular ring counting down the 180s (3-minute) auto-reject threshold, turning red/urgent under 45s.

### 3. Typography & RTL Craft
- **Dual Typeface System:** Plus Jakarta Sans for Latin; IBM Plex Sans Arabic for Arabic.
- **Arabic Optical Baseline Adjustments:** Arabic typography sized +1 sp relative to Latin counterparts, with minimum `FontWeight.w500` to avoid hairline stroke degradation on mobile displays.
- **Underline Discipline:** Eliminated standard text decorations that cut through Arabic descenders (e.g. "طالب جديد؟ أنشئ حساباً"), opting for high-contrast color highlights instead.

---

## 2. Dribbble / Behance Case Study Influences

- *Canteen & Campus Food Ordering System* (Dribbble 2025): Hero card with overlapping floating search bar (-26dp) and quick category pill filters.
- *Modern Restaurant Kitchen Order System* (Behance 2024): Clean white card tickets with left status border strip and prominent order numbers (`#001`, `#002`).
- *Dark Emerald Operations Dashboard* (Dribbble 2025): Fixed 264px dark green operations sidebar (`#0C2B18`) with crisp icon badges and white surface canvas.
