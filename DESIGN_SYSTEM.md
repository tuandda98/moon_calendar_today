# Moon Calendar — Design System · "Moonlight on Ink"

A unified, cross‑platform brand system. It is **not** pure Material nor pure
Cupertino — it applies the *shared, documented rules* of both so the app feels
correct and accessible on iOS and Android while keeping one celestial identity.

**Source rules**
- Apple Human Interface Guidelines — Layout, Typography, Color, Accessibility
  (44pt min touch target; Dynamic Type; sufficient contrast).
  https://developer.apple.com/design/human-interface-guidelines
- Google Material 3 — Design tokens, Color system, Type scale, Elevation,
  State layers, Touch targets (48dp).
  https://m3.material.io

---

## 1. Foundations (tokens)

All tokens live in `lib/theme/app_theme.dart`. Screens consume them via
`AppColorScheme.of(context)` and the static `AppSpace` / `AppRadius` / `AppMotion`.

### 1.1 Color — semantic roles

Two themes, identical roles. Dark is default ("Moonlight on Ink").

| Role | Dark | Light | Use |
|---|---|---|---|
| `background` | `#080810` | `#FAFAFD` | App canvas |
| `surface` | `#11111C` | `#FFFFFF` | Cards, sheets, nav |
| `surfaceVariant` | `#1A1A2A` | `#EFEFF6` | Inputs, chips, fills |
| `surfaceBright` | `#24243A` | `#E6E6F2` | Hero card / highest elevation |
| `border` | `#2A2A40` | `#E3E3EC` | Hairline outlines (0.5–1px) |
| `outlineStrong` | `#3C3C58` | `#CFCFDD` | Checkbox/control outlines |
| `primary` (moonlight) | `#B8B8FF` | `#3A3A78` | Accent text, icons, active nav |
| `accent` (indigo CTA) | `#5E5CE6` | `#5856D6` | Buttons, focus, selection |
| `accentGlow` | `#23234A` | `#E8E8FB` | Selected chip / soft fill |
| `textPrimary` | `#F3F3FA` | `#16161F` | Titles, key values |
| `textSecondary` | `#A9A9C0` | `#494957` | Body, labels |
| `textDim` | `#6E6E88` | `#8A8A9A` | Captions, hints, overlines |
| `eventGold` (auspicious) | `#E7B85A` | `#C7972E` | Rằm / mùng 1 highlights |

> **Contrast:** `textPrimary`/`textSecondary` on `background`/`surface` meet
> WCAG AA (≥ 4.5:1). `accent` carries white labels at ≥ 4:1 (AA for the
> ≥ 15px semibold button text we use). The indigo is Apple `systemIndigo`,
> chosen for cross‑platform familiarity.

> **Dark elevation (Material 3):** depth comes from *lighter* surfaces
> (`surface` → `surfaceVariant` → `surfaceBright`) + hairline borders, not
> drop shadows. Light theme uses soft shadows instead.

### 1.2 Spacing — 4 / 8 grid

`AppSpace`: `xs 4 · sm 8 · md 12 · lg 16 · xl 20 · xxl 24 · xxxl 32 · huge 40`.
Screen gutter = `lg (16)`. Section rhythm = `xl–xxl`.

### 1.3 Radius

`AppRadius`: `sm 10 · md 14 · lg 18 · xl 24 · full`.
Inputs/buttons = `md`. Cards = `lg`. Hero/sheets = `xl`. Pills/avatars = `full`.

### 1.4 Type scale (Be Vietnam Pro — full Vietnamese diacritics)

Mapped to Material 3 roles ≈ HIG text styles.

| Role | Size / Weight | Use |
|---|---|---|
| displayLarge | 32 / 700 | Hero (today's date) |
| headlineMedium | 22 / 600 | Screen titles |
| titleLarge | 18 / 600 | Card titles, app bar |
| titleMedium | 16 / 600 | Item titles |
| bodyLarge | 15 / 400 | Primary body |
| bodyMedium | 14 / 400 | Secondary body |
| labelLarge | 15 / 600 | Buttons |
| labelSmall | 11 / 700 · +1.3 tracking | Section overlines (`SẮP ĐẾN`) |

### 1.5 Motion

`AppMotion`: `fast 150ms · base 240ms · slow 360ms`; curve `easeOutCubic`,
emphasized `easeInOutCubicEmphasized`. Keep transitions swift and subtle.

---

## 2. Components (themed centrally)

Defined once in `ThemeData` so every screen inherits them:

- **Button (filled)** — accent fill, white label, radius `md`, **min height 52**
  (> 48dp/44pt target), 12% white state layer on press.
- **Text/Outlined button** — accent/primary foreground, 10% state layer.
- **Input** — filled `surfaceVariant`, radius `md`, 1.5px accent focus ring,
  floating label turns accent.
- **Card** — `surface`, radius `lg`, 0.5px border, flat on dark / soft shadow on light.
- **Event card** — inset full‑radius color spine (category color) + title +
  lunar label + "days until" with semantic urgency color (≤3d red, ≤7d gold).
- **Bottom nav** — `surface`, active = `primary` (moonlight), inactive = `textDim`.
- **Switch / Checkbox / Slider / Progress** — accent‑driven, white thumb/check.
- **Bottom sheet** — `surface`, drag handle, top radius `xl`.
- **Snackbar / Dialog** — `surfaceBright` / `surface`, radius `md`/`lg`.

### Signature touch
The Home hero shows the moon phase over a soft **radial moonlight halo**
(`primary` at low alpha) on the brightest surface — the identity moment of the app.

---

## 3. Accessibility checklist (per HIG + Material)

- [x] Touch targets ≥ 48dp / 44pt (buttons 52h; icon buttons keep default 48 hit area).
- [x] Body text ≥ 14px; AA contrast on every surface.
- [x] Color never the *only* signal (icons + text accompany urgency colors).
- [x] Type uses logical sizes → respects platform Dynamic Type / font scaling.
- [x] Dark + Light parity with identical semantic roles.

---

## 4. How to extend

1. Add a **token** (color/space/radius), never a raw hex/number in a screen.
2. Style shared widgets through `ThemeData`, not per‑instance, so all screens stay in sync.
3. New colors must pass AA against the surface they sit on.
