# Canvas structure

Read this before phase 5 (canvas structure) and before every organization
sweep.

A Pencil document sprawls by default; nothing forces organization unless it is
asked for. Once it has sprawled it is hard to audit and harder to continue in
a later round: an incremental run that cannot find the existing components by
name builds new ones next to them, and the file becomes a patchwork. The rules
below make the organization structural, so most of it is guaranteed by the
layout engine instead of checked afterward.

## The file

One canvas per project: **`design/prototype.pen`**. Fixed name, fixed place,
versioned with the rest of `design/` (a `.pen` file is JSON on disk, so it
diffs and `git reset` to a phase restores it). Read only through the MCP; a
hook blocks file tools on it. Never a second `.pen` for a second round.

## The rules

### 1. Everything lives inside a named box

No loose element anywhere. The document root holds **only** region frames.
Every node, not just the boxes, carries a human-readable `name`; the name→id
map returned by `execute`, plus `Get`, is how a later round finds anything.
Names are unique: a duplicate breaks `Copy`'s `descendants` map and every
name-based lookup, and is an audit failure.

### 2. The box grid is created before any element

The first canvas write creates the empty, named skeleton and nothing inside
it. Regions are placed with `FindEmptySpace`, chained on the previous region's
`nodeId`, so they never overlap. Creating elements first and organizing them
afterward does not work: by the time there is something to organize, moving
it costs more than placing it right would have.

### 3. One region per kind of thing

```
document
├── Design System        tokens swatches, base components with variants and states
├── Brand                logo variants, palette, type specimens
├── Flow — Onboarding    the screens of exactly this flow, every viewport, every theme copy
├── Flow — Checkout
└── Flow — Landing Page
```

Design System at the top, flows below and to the right (pen.dev's own
convention, and where a later round looks first). Every base component sits
there as a `reusable: true` frame with its variants and states laid out beside
it, grouped in `Section / <Job>` frames (Buttons, Inputs, Selection, Status,
Overlays, Shell, and **States**, below). One region per flow; two flows never
share one. A screen that belongs to two flows is instanced, never duplicated
by hand.

### 3b. `Section / States`: the generic states, built once

The states every screen has in common, **loading, error, empty, first use,
long list, long text, permission denied**, are not drawn per screen. They
are drawn **once per screen archetype** the inventory uses (list, object,
form, dashboard; add one when a flow has an archetype these do not cover) as
**exemplars** in `Design System / Section / States`, for the primary
viewport and again only for a viewport where the state genuinely differs (an
empty state on mobile usually does; a skeleton usually does not). Each
exemplar is a full screen-shaped frame of the archetype in that state, built
from the components the catalog names for it (skeleton in the shape of the
content, empty state with a way forward, error with retry, the longest
realistic strings), named `Section / States / <Archetype> — <State> /
<Viewport>`.

A screen in a flow **inherits** its generic states from the exemplar of its
archetype; the spec's generic-state table says which archetype each screen
is. The completeness audit checks the exemplars, and checks that every
screen names an archetype. In the brasario run, 265 of 521 screens were
these five states repeated per screen; this section is where they live now.

### 4. Inside a flow: groups, rows, versions

This is the rule that keeps a multi-target project readable. A screen can
exist in several **versions**: one per declared viewport, plus a copy rendered
in another theme. The versions of one screen always sit **side by side,
aligned at the top**, whatever their heights. That is guaranteed by layout,
not by arithmetic:

```
Flow — Checkout                         frame · layout horizontal · gap: group gap
├── 01 Cart / Group                     frame · layout vertical   · gap: row gap
│   ├── 01 Cart / Row — Base            frame · layout horizontal · alignItems start · gap: version gap
│   │   ├── 01 Cart / Desktop           screen (primary viewport first)
│   │   ├── 01 Cart / Mobile            screen
│   │   └── 01 Cart / Mobile @ Dark     theme copy, right after the version it copies
│   ├── 01 Cart / Row — Selection       row: a specific state the spec lists for this screen, every version
│   │   ├── 01 Cart / Desktop — Selection
│   │   └── 01 Cart / Mobile — Selection
│   └── 01 Cart / Row — Remove Item     row: an overlay, shown in context, on every version
│       ├── 01 Cart / Desktop / Remove Item
│       └── 01 Cart / Mobile / Remove Item
└── 02 Payment / Group
```

- **The region** is a horizontal layout of column groups, one per screen, in
  navigation order left to right. Reading across the top row walks the flow.
- **A group** is a vertical layout of rows: the base row first, then one row
  per **specific state** the spec lists for that screen (never a generic
  state; those are exemplars, §3b), then one per overlay this screen shows
  in context, in the order the spec lists them. Reading down a group
  exhausts one screen. Most groups are one or two rows.
- **A row** is a horizontal layout with `alignItems: "start"` (the default)
  holding the same thing for every version: primary viewport first, other
  viewports in the order of the Targets table, each followed by its theme copy
  if it has one. Because the row is a layout, the tallest frame sets the row
  height and every frame in it starts at the same `y`.
- **Gaps**: one value between versions in a row and between rows in a group,
  a visibly larger one (twice it) between groups, so groups read as groups.
  Same values in every flow region.
- Single-viewport, single-theme projects use the same structure; rows just
  hold one frame. It costs nothing and an added viewport later slots in.

**Viewport is a real duplication**: a desktop table and a mobile card list are
different designs. Build the primary viewport for every screen first, through
the audit, then derive the others into the same rows. Specific states are
built for the primary viewport and carried to another only where the state
actually differs there.

**Theme is not a duplication.** Variables are themed natively, so one frame
renders in every declared theme as long as every color on it is a `$variable`;
a hardcoded hex is the one defect that silently breaks a whole theme. Every
color token declares a value per declared theme. To *see* the other theme, a
few representative screens (the densest, one with imagery, one with an error
or destructive state) get a **theme copy**: the source screen is marked
`reusable: true` and `Copy`'d into the same row with `theme: {mode: "dark"}`
and the `@ Dark` name, which yields a linked instance that follows the source.
Two or three per project, made after the audit. Every node accepts `theme` per
the schema; if the copy does not render in the other theme on a given
version of pen.dev, fall back to a plain `Copy` with the same override and
say so in the run log.

**An overlay** (modal, sheet, drawer, popover, toast) is shown as its screen
with the overlay open: the screen, the scrim, the overlay component instanced.
The overlay's own component lives in the Design System region; the flow shows
the instance in context. **An overlay is shown in context once per product**,
on the screen the navigation map lists first as opening it, whatever the
flow; every other screen that opens it has the row in the navigation map and
nothing on the canvas. A generic overlay (a confirm-delete modal, a media
chooser) opened from many screens is therefore one context screen, not
twelve; the audit checks the map, not the canvas, for the others.

**Screen frames are fixed to the viewport width and `fit_content` in height.**
Never a device height, never `clip`: a clipped screen is how content gets cut
to fit a tab bar, and cut content is content the implementer never sees.
Horizontal overflow is still a defect; `ctx.problems` catches it.

## Naming

Names are always English, whatever the user's language; only the content of
the design follows the user. Separators carry meaning: `/` nests (viewport,
overlay, structural frame), `—` marks a state, `@` marks a theme copy.

| Thing | Pattern | Example |
|---|---|---|
| Region | `Design System` · `Brand` · `Flow — <Flow Name>` | `Flow — Checkout` |
| Column group | `<NN> <Screen> / Group` | `01 Cart / Group` |
| Row | `<NN> <Screen> / Row — Base` · `<NN> <Screen> / Row — <State>` · `<NN> <Screen> / Row — <Overlay>` | `01 Cart / Row — Empty` |
| Screen version | `<NN> <Screen> / <Viewport>` (`<NN> <Screen>` when one viewport) | `01 Cart / Mobile` |
| Specific state variant | `<version> — <State>` | `01 Cart / Mobile — Selection` |
| State exemplar | `Section / States / <Archetype> — <State> / <Viewport>` | `Section / States / List — Empty / Mobile` |
| Overlay in context | `<version> / <Overlay>` | `01 Cart / Mobile / Remove Item` |
| Theme copy | `<version or variant> @ <Theme>` | `01 Cart / Mobile @ Dark` |
| Component | `<Component>` · `<Component> / <Variant>` · `<Component> / <Variant> — <State>` | `Button / Secondary — Disabled` |
| Brand candidate (exploration only) | `Brand Candidate <A/B/C>` | removed before the prototype starts |

## The organization sweep

Run at the end of every round, including one that touched a single screen, as
the last pass of the audit. Everything found is fixed before handoff, by
`Move`, `Update`, resize or rename, never by deleting and rebuilding.

| # | Check | How |
|---|---|---|
| 1 | Loose element at the root | any child of `document` that is not a region |
| 2 | Element bleeding past its container | `ctx.problems` |
| 3 | Overlapping elements | `ctx.bounds` among siblings |
| 4 | Overlapping regions | `ctx.bounds` among root children |
| 5 | Unnamed node, or a default name (`Frame`) | `!n.name` |
| 6 | Duplicate name | collect names, find repeats |
| 7 | Group out of navigation order | `NN` prefix vs. child index in the region |
| 8 | A screen in the wrong flow | name vs. region |
| 9 | Region, group or row not using the layout above | `layout` and `alignItems` on each structural frame |
| 10 | A declared viewport missing from a base row | row children vs. the Targets table |
| 11 | A version out of order in a row, or a theme copy not next to its source | child order vs. the pattern in §4 |
| 12 | A node still flagged `placeholder: true` | `Get(n => n.placeholder && Print(n.id, n.name))` |
| 13 | A state or overlay outside its screen's group, or a row mixing states | names vs. parent names |
| 14 | A leftover exploration box (`Brand Candidate *`) | name search |
| 15 | A generic state drawn as a screen row (`Row — Loading`, `— Empty`, `— Error`, `— Long List`, `— Long Text`, `— First Use`) instead of inherited from `Section / States` | name search over rows |
| 16 | The same overlay shown in context on more than one screen | overlay names across groups |

All of it runs with `Get` visitors and `Print`. Then one
`TakeScreenshot(["document"])` for what bounds cannot show: whether the canvas
reads as an organized document to someone opening it cold.
