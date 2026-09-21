# Audit rubric

Read this at phase 8. Levels 1, 2, 4 and 5 are checked against the canvas and
the spec; level 3 against `design/design-direction.md`, `design/brand.md`,
`anti-generic.md` and the craft files. Criteria 3.12–3.16 are the auditable
form of `screen-craft.md`, 3.17–3.19 and 4.11 of `component-catalog.md`,
3.15, 3.22, 3.23 and 3.26 of `layout.md`, and 1.11, 3.24 and 3.25 of the
direction's token inventory, type and iconography items. When one fails,
cite the section it comes from so the fix is unambiguous.

Every criterion gets a **binary verdict**, PASS or FAIL. A rubric that admits
degrees grades everything B+ and nothing gets fixed. The auditor runs in a
separate context from whoever produced the work.

A **named exception** the user chose in an incremental round
(`adjustment-verification.md` §0a: "exception: <screen>, <what>, <why>" in
the direction's amendments and in `design/changes.md`) is a PASS for the
criterion it names, on that screen only; cite the entry. The same thing on
another screen, or without the entry, is a FAIL as usual.

The audit is two passes in two contexts. The **structural pass** (levels
1, 2, 4 and 5, no screenshot, run on sonnet) goes first over everything; a
structural failure or a dead end found there saves a visual pass on a screen
that has to be redone anyway. The **visual pass** (level 3, run on opus)
covers the **base screens, the specific states and the state exemplars**
only: a screen's generic states are the exemplar, and screenshotting them
per screen was half the brasario audit. The organization sweep in
`canvas-structure.md` is level 2 in full; it runs again, alone, after the
last fix of the round.

## Report format

Write `design/audits/<YYYY-MM-DD>.md` in the user's language:

```
## <Screen or region name>
- [PASS] <criterion>
- [FAIL:execution] <criterion> — <what is wrong, where, what to do> → designer
- [FAIL:direction] <criterion> — <the direction was followed and is still wrong; what it needs to declare instead> → change request
- [FAIL:spec] <criterion> — <what the product needs that the spec never listed> → change request
```

The class decides where the fix goes. `execution` returns to the designer;
`direction` and `spec` go to the orchestrator under `change-protocol.md`, and
are **not** counted against the screen's two fix cycles — they are not the
screen's fault.

Every FAIL names the node (by name and id), what the correct state is, and the
fix. "Hierarchy is weak" is not actionable. "The card title (`03 Payment — Card
Title`, id `Xk9f2`) is 16px next to a 15px label; the type scale's step 3 is
20px" is.

## Level 1 — Structural (no screenshot)

| # | Criterion | Method | FAIL → |
|---|---|---|---|
| 1.1 | No overflow or clipping | `Get` visitor, `ctx.problems` | Resize the container to fit, or reduce the content. Never crop by clipping. |
| 1.2 | Elements sit on the grid | `ctx.bounds` vs. the direction's spacing scale | Snap to the scale. An off-scale value is a decision nobody made. |
| 1.3 | No hardcoded value where a variable exists | `Get` **without** `resolveVariables`; look for literal colors, sizes, spacings, radii | Replace with the `$variable`. |
| 1.4 | No duplicate component | Compare `reusable` frames and repeated subtrees | Delete the duplicate, instance the original with `ref`. |
| 1.5 | Every node has a name | `!n.name` or a default name | Name it, per `canvas-structure.md`. |
| 1.6 | Text is visible | `type: "text"` with no `fill` | Set the `fill`. Invisible text is the most common silent failure. |
| 1.7 | Every color token declares a value for **every declared theme** | `Print(GetVariables())` vs. the Targets table | Add the missing theme value. A token with one value in a two-theme project breaks that theme wherever it is used. |
| 1.8 | **No color literal on any screen** | `Get` without `resolveVariables`, look for hex strings | Replace with the `$variable`. A literal cannot theme — this is the single defect that silently breaks dark mode everywhere it appears. |
| 1.11 | **Every required token role exists as a variable, by its inventory name** | `Print(GetVariables())` vs. the token inventory in `design/design-direction.md` (Step 3b of `design-direction.md`); a role marked `—` in the direction is exempt | Add the missing variable from the direction's value. If the direction never filled that role, it is a `direction` failure: the inventory is incomplete. |

**Incremental mode adds these two, and they are hard failures:**

| # | Criterion | FAIL → |
|---|---|---|
| 1.9 | No new hardcoded value where a token already exists | Use the existing token. This is not a creative choice; it is drift. |
| 1.10 | No new component duplicating an existing one | Instance the existing one. A near-copy with a different name is the same failure. |

## Level 2 — Canvas organization

Method in the sweep table at the end of `canvas-structure.md`. Mandatory every
round, and run once more after the last fix.

| # | Criterion |
|---|---|
| 2.1 | No loose element outside a box (nothing under `document` but regions, screens, and reusable frames) |
| 2.2 | No element bleeding past its container's bounds |
| 2.3 | No overlapping elements |
| 2.4 | No overlapping boxes or regions |
| 2.5 | Every box named |
| 2.6 | No duplicate names anywhere |
| 2.7 | Column groups in navigation order within their flow region |
| 2.8 | No two flows sharing a region |
| 2.9 | Region, groups and rows use the layouts `canvas-structure.md` §4 prescribes (region horizontal; group vertical; row horizontal, `alignItems: "start"`), with the same gaps in every flow |
| 2.10 | **Every declared viewport has its version in every base row**, primary first, in Targets order |
| 2.11 | **No node carries `placeholder: true`** — a frame still flagged is either unfinished work or a logo generation that never landed | Finish it, or for a `Generate` target whose flag cleared to nothing, re-run the generation once; otherwise report. |
| 2.12 | **Every version of a screen sits in its row, side by side and top-aligned** with the other versions, theme copies directly after their source; states and overlays in their own rows of the screen's group, named per `canvas-structure.md` | Move into the right row and rename. A version placed by `x`/`y` outside its row, or a state beside its base screen, is a FAIL. |
| 2.13 | No exploration leftovers: no `Brand Candidate *` box, no variation box | Delete; the brand document carries what mattered. |

FAIL → fix by `Move`, `Update` on `x`/`y`, resize, or rename. **Never by
deleting and rebuilding.** Fixed before handoff, never filed as a note.

## Level 5 — Navigation integrity (no screenshot; run with levels 1 and 2)

Numbered last, run early: it is cheap, and an orphan screen or a dead end is a
structural defect that makes the visual pass on that screen pointless. The
reference is the **navigation map** in `design/product-spec.md`. Walk every row
against the canvas — `Get` visitors listing each screen's named controls, a
screenshot only where a label is ambiguous.

| # | Criterion | FAIL → |
|---|---|---|
| 5.1 | **Every screen is in the map, and every map row is on the canvas** — no screen exists that nobody planned a route for, no planned screen is missing | Add the row or build the screen; a screen not in the map will not get a route in implementation. |
| 5.2 | **Every screen has at least one way in, present on the canvas**: the control the map names ("entered from") exists on the screen it says, and is labeled to lead here | Add the entry control where the map says — a nav item, a list row, a button. A screen reachable only by deep link is an orphan. |
| 5.3 | **Every screen has at least one way out, present on the canvas**: back, close, a tab bar, or a completion action that leads to a named screen | Add it. A terminal screen with no control is a trap. |
| 5.4 | **Every overlay has a dismiss AND a completion path** — Cancel/✕/swipe/outside-tap *and* the action that does the thing; both visible | Add the missing one. A modal whose only button is the destructive one is a trap with a confirmation on it. |
| 5.5 | **Flow entry and flow end are wired**: the first screen is reachable from the product's navigation; the last screen returns where the map says — home, the list, the object | Wire it. An onboarding that ends nowhere, a success screen with no Done, is a FAIL. |
| 5.6 | **Dead-end states have a way forward**: permission denied, offline, error, empty search, session expired — each offers Retry, Back, Settings, or Clear as the context needs | Add the control. A state that only explains is half a state. |
| 5.7 | **Navigation returns are truthful**: Back goes to where the user came from, Cancel discards and closes, ✕ closes without side effects — labels match behavior | Relabel or rewire. "Cancel" that saves is a FAIL. |

Report format for this level names the screen, the missing edge (in or out),
and where the map says it should lead:

```
- [FAIL:execution] 5.3 `07 Order Confirmed` has no exit — map says "Done → 01 Orders". Add the Done action.
- [FAIL:spec] 5.1 `Settings / Notifications` exists on the canvas and is not in the map — no entry planned. Spec needs the row; likely entered from `Settings` list.
```

## Level 3 — Visual (screenshot)

Only reached once levels 1 and 2 pass. `TakeScreenshot` on the **smallest
meaningful node** — a screen frame, not the document.

| # | Criterion | FAIL → |
|---|---|---|
| 3.1 | The screen matches the chosen direction's **testable personality sentence** — hold the sentence next to the image and answer yes or no | Name which of the twelve direction items is violated; redo against it. |
| 3.2 | The direction's **committed choice** is visible and nameable | If the auditor cannot name it from the picture, it is not there. |
| 3.3 | Nothing on the `anti-generic.md` ban list appears unjustified | Cite the item and the direction file's silence on it; replace. |
| 3.4 | Brand adherence — palette, type, tone of the microcopy, logo used per its rules | Cite the `brand.md` clause. |
| 3.5 | Hierarchy — the single most important thing on the screen is the most prominent; you can rank the top three at a glance | Adjust scale, weight, value, or position — not by adding a shadow. |
| 3.6 | Contrast meets **WCAG AA in every declared theme**: 4.5:1 body text, 3:1 text ≥24px or ≥19px bold, 3:1 for UI component and state boundaries. Check each theme separately — a palette that passes in light routinely fails in dark | Adjust the token for the failing theme, not the instance. If the direction's palette cannot pass in a declared theme, the palette is wrong. |
| 3.7 | Touch targets ≥44×44pt on touch, with spacing between adjacent targets | Enlarge the target, not just the icon. |
| 3.8 | Alignment and optical spacing — items that should align do, gaps read as even | Fix with layout, not by nudging pixels. |
| 3.9 | Copy is in the **user's language**, matches the brand's tone, and **reads as a person wrote it** (`writing.md`): no em dash or travessão inside UI text, no emphasis fragments, and no text node with three or more short sentences in a row (the period test). Checked mechanically: the visitor in `writing.md` lists every multi-sentence text node, and each goes through `scripts/prose-check.py --text` | Rewrite. English microcopy for a Portuguese-speaking user is a FAIL, not a detail; so is an empty state that reads "No sessions yet. Create one. It takes a minute." |
| 3.10 | The screen holds up **at every declared viewport** — density, grid, navigation and information order suit the width it is for, rather than being the other viewport rescaled | Redesign for that viewport against its own density and grid from the direction file. |
| 3.11 | The **theme copies** (`… @ <Theme>`) render correctly in the non-default theme — no invisible text, no glaring accent, no surface collapsing into its background | Fix the theme's token values, then re-check. Never fix by hardcoding a color into the screen. |
| 3.12 | **Navigation** matches the direction's declared system, is identical across every screen in the flow, shows the current location, and offers a working back affordance. Primary tasks reachable in two steps | Fix the structure, not the label. If the direction never declared a navigation system, that is a phase-4 failure — say so rather than inventing one at audit time. |
| 3.13 | **Nothing touches a container edge.** Every screen, card, modal, cell and button gives its content inset on all four sides — the designed insets, not device chrome | Add the inset from the direction's spacing rules. |
| 3.14 | **Spacing comes from the scale, and proximity groups.** Related items sit closer than unrelated ones; gaps between groups are visibly larger than gaps within them; adjacent interactive elements have a gap | Uniform spacing between every child of a container is a defect — it means nothing was grouped. Apply the two-tier gap from the direction. |
| 3.15 | **Composition intent applied in full** (`layout.md` §1, §7): the screen's stated intent — centered block, left-ranged list, form on one edge, grid — holds for *every* element it covers; one dominant edge; body text and forms ranged left; numeric columns right-aligned with matching headers; icons optically centered | Normally already fixed by the layout reviewer; if it reaches you, check its report. Partial application — centered heading over left-ranged content — is a FAIL. |
| 3.16 | **Type sizing is legible and ranked**: body ≥16 on mobile, nothing readable below 12, line length 45–75 characters, no more than ~3 type sizes on a simple screen | Consolidate to the scale's steps. A new size needs a new job. |
| 3.17 | **Destructive actions confirm in a modal** (bottom sheet on mobile) shaped per `component-catalog.md`: title names the thing, body states the consequence, destructive button is a verb with the object in the destructive color, Cancel is the safe default. Reversible actions do *not* confirm — they act and offer Undo | A destructive action with no confirmation, or a dialog whose confirm button says "OK"/"Yes", is a FAIL. A confirm dialog on a reversible action is also a FAIL — it trains click-through. |
| 3.18 | **The lightest component that holds the task was used.** No full screen for a confirmation, a quick edit, a short choice or a filter; no modal where a popover or toast would do; no toast carrying an error the user must act on | Cite the catalog ladder (tooltip → popover → menu → toast → sheet → modal → screen) and the right rung. |
| 3.19 | **Every action gives feedback** — a toast on success, inline validation on a field, a blocking dialog only when blocking is warranted; loading shown on the control that was pressed | Add the feedback at the right weight. Silence after an action is a FAIL. |
| 3.20 | **The screen shows all of its content.** The frame is viewport-width and content-height; nothing is clipped, dropped or truncated to fit a device height or to make room for a tab bar; bottom navigation follows the content rather than displacing it | Resize the frame to `fit_content` and restore what was cut. A screen that "looks like a phone" but hides a third of its content is a FAIL — the implementer will build what is visible. |
| 3.21 | **No safe-area bands.** No empty reserved space for status bar, notch, dynamic island or home indicator at the top or bottom of a mobile screen | Remove the band. Safe insets are the implementer's, and `design-spec.md` says so. |
| 3.22 | **Space is used or deliberately constrained** (`layout.md` §2): no dead zones, no content hugging one side of a wide screen with nothing beside it, columns balanced, rows of cards equal height, rhythm consistent down the screen | Constrain to a max content width and center, or fill, or add a rail — per the direction. Dead space is a FAIL, not "airy". |
| 3.23 | **Distribution is equal where it claims to be** (`layout.md` §5): rows of equals have equal gaps from `gap`, grids share column positions across rows, fill-vs-fixed is consistent within a group | Fix the parent's `gap`/`justifyContent` or the children's sizing mode, never by nudging `x`. |
| 3.24 | **The rendered typeface is the declared one.** Hold the screenshot next to the direction's type pairing: a serif direction rendering in a neutral sans, a display family rendering in the body family, or a weight the family does not ship (medium rendering as regular) is a FAIL. pen.dev falls back silently when a family is not on Google Fonts or a weight is missing | If the family name is wrong, fix `font-*`. If the family is not on Google Fonts, that is a `direction` failure — the direction must name one that is. |
| 3.26 | **Alignment was decided on both axes** (`layout.md` §1b): rows of icon + one line of text, label + control, input + button and title + actions are vertically centered (centers within 1px); centered archetypes (splash, sign-in, empty, success, error, 404) are centered in a region with an explicit height, not hugging the top; numeric and trailing values share one right edge with their headers; modal actions are right-aligned. A screen whose every layout frame has the default alignment on both axes is a FAIL unless it is a plain list or form | Set `alignItems`/`justifyContent` on the parent; give the region its height from the direction. Normally fixed by the layout reviewer; if it reaches you, its report missed the §1b pass. |
| 3.25 | **Iconography is one system.** Every `icon` node uses the direction's declared library (`Get` visitor on `n.type === "icon"` printing `library`, `weight`, `width`), the declared weight, and one of the declared sizes; icons are optically consistent (all stroked or all filled); no emoji as iconography | Replace the stray library or size with the declared one. If the declared library lacks a needed glyph, that is a `direction` failure to record, not a license to mix. |

## Level 4 — Completeness

Checked against the generic-state and specific-state tables in
`design/product-spec.md`. These are the states that are always missing,
because they are the ones nobody thinks about while designing the happy path.

The generic states are **exemplars in `Design System / Section / States`**,
one per archetype and state (`canvas-structure.md` §3b), and are checked
there once; a screen passes 4.1–4.7 by naming its archetype in the spec and
having that archetype's exemplars exist. A screen with a `— Loading` or
`— Empty` row of its own is a level-2 FAIL (sweep check 15), not a pass.

| # | State | Present as an exemplar for every archetype the inventory uses, and for every viewport where it differs? |
|---|---|---|
| 4.1 | **Empty** — no data yet, with a way forward, not just a shrug |
| 4.2 | **Loading** — and it matches the shape of what is coming |
| 4.3 | **Error** — says what happened and what to do, in the user's language |
| 4.4 | **First run** — the very first time, before anything exists |
| 4.5 | **Long list** — enough items to show pagination, scroll, or virtualization |
| 4.6 | **Long text** — the longest realistic name, label, and body, in the user's language (which may be ~25% longer than English) |
| 4.7 | **Permission denied / restricted** — the user cannot do this, and it says why |

| # | | |
|---|---|---|
| 4.8 | **Every declared viewport** has the flows and screens the spec lists for it |
| 4.9 | **Every declared theme** has token coverage, and two or three theme copies exist beside their source screens |
| 4.10 | **The secondary screens the context requires exist** — for a mobile app that means at least splash, first run, permission request *and* permission denied, and offline where a network is involved; for a web app 404, no-access and session-expired; for a marketing site 404 and form confirmation. Catalog in `screen-craft.md` |
| 4.11 | **The forgotten actions are present** where they apply — create (reachable from the empty state too), edit, delete, duplicate, search, filter, sort, bulk select, share/export, undo, retry, refresh, sign out, help. Checked against the list in `component-catalog.md` per collection and object screen |
| 4.12 | **Every interactive base component has its interaction states** as named variants in the design-system region: `default`, `hover`, `focus` (with the `color-border-focus` ring), `pressed`, `disabled`; inputs add `error` and `filled`; buttons add `loading`; selectable rows and options add `selected`. Named `<Component> / <Variant> — <State>` per `canvas-structure.md` | Build the missing state beside the component. A component with only a default state hands the implementer a guess for every other one — and `focus` missing is an accessibility defect, not a nicety. |
| 4.13 | **The landing page, when in scope, has every section the spec's landing study lists, in that order, with exactly one primary action** repeated with the same label; its confirmation and submit-error screens exist (`landing-page.md`) | Add the missing section or state; reduce to one primary action. |
| 4.14 | **Every specific state the spec lists exists** as a named row of its screen's group, and no row exists that the spec does not list with a reason | Build the missing one; move an unlisted one to the spec with its reason, or remove it if it is a generic state in disguise. |
| 4.15 | **Every screen names an archetype** in the generic-state table, and every archetype named has its exemplars | Add the archetype, or the exemplar set. |
| 4.16 | **Depth is honored**: with `core`, every screen the core loop and the required secondary screens need is drawn, and the backlog lists the rest; nothing drawn is absent from the inventory | Add the missing core screen, or move the extra one to the backlog. |

FAIL → build the missing exemplar in `Section / States` (4.1–4.7), the
missing screen or row (4.8–4.10, 4.13, 4.14, 4.16), or the state beside its
component (4.12), named per `canvas-structure.md`.

## What the designer already checked

Before reporting a screen, the designer runs the self-review in section 7 of
`screen-craft.md` — a `Get` pass for clipping, missing fills, literals,
near-miss alignment and overlap, and one screenshot for the obvious. Its report
names anything it left open.

Read that report first. **If you find something mechanical that the self-review
should have caught and the report does not mention, say so explicitly in the
finding** ("not caught by self-review") — that is a process signal worth more
than the defect itself, and it is how the self-review procedure gets tightened.
Do not soften the FAIL because of it.

## The attempt limit

**At most 2 fix cycles per screen.**

Screenshot-based visual critique is good at hierarchy and gross error, and weak
at refinement. Past two cycles it stops converging and starts oscillating —
each pass finds a new subjective complaint and the screen changes without
getting better. The brasario run's third cycles resolved almost nothing the
second had not.

On the second failure: **stop**. Record in the audit report what is still wrong,
what was tried, and why it did not resolve. Then move on. An honest open finding
is worth more than a third pass, and a human reading the report can decide in
ten seconds what the loop could not decide in two.

Levels 1, 2, 4 and 5 are **not** subject to this limit. They are objective, they
converge, and they get fixed until they pass.
