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

## 1. Navigation is designed first, per viewport

**Before placing a single element on the first screen of a flow, decide the
navigation system.** Not the visual treatment — the structure: how a user knows
where they are, how they get to every primary destination, and how they go back.

`design/design-direction.md` declares this per viewport. If it does not, stop and
report — navigation invented per screen produces a prototype where each screen
disagrees with the last about where things live.

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
- **Back always exists and always goes back.** On mobile, the platform gesture
  plus a visible affordance on any screen pushed onto a stack. Never a back
  control that goes somewhere other than where the user came from.
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

## 2. Spacing: nothing touches, nothing floats

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

**Mobile safe areas are not optional.** Content clears the status bar, the notch
or dynamic island, and the home indicator. A bottom-anchored primary button sits
*above* the home indicator, not under it.

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

## 3. Alignment: pick an edge and commit to it

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

## 4. Target sizes and density

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

## 5. Hierarchy in practice

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

## 6. Secondary screens the context requires

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

## 7. Content that behaves like real content

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

## 8. Before reporting a screen done

Run this list. It is the cheap version of the audit, and it catches most of what
would otherwise come back as a finding.

- [ ] Navigation present, consistent with the other screens in the flow, current
      location visible, back available.
- [ ] Nothing touches a container edge; safe areas respected on mobile.
- [ ] Every gap comes from the spacing scale; groups read as groups.
- [ ] One strong alignment edge; numbers right-aligned; no centered paragraphs.
- [ ] Every color is a `$variable` — **no literals** (this is what breaks themes).
- [ ] Touch targets meet the platform minimum, with gaps between adjacent ones.
- [ ] The primary element is identifiable at a glance; three type sizes or so.
- [ ] Content is realistic, in the user's language, at realistic length.
- [ ] Every state from the spec exists as a named variant.
- [ ] `Get` visitor run: no `ctx.problems`, bounds inside the parent.
