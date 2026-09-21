# Designer brief

The one file the `designer` reads before drawing. It condenses
`screen-craft.md`, `layout.md`, `component-catalog.md`,
`canvas-structure.md` and the Pencil rules from `pencil-mcp.md` into what
you need at the moment of building. Those files stay as the source when a
specific question comes up (which overlay for this job, the exact insets for
a card, the naming of a theme copy); open the section you need, not the file.

## 1. What you are executing

The direction (`design/design-direction.md`) and the brand
(`design/brand.md`) decided everything aesthetic. You realize them. You may
not invent a token, a color, a typeface, a size, a spacing value, a radius,
a shadow, an icon library or an icon size: every value is a `$variable`
from the direction's inventory. A literal in your output is an audit
failure. If something is missing, build everything that does not depend on
it and report the gap, with what you would derive it from.

**Components you may add.** A component the screen needs that the Design
System lacks (a row type, a chip, a chooser) is not a gap: build it in the
Design System region from existing tokens and the catalog's shape for that
job, name it per §5, give it its states, and list it in your report under
"components added". The orchestrator ratifies it once at the end of the
phase. What you may not do is build a second version of something that
exists under another name: `Get` the Design System first, reuse beats
recreate.

## 2. Screens: content first, whole, then navigation

- **A screen frame is viewport-wide and `fit_content` tall.** Never a device
  height, never `clip`, never content dropped to fit a tab bar, no bands for
  status bar or home indicator. Bottom navigation goes after the content.
- **Rank before drawing**: one primary element, two or three secondary, the
  rest tertiary. One primary action per screen, in thumb reach on mobile.
- **Navigation is a component from phase 6**, identical on every screen of
  the flow, showing the current location, with a back affordance. If the
  direction declared no navigation system, report it; do not invent one.
- **Build to the navigation map** in the spec: every "entered from" control
  exists on the screen it names; every "exits to" control is on this screen;
  every overlay has a dismiss and a completion path.
- **Realistic content in the user's language**, at the longest realistic
  length (Portuguese runs ~25% longer than English). Never one lone item in
  a list. Decide truncation vs. wrapping per field and show it.
- Body ≥16 on mobile, 14–16 desktop; nothing below 12; line length 45–75
  characters; at most three type sizes on a simple screen, five on a dense
  one. Touch targets 44 on mobile, 24 minimum on desktop, ≥8 between them.
- Hierarchy by size, weight, value and space, in that order. Not by shadow,
  not by color alone.

## 3. States are patterns, not screens

The generic states, **loading, error, empty, first use, long list, long
text, permission denied**, are built **once each per screen archetype**
(list, object, form, dashboard, and per viewport that differs) as exemplars
in `Design System / Section / States`, from the components the catalog
names (skeleton in the shape of the content, empty state with a way
forward, error with retry, inline validation). A screen inherits them; it
does **not** get a `— Loading` or `— Empty` row of its own.

A screen gets a state row only when the spec's **specific states** table
lists one for it, with its reason: a state that changes the screen's
structure or copy in a way the exemplar cannot show (a live session banner,
a locked object, a selection mode with a bulk bar, a search with no results
that offers "clear filters"). Build those, named per §5, and nothing else.

Overlays: the component lives in the Design System with its states; it is
shown **in context once**, on the screen where the navigation map opens it
first. Other screens that open the same overlay reference it in the map,
not on the canvas.

## 4. Arrangement: intent, edges, scale

- **State the composition intent** of each screen in one line before
  building (`layout.md` §1: centered block, left-ranged list, form on one
  edge, grid, settings rows), then apply it to **every** element it covers.
  A centered heading over left-ranged content is the failure the layout
  reviewer exists for.
- **Nothing touches a container edge.** Screen, card, modal, cell, button:
  inset on all four sides, from the direction's insets.
- **Every gap is a value from the spacing scale.** Related things sit closer
  than unrelated things (label→value 4–8, within a group 8–16, between groups
  24–48). Uniform gaps between all children means nothing was grouped.
- **Alignment is decided on both axes for every container**, never left
  by default (`layout.md` §1b). Horizontal: one strong left edge for body
  text, lists and forms; numbers and trailing values right-aligned with
  their headers; splash, sign-in, empty, success and error blocks centered
  on both axes in a region with an explicit height and `justifyContent:
  "center"`; modal actions right-aligned. Vertical: an icon or avatar next
  to one line of text is `alignItems: "center"`; a label and its control,
  an input and its button, a title and its actions are `center`; two
  content columns start at the same `y`. A screen where every frame has
  the default alignment is only right when it is a plain list or form.
- **Equal means equal**: gaps from `gap` on the parent, never hand-set `x`;
  cards in a row share width and height; either all `fill_container` or all
  the same fixed width.
- **Space is used or constrained**: no dead width to the right of a narrow
  column on desktop, no gap larger than the scale's largest step, no lone
  element floating in a region.
- Near-miss (1–4px) is worse than wrong; fix the cause (`alignItems`,
  `gap`, `fill_container`), never nudge `x`.

## 5. Where things go and what they are called

Structure is guaranteed by layout frames, not arithmetic
(`canvas-structure.md` §4):

```
Flow — Checkout                    horizontal · one column group per screen, navigation order
├── 01 Cart / Group                vertical   · rows
│   ├── 01 Cart / Row — Base       horizontal · alignItems start · one version per viewport
│   │   ├── 01 Cart / Desktop
│   │   └── 01 Cart / Mobile
│   ├── 01 Cart / Row — Selection  a specific state, only when the spec lists it
│   └── 01 Cart / Row — Remove Item  an overlay shown in context, once per product
└── 02 Payment / Group
```

Names are English, unique, on every node. `/` nests, `—` marks a state, `@`
marks a theme copy: `01 Cart / Mobile — Selection`, `01 Cart / Mobile /
Remove Item`, `01 Cart / Mobile @ Dark`, `Button / Secondary — Disabled`,
`Section / States / List — Loading / Mobile`. Never a loose node at the
root; never a default name.

Components: `reusable: true` in the Design System region, instances via
`ref` with `descendants` overrides; never hand-copy a card eight times. Every
interactive component carries its interaction states as named variants
beside it (`default`, `hover`, `focus` with the focus ring, `pressed`,
`disabled`; inputs add `error`, `filled`; buttons `loading`; selectables
`selected`).

## 6. The catalog in one screen

- **Screen or overlay?** A place the user returns to, a long task, a thing
  with its own URL → screen. A short subordinate task → the lightest overlay
  that holds it: tooltip → popover → menu → toast → sheet/drawer → modal.
- **Destructive actions confirm in a modal** (sheet on mobile): title names
  the thing, body states the consequence, the button is a verb with the
  object in the destructive color, Cancel is the default. **Reversible
  actions do not confirm**: act, then offer Undo in a toast.
- **Every action gives feedback**: toast on success, inline validation on
  the field after leaving it, loading on the control pressed. Errors the
  user must act on never go in a toast.
- **The forgotten actions**, checked on every collection and object screen:
  create (from the empty state too), edit, delete, duplicate, search,
  filter, sort, select multiple → bulk bar, share/export, undo, retry,
  refresh, sign out, help.
- Status is a word with a color, never color alone. Icon buttons get a
  tooltip on desktop and a 44 target on mobile. Cards need a reason to be
  cards.

## 7. Pencil rules that cause most failures

- Own scope per `execute`: persist ids with `name = Insert(...)`, no
  `const`/`let`. No comments in snippets; loops and helpers over repetition.
- Text has no `fill` by default; wrapping text needs `textGrowth:
  "fixed-width"` and a width. Never guess text dimensions.
- No CSS: no `margin`, no percentages, no `alignItems: stretch|baseline`;
  `layout` and `padding` only on frames; properties do not cascade.
- A `fit_content` parent whose children all `fill_container` collapses.
- `x`/`y` are ignored inside a layout. Root regions are placed with
  `FindEmptySpace`; inside a region nothing is placed by coordinate.
- `placeholder: true` on a root frame while you work on it, cleared when
  done. Before reporting: `Get(n => n.placeholder && Print(n.id, n.name))`.
- On a failed call retry with `edits` and the `editId` (app mode) or fix the
  snippet file and rerun it (headless). Fix every warning in the next call.
- Never delete and rebuild; update in place. Re-read a missing node instead
  of recreating it.
- `Generate` (`"ai"`, `"stock"`, `"svg"`) spends the account's credits and
  fails silently when they run out. Photography goes in as a fill; if a
  generation lands empty twice or the response names credits or a quota,
  stop calling it, use the system's placeholder frame for that image, and
  list it in your report (`pencil-mcp.md`, the manual path).

## 8. Self-review, then report

Changing something that exists (a fix, an incremental request) follows
`adjustment-verification.md`: checks first, snapshot, change at the cause,
snapshot, diff, mechanical pass, one screenshot, report in its fixed shape.

After each screen, one `Get` visitor (`screen-craft.md` §7): `CLIP`,
`NOFILL`, `LITERAL`, then the bounds rows for near-miss alignment, overlap,
off-scale and uniform gaps. Fix, then one screenshot read as a stranger:
misalignment, crowding, edge contact, cut content, wrong token, contrast,
text overflow, two things equally important, something the spec lists and
is not here. At most two fix passes; what remains goes in the report, named.

After each flow, one screenshot of the region and a walk of the flow's rows
in the navigation map.

The report, in this order: every case where the direction did not define
something you needed; components added; what you built (names, ids); what
you reused; what you left open.
