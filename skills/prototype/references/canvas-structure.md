# Canvas structure

Read this before phase 5 (canvas structure), and always before phase 9
(organization review).

This is not cosmetics. A Pencil document sprawls by default, because nothing
forces organization unless it is asked for explicitly. Once it has sprawled it
is hard to audit and harder to continue in a later round — an incremental run
that cannot find the existing components by name will build new ones next to
them, and the file becomes a patchwork.

## The four rules

### 1. Everything lives inside a named box

No loose element anywhere on the canvas. The box — a `frame` — is the unit of
grouping, and **every node carries an explicit human-readable `name`**, not just
the boxes. The name→id map returned by each `execute` call, plus `Get`, is the
only way a future round finds anything without looking at a picture.

pen.dev's own rule agrees and sharpens it: the document root holds **only**
region frames, screen frames, and reusable component frames. Never a text, icon,
button, card, row, image, or decorative shape directly under `document`.

### 2. The box grid is created before any element

Phase 5 creates the **empty, named skeleton** and stops there. Regions first,
contents second. Creating elements and organizing them afterward does not work;
by the time there is something to organize, the cost of moving it exceeds the
cost of having placed it right.

Use `FindEmptySpace` to place each region, chaining with its `nodeId` anchor so
regions never overlap. Region frames use `layout: "none"` so their children can
be positioned deliberately.

### 3. Separation by nature

One region per kind of thing. Regions never mix.

```
document
├── [Design System]        ← tokens swatches, base components, variants, states
├── [Brand]                ← logo variants, palette, type specimens
├── [Flow — Onboarding]    ← screens of exactly this flow
├── [Flow — Checkout]      ← screens of exactly this flow
└── [Flow — Settings]
```

- **Design System** goes at the top of the canvas, screens below and to the
  right — this is pen.dev's own convention and keeps the reusable components
  where a later round looks first. Every base component sits here as a
  `reusable: true` frame with its variants and states laid out beside it, each
  one named for the state it shows.
- **Brand** holds the logo variants, the palette, and the type specimens.
- **One region per flow.** Two flows never share a region. A screen that
  genuinely belongs to two flows is instanced, not duplicated by hand.

### 3b. Viewports duplicate screens; themes do not

This is the rule that keeps a multi-target project from exploding. Two viewports
and two themes could mean four screen sets. It means **two**.

**Viewport is a real duplication.** A desktop table and a mobile card list are
different designs, not one design at two widths — different density, different
grid, different navigation, often a different information order. They get
separate screen frames, and the flow region is split by viewport:

```
document
├── [Design System]
├── [Brand]
├── [Flow — Checkout / Desktop]
└── [Flow — Checkout / Mobile]
```

Build the **primary viewport first, completely**, through the audit. The second
viewport is derived from a design that has already been judged, not invented
alongside it.

**Theme is not a duplication.** pen.dev variables are themed natively —
`SetVariables` takes `{value, theme: {mode: "dark"}}` arrays — so the *same*
screen renders in every declared theme when its colors reference variables. A
duplicated dark screen set is four times the canvas, and it drifts: someone fixes
a label in light and forgets dark.

So, when dark is in scope:

- **Every color token declares a value for every declared theme.** No exceptions.
- **No color literal anywhere on a screen.** A hardcoded hex cannot theme, so it
  is the one defect that silently breaks the entire dark mode. This was already a
  rule; with a second theme in scope it becomes load-bearing.
- **Build a small theme-verification set, not a full one.** Pick two or three
  representative screens — the densest, the one carrying imagery, and one with an
  error or destructive state — and place them in the design-system region under a
  `Theme Check — <theme>` box, so contrast in the non-default theme is verified
  visually rather than assumed.

The audit then checks contrast **in every declared theme** (rubric 3.6), because
a palette that passes AA in light routinely fails it in dark.

### 4. Inside a flow, screens follow navigation order

Screens sit in the order the user walks them, with a predictable reading
direction (left to right, wrapping down) and a **constant gap between screens**.
Same gap in every flow region. A screen out of order is an audit failure, not a
detail — order is what makes the region readable as a flow instead of a pile.

Screen frames carry `clip: true` so overflowing content is visible as a problem
rather than silently spilling across the canvas.

## Naming

Names are **always in English**, regardless of the user's language, so they stay
stable across rounds and across whoever runs the plugin. Only the *content* of
the design — labels, headings, microcopy — follows the user's language.

| Thing | Pattern | Example |
|---|---|---|
| Region | `Flow — <Flow Name>` / `Design System` / `Brand` | `Flow — Checkout` |
| Region, multi-viewport | `Flow — <Flow Name> / <Viewport>` | `Flow — Checkout / Mobile` |
| Screen | `<NN> <Screen Name>` | `03 Payment Method` |
| Theme check | `Theme Check — <Theme>` | `Theme Check — Dark` |
| State variant | `<NN> <Screen Name> — <State>` | `03 Payment Method — Error` |
| Component | `<Component Name>` | `Button` |
| Component variant | `<Component> / <Variant>` | `Button / Secondary` |
| Component state | `<Component> / <Variant> — <State>` | `Button / Secondary — Disabled` |

Names must be **unique**. A duplicate name breaks `Copy`'s `descendants` map,
which resolves keys by name, and breaks every visitor that looks a node up by
name. Two nodes with the same name is an audit failure.

## Mandatory organization review

**At the end of every round of interactions**, including an incremental round
that touched a single screen, `prototypen:auditor` sweeps the whole canvas.
Nothing ships to handoff with an open finding here.

Check, in this order:

| # | Check | How |
|---|---|---|
| 1 | Loose element outside any box | `Get` visitor at the root: any child of `document` that is not a region, screen, or reusable frame |
| 2 | Element bleeding past its container | `ctx.problems` — `"partially clipped"` or `"fully clipped"` |
| 3 | Overlapping elements | compare `ctx.bounds` among siblings |
| 4 | Overlapping boxes | compare `ctx.bounds` among root-level regions and among screens in a region |
| 5 | Unnamed box | `!n.name`, or a name left at a default like `Frame` |
| 6 | Duplicate name | collect all names, find repeats |
| 7 | Screen out of flow order | screen `NN` prefixes vs. left-to-right `bounds.x` order in the region |
| 8 | Flows mixed in one region | a screen in a region whose flow name does not match |
| 9 | Inconsistent gap between screens | diff the gaps within a region |
| 10 | A declared viewport with no screen set | region names vs. the Targets table in `design/product-spec.md` |
| 11 | Two viewports mixed in one region | screen widths within a region |

Checks 1–8 are structural and need **no screenshot**. Run them with `Get`
visitors and `Print`. Then take **one** `TakeScreenshot(["document"])` for the
macro arrangement — the thing bounds cannot show: whether the canvas reads as an
organized document to a human opening it cold.

Everything found is **fixed before handoff**, not filed as a note for later.
Fix by `Move`, `Update` on `x`/`y`, resizing the container, or renaming — never
by deleting and rebuilding.
