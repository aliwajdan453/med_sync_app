# Design System Strategy: Clinical Performance Lab

## 1. Overview & Creative North Star
The Creative North Star for this design system is **"The Clinical Performance Lab."** This is an environment where elite sports medicine meets high-end editorial precision. We are moving away from the "friendly wellness" aesthetic toward a visual language that feels authoritative, scientific, and premium.

To achieve this, the system breaks the standard "SaaS dashboard" mold through **intentional asymmetry and tonal layering**. We reject the use of structural lines (borders) in favor of defining space through sophisticated background shifts. The layout should feel like a high-end medical journal—wide margins, bold typographic hierarchy, and a surgical focus on data metrics.

---

## 2. Color Architecture & Surface Philosophy
The palette is rooted in high-contrast "Warm Whites" to avoid the sterile, blue-light feel of generic medical software, replacing it with a "Gallery" feel.

### The "No-Line" Rule
**Designers are strictly prohibited from using 1px solid borders for sectioning.** Boundaries must be defined solely through background color shifts or subtle tonal transitions.
*   **Surface (`#FBF9F6`):** The primary canvas.
*   **Surface-Container-Low (`#F5F3F0`):** Use for secondary content areas or sidebars.
*   **Surface-Container-Highest (`#E4E2DF`):** Use for deeply nested elements or to pull focus to a specific data module.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers. To create depth, nest containers using the Tier scale:
1.  **Level 0 (Base):** `surface`
2.  **Level 1 (Section):** `surface-container-low`
3.  **Level 2 (In-section Card):** `surface-container-lowest` (#FFFFFF)

This "stacking" creates a soft, natural lift that communicates hierarchy without visual clutter.

### Signature Textures & Accents
*   **Primary Soft Orange (`#FF8C42`):** Reserved exclusively for high-priority CTAs and critical performance metrics.
*   **Muted Teal (`#3ABFBF`):** Use strictly for data visualization (graphs, progress bars). Do not use for buttons or navigation.
*   **The Signature Glow:** Interactive elements using the `primary` token should feature a subtle `0 0 16px` outer glow of the same color on hover to simulate a digital "active state" in a lab setting.

---

## 3. Typography: Editorial Authority
We utilize a dual-font system to balance clinical efficiency with high-end editorial impact.

*   **Display & Headlines (Manrope):** Set in Bold with tight tracking (-2% to -4%). Manrope’s geometric but humanist qualities provide the "Modern Lab" feel. Use `display-lg` to `headline-sm` for high-impact entry points.
*   **Body & Labels (Inter):** The workhorse for data. Inter is used for its legibility at small scales. Use `label-md` for metadata and `body-md` for patient/athlete notes.
*   **Hierarchy Note:** Always maintain a minimum 2:1 ratio between headline size and body size to ensure an "Editorial" layout feel.

---

## 4. Elevation & Depth: Tonal Layering
Traditional shadows and borders are replaced by light-physics-based layering.

*   **The Layering Principle:** Depth is achieved by "stacking" surface tiers. Place a `surface-container-lowest` card on a `surface-container-low` background to create a "Paper on Table" effect.
*   **Ambient Shadows:** For floating elements (Modals/Popovers), use the custom token: `0 2px 12px rgba(13,27,42,0.06)`. The Navy tint in the shadow ensures it feels integrated into the brand's color space rather than a generic grey.
*   **The "Ghost Border" Fallback:** If accessibility requires a stroke (e.g., input fields), use `outline-variant` (#DDC1B3) at 20% opacity. Never use 100% opaque borders.

---

## 5. Components & "Power Corner" Patterns

### Buttons
*   **Primary:** Pill-shaped (`rounded-full`), `primary_container` background, `on_primary_container` text.
*   **Interaction:** On hover, apply a `primary` subtle glow. Transitions must be instant (150ms) to feel clinical and responsive.
*   **Secondary:** Pill-shaped, `secondary_container` background, `on_secondary_container` text. No border.

### The "Power Corner" Card
Cards should not have borders. Use `surface-container-lowest` (#FFFFFF).
*   **The Pattern:** The top-right corner of every card is reserved for the "Power Metric"—a high-contrast `primary` value (e.g., "98%") set in `headline-md` (Manrope).
*   **Spacing:** Use `spacing-6` (2rem) for internal padding to maintain the "Elite Sports" premium feel.

### Input Fields
*   **Structure:** Minimalist. No box. Use a `surface-container-high` bottom-weighted fill or a very faint "Ghost Border."
*   **Labels:** Always `label-sm` in `secondary` slate, positioned above the input.

### Data Visuals (Muted Teal)
*   **Charts:** Use `tertiary` (#006A6A) and `tertiary_container` (#36BCBC) for all graphing. This separates clinical data from actionable UI elements (Orange).

---

## 6. Do’s and Don’ts

### Do:
*   **Use Generous Whitespace:** If a section feels crowded, increase padding using the `spacing-10` or `spacing-12` tokens.
*   **Lead with Typography:** Let the size and weight of Manrope do the heavy lifting for hierarchy, not boxes.
*   **Respect the Navy:** Use `on_secondary_fixed` (#0D1D2C) for all primary text to maintain high legibility and an authoritative tone.

### Don't:
*   **No Dark Backgrounds:** The system must remain in "High-Contrast Light Mode" at all times.
*   **No Glassmorphism:** Avoid backdrop blurs or transparency; the lab environment is grounded and solid, not "ethereal."
*   **No Playful Animations:** Avoid "bouncy" or "elastic" easing. Use "Linear" or "Ease-In-Out" for professional, scientific transitions.
*   **No 1px Dividers:** Use `spacing-px` as a background-color shift if a separator is required, but prefer `spacing-8` of empty air.