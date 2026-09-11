# Screen craft

Read this before phase 7, and again before applying audit fixes. The `designer`
agent reads it on every task.

This is the **baseline of established practice** — the things a competent product
designer does without being asked, and the things that fail an audit when they
are skipped. `anti-generic.md` says what not to copy; this file says what to get
right. They do not conflict: originality lives in the palette, the type, the
surface treatment and the composition. Everything below is craft, and breaking it
produces a design that is different *and worse*.

**Every rule here has a matching criterion in `audit-rubric.md`.** That pairing is
deliberate: the designer is given the standard before drawing, so the auditor is
not the first place it appears.

---

## 1. Navigation: decided early, built as components, placed after content

The navigation **system** is decided once, in `design/design-direction.md`, per
viewport — the structure: how a user knows where they are, how they get to every
primary destination, how they go back. Its **components** (tab bar, sidebar, app
bar, breadcrumb) are built in phase 6 with the rest of the system. If the
direction never declared a system, stop and report; navigation invented per
screen produces a prototype where each screen disagrees with the last about
where things live.

On a screen, though, **content comes first and navigation is placed after it.**
Build the screen's actual content — every section, every row, every state the
spec lists — and only then instance the navigation component the direction
calls for. This order is deliberate, because the opposite order produces a
specific and common defect: the screen frame gets sized to a device height, a
tab bar is pinned to the bottom, and the content that no longer fits is cut off
to make room. That prototype looks like a phone and shows a third of the screen.

### The screen shows all of its content — always

**A screen frame is as tall as its content.** Width is fixed to the declared
viewport; height is `fit_content`, never a device height. A long list screen is
tall. A settings screen with forty rows is very tall. That is correct.

The prototype is not a device mockup; it is the **specification the
implementing agents read** and the complete picture the user gets of what each
screen holds. Content hidden below a fold, cut by a clip, or replaced by "…" is
content that will not be built and cannot be reviewed. Scrolling is an
implementation behavior — the implementer decides what scrolls; the prototype
shows what exists.

So:

- Never clip a screen to a device height to make it "look right".
- Never drop rows, sections or states to fit.
- Bottom navigation goes **after** the content, at the bottom of the frame —
  wherever that ends up. It does not float over content, and content does not
  get cut to reach it.
- If a screen is genuinely enormous, that is information: it usually means the
  spec is asking one screen to do two jobs, and the fix is in the spec, not the
  clip.

### No safe-area bands in the prototype

**Do not reserve space for the status bar, notch, dynamic island or home
indicator.** Those are implementation concerns — the implementer applies safe
insets from the platform, and the handoff spec says so. In a prototype they
produce an odd empty band at the top and another at the bottom of every mobile
screen, communicating nothing and hiding the real edge spacing decision behind a
fake one.

A mobile screen frame starts at its first real element (the app bar, the first
content) and ends at its last (the tab bar, or the last content row). Edge
*insets* — the 16–20 that keeps content off the left and right sides, the top
padding under the app bar — are design decisions and stay; the *device chrome*
is not.

### Choosing the system

| Destinations | Mobile | Desktop / web app |
|---|---|---|
| 2–5 primary | Bottom tab bar — the standard, and the only one in the thumb zone | Top bar, or a persistent left sidebar |
| 6–10 | Tab bar for the top 4 + a "More" destination | Persistent left sidebar, grouped with labels |
| Many / hierarchical | Drawer, with the 3 most-used also reachable directly | Collapsible sidebar with sections, plus search |
| Single task | No chrome — a title bar with a close or back affordance | Centered task view, one exit |
| Marketing site | Short top nav, sticky on scroll | Top nav, 4–7 items, one clear CTA |

### Rules that hold everywhere

- **Current location is always visible.** A selected tab, an active sidebar row,
  a breadcrumb. A user who cannot tell where they are will not trust anything
  else on the screen.
- **Every screen has a way in and a way out — visibly.** A way in is a control
  on some other screen that opens it: a nav item, a list row, a button, a link.
  A way out is a control on the screen itself that leaves it: back, close, a
  tab bar, a completion action that goes somewhere. Both are declared in the
  **navigation map** in `design/product-spec.md` before anything is drawn, and
  the audit walks that map against the canvas. A screen with no entry is an
  orphan — it will not get a route in implementation. A screen with no exit is
  a trap.
- **Every overlay has a dismiss *and* a completion path.** A modal has Cancel
  (or ✕) and its action; a sheet dismisses by swipe or ✕ and completes by
  choosing; a drawer closes. A modal whose only button is the destructive one
  is a trap with a confirmation on it.
- **Back always exists and always goes back.** On mobile, the platform gesture
  plus a visible affordance on any screen pushed onto a stack. Never a back
  control that goes somewhere other than where the user came from.
- **The end of a flow returns somewhere.** A success screen has "Done" or
  "Continue" and it leads to a named screen; onboarding has Skip and a last
  step that lands on the home screen; a permission-denied state has a way
  forward; an error state has Retry or Back. A terminal screen with no control
  is the most common dead end.
- **Primary tasks within two steps.** If the core loop from `product-spec.md`
  takes three or more navigations, the structure is wrong, not the labels.
- **Do not hide primary destinations behind a hamburger** on mobile when a tab
  bar would fit them. It halves discovery and is the most common navigation
  defect in AI-generated mobile UI.
- **Navigation is identical across every screen in a flow.** Same position, same
  order, same labels. A tab bar that reorders between screens is a bug.
- **Destination labels are nouns, actions are verbs.** "Orders", not "View
  orders"; "Add shipment", not "New".
- One **primary action per screen**, and it is visually unambiguous. On mobile it
  sits in reach of a thumb — bottom-anchored, not top-right.

### Desktop specifics

- Sidebar destinations get an icon **and** a label. Icon-only rails need tooltips
  and are for a second, collapsed state, not the default.
- Depth beyond two levels needs breadcrumbs.
- Keyboard reachability is part of navigation, not an accessibility extra: tab
  order follows visual order, and the current focus is always visible.

---

## 2. Arrangement lives in `layout.md`

Composition intent per screen archetype, space usage, spacing and edge insets,
alignment, distribution, and the numeric method for checking all of it are in
**`layout.md`**. It is a separate file because it is a separate discipline —
checked by numbers, reviewed by a dedicated agent, and the source of the defects
a viewer feels instantly and cannot name. Read it before building any screen.

The two rules from it that account for the most findings: **nothing touches a
container edge**, and **an intent applies to every element it covers** — a
centered screen is centered in full, a left-ranged list shares one edge in full.

---

## 3. Target sizes and density

| | Minimum |
|---|---|
| Touch target (iOS convention) | 44×44 pt |
| Touch target (Android/Material convention) | 48×48 dp |
| WCAG 2.2 AA target size | 24×24 CSS px |
| Pointer target (desktop) | 24×24, comfortable at 32 |

Use the platform convention for the declared viewport — **44 on mobile is the
working number**, not the 24 floor. The *visual* control may be smaller than its
target; extend the hit area with padding rather than enlarging the icon.

Body text: **16 on mobile** as the baseline (smaller triggers zoom-on-focus in
mobile browsers and is hard in motion), 14–16 on desktop. Nothing readable goes
below 12, and 12 is for genuinely secondary metadata, not body copy.

Line length: **45–75 characters** for anything paragraph-shaped. Line height
1.4–1.6 for body, tighter (1.1–1.25) for large display type.

---

## 4. Hierarchy in practice

- **Rank the screen before drawing it.** One primary element, two or three
  secondary, everything else tertiary. If you cannot name the primary, the screen
  has no job and the spec is wrong.
- Establish hierarchy with **size, weight, value and space** — in that order of
  preference. Shadow is not a hierarchy tool, and color alone is not either
  (it fails for colorblind users and in the other theme).
- **Do not use more than 3 type sizes on a simple screen**, 5 on a dense one. A
  new size needs a new job.
- **Weight beats size** for small distinctions. Bumping 14 to 15 is noise;
  bumping regular to medium is a signal.
- Long content gets **scannable structure** — headings, groups, whitespace — not
  a wall of paragraphs.

---

## 5. Secondary screens the context requires

The screen inventory in `product-spec.md` covers the flows. Real products need
more, and these are the ones that get forgotten because nobody lists them as
features. **Read the application context and build the ones that apply.**

### Mobile app

| Screen | When |
|---|---|
| **Splash / launch** | Always. It is the first frame of the brand and it is where a cold start lives. Keep it short and brand-carrying, never a loading spinner with a logo bolted on. |
| **Onboarding / first run** | When the product needs setup, or the value is not obvious in one screen. Three screens maximum, skippable. |
| **Permission request** | Before any OS permission — with the reason stated *before* the system dialog, not after. |
| **Permission denied** | The state where the user said no and the feature still has to work or explain itself. Almost always missing. |
| **Sign in / sign up / forgot password** | When there are accounts. |
| **Offline / no connection** | When the product touches a network. |
| **Update required** | For a versioned client. |
| **Settings, profile, notifications** | For anything with an account or preferences. |

### Web app

404, 403 / no access, session expired, empty search results, bulk-action
confirmation, settings, account and billing, invite/teammates, and a
first-run empty workspace.

### Marketing site

404, form confirmation / thank-you, cookie or consent notice where the
jurisdiction demands it, and the legal pages the footer links to.

**Decide from context, do not build all of them.** A single-purpose internal tool
with SSO does not need a sign-up screen. State in the audit which secondary
screens the context called for and which were built.

---

## 6. Content that behaves like real content

- Use **realistic content in the user's language** — real-looking names, dates,
  currency, addresses, and lengths for that locale. Lorem ipsum hides every
  layout problem it would otherwise reveal.
- Design for the **longest realistic string**, not the convenient one. Names
  wrap, labels in Portuguese run ~20–25% longer than English, and numbers get
  large.
- Decide **truncation vs. wrapping** deliberately per field, and show it. A name
  that must stay on one line truncates with an ellipsis; a description wraps.
- **Never a lone item in a list** as the only representation. Show enough rows
  that the rhythm, the dividers and the overflow behavior are visible.

---

## 7. Self-review: after every screen, and after every flow

**Nothing is reported done without being looked at.** The audit in phase 8 is
for judgment — does this match the direction, is the hierarchy right, does the
committed choice show. It is not for catching a label 3px off its icon or a card
that overlaps its neighbor. Those are yours to catch, and catching them here
costs one `Get` and one screenshot; catching them in the audit costs a full fix
cycle out of the three each screen gets.

This is a **self-review of the obvious**, and it is deliberately mechanical. It
does not replace the isolated audit — an agent cannot judge its own taste — but
it can absolutely see its own overlaps.

### After each screen

**1. Structural pass — no screenshot.** One `Get` visitor over the screen:

```js
Get(screenId, (n, c) => {
  if (c.problems) Print("CLIP", n.name, c.problems)
  if (n.type === "text" && !n.fill) Print("NOFILL", n.name)
  if (typeof n.fill === "string" && n.fill.startsWith("#")) Print("LITERAL", n.name, n.fill)
  Print(n.name, "|", c.depth, "|", c.bounds.x, c.bounds.y, c.bounds.width, c.bounds.height)
})
```

Fix every `CLIP`, `NOFILL` and `LITERAL` before going further. Then read the
bounds rows for the things numbers reveal better than eyes:

- **Near-miss alignment**: siblings whose `x` (or centers) differ by 1–4px. That
  is not "slightly off", it is a defect a viewer feels without being able to
  name.
- **Overlap**: siblings whose bounds intersect when they should not.
- **Gaps off the scale**: consecutive siblings whose spacing is not a value from
  the direction's spacing scale.
- **Uniform gaps**: every sibling equidistant — nothing was grouped.

**2. Visual pass — one screenshot.** `TakeScreenshot([screenId])`, then look at
it *as a stranger* — someone who has not spent the last ten minutes building it —
and go through this list in order:

| Look for | What it looks like |
|---|---|
| **Misalignment** | An edge that almost lines up; a row where one item sits higher |
| **Overlap or crowding** | Anything touching, anything the eye cannot separate |
| **Edge contact** | Content against a container boundary; an empty device-chrome band at the top or bottom that should not be there |
| **Cut content** | A screen sized to a device height with content clipped or dropped; a bottom nav that displaced content instead of following it |
| **Wrong color** | A literal that slipped through; a token used for the wrong role — body text in the secondary color, a badge in the brand accent |
| **Contrast** | Text you have to squint at — especially secondary text, placeholder text, and anything on a tinted surface |
| **Text problems** | Overflow, unintended truncation, a wrap that orphans one word, a label in the wrong language |
| **Confusion** | Two things that look equally important; an action you cannot tell is an action; a status you cannot read without the legend |
| **Missing** | The state, the action, or the navigation the spec says should be here and is not |

**3. Fix and re-check.** Fix what you found — in place, with `Update`, never by
rebuilding. One more screenshot. **At most two self-fix passes per screen**;
these are cheap, but the audit exists for what does not resolve mechanically.
If something is still wrong after two, leave it and **say so in your report** —
an honest open item is a gift to the auditor, a silent one is a wasted cycle.

**4. Then the checklist.** It is short because the two passes above did most of
it:

- [ ] Navigation present, placed after the content, identical to the flow's
      other screens; current location visible; back available.
- [ ] Every row, section and state the spec lists is visible — the frame is
      content-height, nothing was clipped or dropped to fit a device size.
- [ ] Every state from the spec exists as a named variant.
- [ ] Every action from the "forgotten actions" list in `component-catalog.md`
      that applies is present; every destructive one is behind a modal.
- [ ] Content is realistic, in the user's language, at realistic length.
- [ ] Touch targets meet the platform minimum with gaps between them.

### After each flow

When the last screen of a flow is done, review the **flow**, not the screens:

1. `TakeScreenshot([flowRegionId])` — one image of the whole region.
2. **Consistency across screens**: the navigation is in the same place with the
   same items; the page header sits at the same height; the same component looks
   the same everywhere; the spacing rhythm does not shift between screens.
3. **Order and continuity, against the navigation map**: open the flow's rows
   in `design/product-spec.md` and walk them. For every screen and overlay: is
   each "entered from" control actually present on the screen it says? Is each
   "exits to" control present and labeled to go where it says? Does the flow's
   first screen have its entry from the product's navigation, and does the last
   one return where the map says? Any empty cell in the map, any control the
   map names that is not on the canvas, any screen on the canvas that is not in
   the map — fix it or report it. This is the check that prevents orphan screens
   and dead ends, and the auditor will repeat it.
4. **Nothing overlaps another screen**, and the gaps between screens are equal.
5. Fix, and then report — including the screens you left open items on.

### What this is not

It is not the audit. Do not grade the design against the direction's personality
sentence, do not argue about whether the palette works, do not decide the
committed choice is visible. Those judgments need a context that did not make
the choices. Your job here is narrower and more valuable than it sounds: **make
sure the auditor never has to spend a finding on something a `Get` visitor could
have caught.**
