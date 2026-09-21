# Design Direction — <Product Name>

> Instantiated by phase 4 to `design/design-direction.md`.
> Written in English here; **translate the section headings into the user's
> language** when instantiating, and write all content in the user's language.
> This file is the constraint every later phase is audited against.

## Targets carried from the product spec
<Copied from design/product-spec.md — the viewports and themes this direction
must satisfy. Every item below is specified for all of them.>

| | Targets | Primary |
|---|---|---|
| **Viewport** | | |
| **Theme** | | |

## Axes
<The two divergence axes chosen for this project, and why these two — what
tension in this product actually lives on them.>

## The three directions

### Direction A — <Name>
- **Personality (testable, one sentence):** <A sentence someone can hold next to a screenshot and answer yes or no.>
- **Position on the axes:** <Where on each of the two axes.>
- **Type pairing:** <Two named families — exact Google Fonts names and the weights they ship — what each is for, why they pair.>
- **Modular scale:** <Ratio (e.g. 1.25 major third), base size, resulting steps.>
- **Palette:** <The concept first, then the colors derived from it, including named neutrals and intended value distribution. **One value per declared theme** — a dark theme is a designed palette, not an inverted light one. State the contrast pairs that must hold in each.>
- **Density and spacing scale:** <Base unit (usually 4 or 8), the derived scale, and how much a primary view holds — **per declared viewport**. Plus the application rules: screen edge inset, card/modal padding, button and input padding, gap within a group vs. the larger gap between groups, and the minimum gap between adjacent interactive elements.>
- **Grid:** <Columns, gutters, max widths, breakpoints that matter — **per declared viewport**.>
- **Edge treatment:** <Radius and where it varies, border weight and use, what carries depth.>
- **Motion:** <What moves, how fast, what easing, what deliberately does not.>
- **Navigation (per viewport):** <The pattern — bottom tab bar, sidebar, drawer, top nav, no chrome — the primary destinations it carries, how the current location is shown, how back works, and where the primary action sits. Decided once here so every screen agrees.>
- **Alignment posture:** <The dominant alignment edge, whether display type is centered or ranged left, where form labels sit, and how numeric columns are treated.>
- **Iconography:** <One library (lucide / feather / Material Symbols variant / phosphor), one weight, the size scale tied to the type scale, filled or stroked, and whether icons ever carry a color other than the adjacent text.>
- **Rejects:** <The trade-off this direction accepts.>

### Direction B — <Name>
<Same twelve items.>

### Direction C — <Name>
<Same twelve items.>

## Selection criteria
<Written before the winner is named, and tied to the audience and the job from
the product spec — not to taste. "The cleanest" and "the most modern" are not
criteria.>

## Chosen: <Direction Name>
<The full spec of the chosen direction, all twelve items, stated as the decision.>

## Token inventory
<Every required role from references/design-direction.md Step 3b, filled with
this direction's values — one value per declared theme for every color. Phase 6
writes these names verbatim as canvas variables. A role the product never needs
is marked — with a reason, never omitted.>

| Token | Light | Dark | Role / where it applies |
|---|---|---|---|
| `color-surface` | | | page background |
| `color-surface-raised` | | | card, panel |
| `color-surface-overlay` | | | modal, sheet, popover |
| `color-surface-sunken` | | | input, well |
| `color-scrim` | | | veil behind overlays |
| `color-text-primary` | | | |
| `color-text-secondary` | | | |
| `color-text-tertiary` | | | placeholder, disabled |
| `color-text-on-accent` | | | |
| `color-text-link` | | | |
| `color-accent` | | | |
| `color-accent-hover` | | | |
| `color-accent-pressed` | | | |
| `color-accent-subtle` | | | selected row, chip surface |
| `color-border` | | | |
| `color-border-strong` | | | |
| `color-border-focus` | | | focus ring, 3:1 vs surface |
| `color-success` / `-text` / `-surface` | | | |
| `color-warning` / `-text` / `-surface` | | | |
| `color-danger` / `-text` / `-surface` | | | destructive button, error text |
| `color-info` / `-text` / `-surface` | | | |

| Token | Value | Role |
|---|---|---|
| `font-display` / `font-body` / `font-mono` | | |
| `weight-regular` / `weight-medium` / `weight-bold` | | |
| `leading-body` / `leading-display` | | |
| `size-1` … `size-N` | | <step → role: caption, body, control label, h3, h2, h1, display> |
| `space-1` … `space-N` | | <which step is the edge inset, card padding, within-group gap, between-group gap, min gap between targets> |
| `radius-sm` / `-md` / `-lg` / `-full` | | <where each applies> |
| `border-width` / `border-width-strong` | | |
| `shadow-*` | | <or — : depth is carried by …> |
| `duration-fast` / `duration-base` / `easing` | | <or — : none, deliberately> |
| `icon-size-sm` / `-md` / `-lg`, `icon-library`, `icon-weight` | | |
| `grid-columns-<vp>` / `grid-gutter-<vp>` / `content-max-<vp>` / `screen-width-<vp>` | | per declared viewport |

## Component list
<Written by phase 5, before the canvas is touched: the screen inventory walked
against skills/prototype/references/component-catalog.md. One row per
component the product's screens need, and nothing the screens do not need.
Phase 6 builds exactly this; phase 7 designers add to it only what a screen
turned out to need, and their additions are ratified into this table once.>

| Component | Job (catalog section) | Variants | States | Used by (screens) |
|---|---|---|---|---|
| <Navigation: the system declared above, per viewport> | | | | |
| <Overlays: every modal, sheet, drawer, popover, toast the inventory opens> | | | | |
| <Collections: the row/card/table types the archetypes need> | | | | |
| <Inputs, actions, status, structure> | | | | |

### State exemplars
<One row per archetype the inventory uses (list, object, form, dashboard,
plus any a flow needs) × generic state, with the viewport(s) it is built
for; built in `Section / States` in phase 6 (canvas-structure.md §3b).>

| Archetype | Loading | Empty | Error | First use | Long list | Long text | Permission denied | Viewports |
|---|---|---|---|---|---|---|---|---|

## Why the others were rejected
- **<Direction>:** <One paragraph against the stated criteria.>
- **<Direction>:** <One paragraph against the stated criteria.>

## Anti-generic justifications
<Every item from anti-generic.md that this direction uses, named explicitly,
with the reason it earns its place here. Anything not justified by name in this
section is forbidden downstream.>

## The committed choice
<The one non-neutral decision a viewer would notice and could describe. Named
here so the audit can look for it in a screenshot.>

## Brand compatibility
<How this direction works within design/brand.md — palette, typography, tone,
archetype.>
