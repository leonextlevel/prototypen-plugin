# Design Spec — <Product Name>

> Instantiated by phase 10 (Handoff) to `design/design-spec.md`.
> Written in English here; **translate the section headings into the user's
> language** when instantiating, and write all content in the user's language.
> Token names, component names, and canvas node names stay in English.
> This is the handoff document: what an implementer needs that the canvas
> cannot show.

## Targets
<The viewports and themes this design covers, carried from
design/product-spec.md. An implementer reads this first — it says which screen
sets and which theme values exist.>

| | Targets | Primary |
|---|---|---|
| **Viewport** | | |
| **Theme** | | |

## How to read this
<Where the canvas file is and how it is organized: one region per flow, one
column group per screen, the screen's versions (viewports, then theme copies)
side by side in the base row, its specific states and the overlays it is the
first to open in the rows below; the generic states (loading, empty, error,
long list, long text, first use, permission denied) live once per screen
archetype as exemplars in `Design System / Section / States`, and every
screen of that archetype inherits them. How a name here maps to a node
there. Then the exported deliverables for readers
without pen.dev: `design/screens/<flow>/*.png` (one per screen version and
state; unversioned, regenerated on every handoff),
`design/screens/<flow>/index.html`, `design/screens/design-system/`,
`design/tokens.json` (W3C Design Tokens, all themes), `design/tokens.css`.>

## Run summary
<From design/run.md: mode, branch, which phases ran and which were skipped and
why, and every change decision from design/changes.md by title and commit —
so the reader knows what was decided without opening the log.>

## Tokens
<Every design token, with its .pen variable name and its intended name in code.
Values live in `design/tokens.json`; this section maps names and states use.
Names are the inventory names from design-direction.md, verbatim.>

### Color
| Canvas variable | Code name | Light | Dark | Use |
|---|---|---|---|---|

### Typography
| Canvas variable | Code name | Value | Use |
|---|---|---|---|

<Plus the scale: ratio, base size, and every step with its intended role.>

### Spacing
| Canvas variable | Code name | Value | Use |
|---|---|---|---|

### Radius, border, shadow
| Canvas variable | Code name | Value | Use |
|---|---|---|---|

## Components
<Every base component: what it is, its variants, its states, and the props an
implementation needs. Include the canvas node name so it can be found.>

### <Component Name>
- **Canvas node:** `<Name>`
- **Purpose:** <One sentence.>
- **Variants:** <List.>
- **States:** <default, hover, focus, active, disabled, loading, error — whichever apply.>
- **Props:** <Name, type, default, what it does.>
- **Behavior the canvas cannot show:** <Focus handling, keyboard interaction, truncation, responsive collapse.>

## Screens
<One row per screen version, generated from the canvas by the snippet in
`skills/prototype/references/handoff.md`, never typed by hand. Then the
state exemplars, one row each.>

| Flow | Screen | Version | Canvas node | PNG |
|---|---|---|---|---|

### State exemplars
<One row per exemplar in `Section / States`: archetype, state, viewport, node,
PNG, and which screens inherit it (from the spec's generic-state table).>

| Archetype | State | Viewport | Canvas node | PNG | Inherited by |
|---|---|---|---|---|---|

## Navigation map
<Carried from design/product-spec.md and verified against the canvas: for every
screen and overlay, what opens it and every way out. This is the routing table
an implementer builds from — a screen missing here will not get a route, and an
overlay without a dismiss here will trap users in implementation exactly as it
would have in the prototype.>

| Flow | Screen / overlay | Entered from | Exits to |
|---|---|---|---|

## Rules the canvas cannot show
- **Screens are content-height, not device-height.** Every screen frame shows
  all of its content; nothing scrolls in the prototype. <State per screen, or
  as a general rule, what scrolls in implementation and what stays fixed —
  typically the app bar and bottom navigation are fixed and the content region
  scrolls.>
- **Safe areas are not drawn.** <State that the implementer applies platform
  safe insets — status bar, notch, dynamic island, home indicator — and that
  the prototype's edge insets are the designed ones on top of those. Name any
  element that must stay clear of the home indicator, e.g. a bottom tab bar or
  a sticky primary button.>
- **Focus order:** <Per screen where it is not obvious.>
- **Responsive behavior:** <What reflows, what collapses, what hides, at which breakpoints.>
- **Motion:** <What animates, duration, easing, and what must not animate.>
- **Copy tone:** <The rules for writing new strings, from design/brand.md.>
- **Accessibility:** <Contrast decisions, touch target minimums, the focus ring token and where it applies, anything that constrains implementation.>
- **Typography and icons:** <The Google Fonts families and weights to load; the icon library, weight and sizes — so the implementation renders what the canvas rendered.>

## Open findings
<Carried over from the latest audit report: what failed two fix cycles and was
left unresolved, and what a human needs to decide.>
