# Layout: composition, alignment, distribution, space

Read this at phase 7 before building any screen, and on every layout review.
The `designer` reads it on every task; the `layout-reviewer` reads nothing else
from the craft set.

`screen-craft.md` covers what a screen must *contain* — navigation, targets,
hierarchy, states, content. This file covers how it is *arranged*: whether the
composition does what it claims, whether things line up, whether space is used
or wasted. These are the defects a viewer feels instantly and cannot name, and
they are the ones most often left standing, because they are small and the
audit's attention is on larger questions.

**Every rule here is checkable with numbers** — `ctx.bounds` from a `Get`
visitor — before a screenshot is taken. The method is at the end.

---

## 1. Composition intent: decide it, then apply it to everything

Every screen has a **composition intent** — the arrangement it is trying to be —
and the most common layout failure is applying it to *part* of the screen: a
centered title over left-ranged content, a centered empty state whose button
sits at the left edge, a two-column layout where one column hugs the top and the
other floats. The intent has to be stated, and then it has to hold for every
element the intent covers.

`design/design-direction.md` declares an **alignment posture** for the product.
Within it, the intent per screen follows the screen's archetype:

| Screen archetype | Expected composition | What "partial" looks like |
|---|---|---|
| **Splash, sign-in, sign-up, onboarding step** | Centered on both axes: logo, headline, form/CTA share one vertical axis | Title centered, form left-ranged; CTA off-axis |
| **Empty state, success, error page, 404** | Centered block: illustration/icon, heading, one-line body, one action — all on one axis, vertically centered in the region | Text centered but the action at the left edge; block hugging the top |
| **Modal / dialog** | Content ranged to the dialog's own left inset; actions right-aligned in the footer (or full-width stacked on mobile); the dialog itself centered in the viewport | Title centered, body left; actions centered under left-ranged content |
| **List, table, feed, inbox** | Ranged left to one strong edge; rows share exact left and right bounds; page header aligns to the same edge | Header inset differs from row inset; some rows narrower |
| **Detail / object page** | Left-ranged content column with an optional right rail; sections share the left edge; page header aligned to it | Sections at different insets; metadata floating right without a rail |
| **Form** | One left edge for all labels and fields; fields share width unless a row groups two; actions at the end, ranged to the form's edge | Fields of random widths; a centered submit button under left-ranged fields |
| **Dashboard / overview** | A grid: equal columns, equal gutters, cards in a row share height; metrics row aligned to the grid | Cards of unequal height in a row; one card wider "because it had more" |
| **Settings** | Grouped rows with a left edge for labels and a right edge for controls, both consistent across every group | Controls at varying right positions; group headers at a different inset than rows |
| **Marketing section** | Whatever the direction commits to — centered hero or asymmetric split — applied to the whole section, not to the headline alone | Centered headline over a left-ranged feature grid |

**Rules that hold for every intent:**

- **Centered means the whole block.** Every element the intent covers shares the
  same vertical axis. Check it: for each child, `bounds.x + bounds.width / 2`
  equals the parent's `width / 2`, within 1px.
- **Left-ranged means one edge.** Every element shares the same `x` inset. Not
  "roughly" — the same value from the spacing scale.
- **Mixed intents need a boundary.** A centered header over a left-ranged list
  is legitimate *if* the two are visibly different regions; the same content
  half-centered is not.
- **Text alignment follows the block.** A centered block has centered short
  text; a left-ranged block has left text. Never a centered paragraph — if the
  copy is longer than two lines, the block's intent was wrong for it.

### 1b. Both axes, and the left-edge reflex

A generated screen has a bias: everything ranged left and top, because
`alignItems: "start"` and `justifyContent: "start"` are the defaults and
nothing forces a decision. The result reads as unresolved even when every
left edge agrees. Alignment is a decision on **two axes for every
container**, and the intent table above names the horizontal one; this is
the vertical one, and the cases where left is the wrong answer.

**Cross-axis (vertical, inside a horizontal row):**

| Row holds | Cross-axis alignment |
|---|---|
| An icon or avatar next to one line of text | `center`; the icon sits on the text's vertical center |
| An icon next to two or more lines of text | `start`, with the icon's top optically at the first line's cap height (a small top padding on the icon's wrapper), never floating at the block's center |
| A label and a control (text field, toggle, select) | `center` |
| An input and a button beside it | `center`, and the button's height equals the input's |
| A page title and its actions | `center` (single-line title) or `end` (title with a subtitle: the actions sit on the title's baseline) |
| Two columns of content (text beside an image, form beside a summary) | `start`, both columns beginning at the same `y`; `center` only when the shorter column is a single block meant to sit mid-height |
| Cards in a grid row | equal heights, so the question does not arise |
| A table row | `center` for every cell, single-line; multi-line cells `start` for all cells in that row |

**Main-axis (vertical, inside a vertical layout) and the block cases:**

| Screen or region | Vertical composition |
|---|---|
| Splash, sign-in, empty state, success, error page, 404 | the block is **centered in its region on both axes**. The screen is `fit_content`, so the region that holds the block gets an explicit height (the viewport height minus the chrome, from the direction) and `justifyContent: "center"`; a centered block that hugs the top is the most common partial |
| A modal or sheet | the dialog centered in the viewport (sheet at the bottom); inside it, content ranged to the dialog's own left inset, the footer's actions **right-aligned** (or full-width stacked on mobile) |
| A button, chip, badge, tab, cell, app bar | its content centered on the cross axis, and horizontally centered for buttons, chips and tabs |
| Numeric columns, prices, totals, the trailing value in a list row | **right-aligned**, headers included |
| A landing hero, a marketing section | whatever the direction commits to, applied to the whole section |

**The left-edge reflex test.** If every container on a screen has the
default alignment on both axes, one of these is true: the screen is a
plain list or form and it is fine, or nobody decided. For any other
archetype it is a finding. Check it in one pass:

```js
Get(screenId, (n, c) => n.type === "frame" && (n.layout || "horizontal") !== "none" && (n.children || []).length > 1 &&
  Print(n.name, "|", n.layout || "horizontal", "| align", n.alignItems || "start", "| justify", n.justifyContent || "start"))
```

Every horizontal row with children of different heights and `align start`
needs a reason; every vertical region holding a centered archetype with
`justify start` needs one too. Then the numeric check: for each horizontal
container, `bounds.y + bounds.height / 2` of each child against the
container's `height / 2`; a row that intends `center` and misses by more
than 1px is a FAIL, and a row of icon + single-line text with the icon's
center above or below the text's center is the defect a viewer feels first.

---

## 2. Space: used, not wasted

Bad space usage is the layout defect that reads as "something is off" from
across the room.

- **Content fills the width it is given, or is deliberately constrained.** On
  desktop, a 1440-wide screen with a 600-wide column hugging the left edge and
  nothing else is not a design decision unless the direction says so. Either
  the content spans (a table, a grid) or it is constrained to a **max content
  width** and centered, or a right rail uses the rest. Empty width to the right
  of everything is dead space.
- **No dead zones.** A region of the screen with nothing in it and no reason to
  be empty: a huge gap before the first content, a void between two sections
  larger than any gap in the scale, a tall frame where the content stops
  two-thirds up. If the frame is `fit_content` (which it must be), dead space
  means an oversized gap or padding.
- **Balance across columns.** In a two-column layout, the columns start at the
  same `y`. In a row of cards, cards share height (`fill_container` on the
  cross axis, or `alignItems: "stretch"` is unsupported — so size them equally).
  A column that is half the height of its neighbor needs either more content or
  a different layout.
- **Rhythm is consistent down the screen.** The gap between sections is the
  same gap every time. Stacked cards have the same gap. A screen that opens
  with 32 between sections and drifts to 20 halfway down has drifted.
- **Nothing is orphaned.** A single small element alone in a large region — a
  lone button in the middle of nowhere, a label with nothing near it — either
  belongs to a group and should sit near it, or is the primary thing and should
  be composed as such.
- **Width consistency within a group.** Rows in a list share width. Fields in a
  form share width unless deliberately paired. Buttons in a row share height.
  Cards in a grid share width.

---

## 3. Spacing: nothing touches, nothing floats

The most common reason a generated screen reads as amateur is spacing — elements
flush against container edges, unrelated things equidistant from each other, and
gaps chosen one at a time.

### The scale

**Every gap, margin and padding is a value from the direction's spacing scale.**
Not a nearby number. The scale exists so that spacing carries meaning: a reader
learns that 8 means "same thing" and 32 means "different section", and an
off-scale 13 destroys that signal without anyone being able to name why.

Most scales are built on a 4 or 8 unit base (4, 8, 12, 16, 24, 32, 48, 64). The
direction file states which; use it.

### Edge padding — never let content touch a boundary

Every container gives its content breathing room on **all four sides**. A screen,
a card, a modal, a table cell, a button — all of them.

| Container | Typical inset |
|---|---|
| Mobile screen edge | 16–20 |
| Desktop screen / page gutter | 24–48, more at large widths |
| Card, panel, modal | 16–24 mobile, 24–32 desktop |
| Button | 12–16 horizontal, 8–12 vertical, and never less horizontally than vertically |
| Table / list cell | 12–16 horizontal, 8–12 vertical |
| Input field | 12–16 horizontal |

The direction file may set different numbers; these are the fallback shape when
it does not, not a substitute for it.

**Safe areas are not drawn.** Status bar, notch and home indicator are
implementation concerns (section 1). The prototype's edge insets are the
designed ones — sides, and the padding under the app bar — not device chrome.

### Proximity carries grouping

Related things sit closer together than unrelated things. This is the cheapest
hierarchy available and the most often wasted.

- A label and its value: tight (4–8).
- Items within a group: one step (8–16).
- Between groups: a clear jump (24–48), enough that the eye reads a boundary
  without needing a divider.
- **If everything is equidistant, nothing is grouped.** Uniform gaps between all
  children of a container is a defect, not neutrality.

Do not reach for a divider line where a larger gap would do. Dividers are for
where space alone is ambiguous.

### Between interactive elements

Adjacent tappable or clickable targets get **at least 8** between them — more on
mobile. Two buttons flush against each other produce mis-taps, and a destructive
action next to a confirm action with no gap is a real hazard, not a cosmetic one.

---

## 4. Alignment: pick an edge and commit to it

- **Establish one strong alignment edge per screen** and let most content share
  it. A screen with four different left edges reads as unresolved.
- **Body text and labels align left** (in LTR). Centered text is for short
  display lines only — a headline, an empty-state message of a line or two, a
  dialog title. **Never center a paragraph**, and never center-align a form.
- **Numbers align right** in any column that will be compared or summed —
  currency, quantities, percentages. Tabular figures where the typeface offers
  them. Text columns stay left.
- **Column headers align with their data**: a right-aligned number column gets a
  right-aligned header.
- **Vertically center items in a row** against each other — an icon against its
  label, an avatar against a name. Icons often need **optical** centering rather
  than mathematical: trust the eye, then verify with `ctx.bounds`.
- **Form labels are consistent**: all above their field, or all to one side. Not
  mixed within a form.
- Related controls share a baseline. A button next to an input matches its
  height, not its top edge only.

---

## 5. Distribution: equal means equal

- **A row of equals gets equal gaps**, from `gap` on the parent — never from
  hand-set `x` on each child. If the children should spread to the edges, use
  the schema's space-between value for `justifyContent` (read `pen-schema.md`
  via `read_skill`; do not guess the string); otherwise a fixed `gap` from the
  scale and the row sized `fit_content`.
- **A grid is a set of row frames with the same column count and gutter.**
  Every row's columns start at the same `x` values. Since flexbox does not wrap,
  a 3-column grid is N row frames of 3 — check that all N agree.
- **Fill vs. fixed is decided per group, not per element.** Either every card in
  a row is `fill_container`, or every one has the same fixed width. One fixed
  and two filling is a defect.
- **Segmented controls, tab bars, button groups** — items share width
  (`fill_container` each) or share padding (`fit_content` each), consistently.
- **Vertical distribution in a tall container**: content either starts at the
  top with a consistent rhythm, or is centered as a block. It does not start at
  the top and then float the last item to the bottom by accident.

---

## 6. Checking it with numbers

Screenshots confirm; bounds detect. Run this before the screenshot.

```js
Get(screenId, (n, c) => {
  if (c.depth === 1) Print("L1", n.name, "x", c.bounds.x, "y", c.bounds.y, "w", c.bounds.width, "h", c.bounds.height,
    "cx", Math.round(c.bounds.x + c.bounds.width / 2))
})
```

Then, per container whose children should agree, one visitor at that
container's depth. What to compute and what a failure is:

| Check | Compute | FAIL when |
|---|---|---|
| Left edge | each child's `bounds.x` | any two differ by 1–4px (near-miss) or one differs while the rest agree (partial) |
| Center axis | `bounds.x + bounds.width/2` vs parent `width/2` | any covered child off by more than 1px |
| Right edge | `bounds.x + bounds.width` | as left edge, for right-ranged groups |
| Row baseline | `bounds.y` of items in a row | any item's top or center off from the rest |
| Gaps | `next.y - (prev.y + prev.height)` down a column; same on x across a row | a gap not on the scale; gaps within a group not all equal; gaps between groups not larger than within |
| Widths in a group | `bounds.width` of siblings | any differ where the group intends equality |
| Dead space | frame height vs last child's bottom edge; largest gap vs scale max | trailing space beyond the inset; a gap larger than the scale's largest step |
| Row heights | `bounds.height` of cards in a row | unequal |
| Cross-axis centers | `bounds.y + bounds.height/2` of each child in a horizontal row vs the row's `height/2` | a row that intends `center` (icon + one line, label + control, input + button, title + actions) off by more than 1px; an icon next to one line of text at a different center |
| Block centering | the block's `bounds.y + height/2` vs its region's `height/2`; its `x + width/2` vs `width/2` | a centered archetype (splash, sign-in, empty, success, error, 404) whose block hugs the top or an edge |
| Default alignment everywhere | every layout frame `align start` and `justify start` | on any archetype except a plain list or form |
| Trailing values | `bounds.x + width` of numeric cells and trailing values | not sharing one right edge; header not right-aligned with them |

**Near-miss is worse than wrong.** A 40px offset reads as intentional; a 3px
offset reads as sloppy. Treat 1–4px as the highest-priority finding, not the
lowest.

Fix by changing the **cause** — the parent's `alignItems`/`justifyContent`, a
child's `fill_container`, a `gap`, a padding — not by nudging `x`. A nudged value
drifts again the next time content changes.

---

## 7. The partial-alignment failure, named

The single defect this file exists for: **an intent applied to some elements and
not others.** It happens because screens are built element by element and each
element is placed relative to its neighbor, so the intent is never checked
against the whole. The symptom list, so it is recognized on sight:

- Centered heading, left-ranged everything else.
- An empty state or a sign-in whose block starts at the top inset because
  the region has no height and no `justifyContent`.
- An icon whose center sits 3px above the text beside it (`alignItems`
  left at `start`).
- Actions in a header at the top edge while the title is vertically
  centered.
- Amounts in a table ranged left.
- Centered block whose button sits at the container's left inset.
- Form fields of three different widths.
- Rows whose right edges vary because some have a trailing icon and some do not
  (the icon column needs a fixed width, present or not).
- A page header inset 24 over rows inset 16.
- Three metric cards, two `fill_container`, one fixed.
- A modal footer with Cancel left and Confirm right but a third button centered.
- A two-column section where the right column starts 12px lower "because the
  image had padding".
- Section headers at one inset, section content at another.

When found: the fix is to identify the intent, state it in one line, and apply
it to every element it covers — not to fix the one element that was noticed.
