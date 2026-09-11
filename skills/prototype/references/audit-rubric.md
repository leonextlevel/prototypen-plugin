# Audit rubric

Read this at phase 8 (audit) and phase 9 (organization review).

Levels 1, 2 and 4 are checked against the canvas and the spec. Level 3 is checked
against `design/design-direction.md`, `design/brand.md`, `anti-generic.md`, and
**`screen-craft.md`** — the craft baseline the designer was given before drawing.
Criteria 3.12–3.16 below are the auditable form of that file, and 3.17–3.19 and
4.11 are the auditable form of `component-catalog.md`; when one fails,
cite the section of `screen-craft.md` it comes from so the fix is unambiguous.

Every criterion below gets a **binary verdict** — PASS or FAIL. Not a score, not
"mostly", not "could be improved". A rubric that admits degrees gets everything
graded B+ and nothing fixed.

The auditor runs in a **separate context** from whoever produced the work. Self-
review in the same context approves its own work — it has already justified every
decision to itself once.

Run the levels in order. Level 1 and 2 need no screenshot and are nearly free;
finding a structural failure there saves the expensive visual pass on work that
has to be redone anyway.

## Report format

Write `design/audits/<YYYY-MM-DD>.md` in the user's language:

```
## <Screen or region name>
- [PASS] <criterion>
- [FAIL] <criterion> — <what is wrong, where, and what to do about it>
```

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

**Incremental mode adds these two, and they are hard failures:**

| # | Criterion | FAIL → |
|---|---|---|
| 1.9 | No new hardcoded value where a token already exists | Use the existing token. This is not a creative choice; it is drift. |
| 1.10 | No new component duplicating an existing one | Instance the existing one. A near-copy with a different name is the same failure. |

## Level 2 — Canvas organization

Detailed method in `canvas-structure.md`. Mandatory every round.

| # | Criterion |
|---|---|
| 2.1 | No loose element outside a box (nothing under `document` but regions, screens, and reusable frames) |
| 2.2 | No element bleeding past its container's bounds |
| 2.3 | No overlapping elements |
| 2.4 | No overlapping boxes or regions |
| 2.5 | Every box named |
| 2.6 | No duplicate names anywhere |
| 2.7 | Screens in navigation order within their flow |
| 2.8 | No two flows sharing a region |
| 2.9 | Constant gap between screens within a region |
| 2.10 | Every declared viewport has a screen set, and viewports are not mixed in one region |

FAIL → fix by `Move`, `Update` on `x`/`y`, resize, or rename. **Never by
deleting and rebuilding.** Fixed before handoff, never filed as a note.

## Level 3 — Visual (screenshot)

Only reached once levels 1 and 2 pass. `TakeScreenshot` on the **smallest
meaningful node** — a screen frame, not the document.

| # | Criterion | FAIL → |
|---|---|---|
| 3.1 | The screen matches the chosen direction's **testable personality sentence** — hold the sentence next to the image and answer yes or no | Name which of the eleven direction items is violated; redo against it. |
| 3.2 | The direction's **committed choice** is visible and nameable | If the auditor cannot name it from the picture, it is not there. |
| 3.3 | Nothing on the `anti-generic.md` ban list appears unjustified | Cite the item and the direction file's silence on it; replace. |
| 3.4 | Brand adherence — palette, type, tone of the microcopy, logo used per its rules | Cite the `brand.md` clause. |
| 3.5 | Hierarchy — the single most important thing on the screen is the most prominent; you can rank the top three at a glance | Adjust scale, weight, value, or position — not by adding a shadow. |
| 3.6 | Contrast meets **WCAG AA in every declared theme**: 4.5:1 body text, 3:1 text ≥24px or ≥19px bold, 3:1 for UI component and state boundaries. Check each theme separately — a palette that passes in light routinely fails in dark | Adjust the token for the failing theme, not the instance. If the direction's palette cannot pass in a declared theme, the palette is wrong. |
| 3.7 | Touch targets ≥44×44pt on touch, with spacing between adjacent targets | Enlarge the target, not just the icon. |
| 3.8 | Alignment and optical spacing — items that should align do, gaps read as even | Fix with layout, not by nudging pixels. |
| 3.9 | Copy is in the **user's language**, and matches the brand's tone | Rewrite. English microcopy for a Portuguese-speaking user is a FAIL, not a detail. |
| 3.10 | The screen holds up **at every declared viewport** — density, grid, navigation and information order suit the width it is for, rather than being the other viewport rescaled | Redesign for that viewport against its own density and grid from the direction file. |
| 3.11 | The `Theme Check` screens render correctly in the non-default theme — no invisible text, no glaring accent, no surface collapsing into its background | Fix the theme's token values, then re-check. Never fix by hardcoding a color into the screen. |
| 3.12 | **Navigation** matches the direction's declared system, is identical across every screen in the flow, shows the current location, and offers a working back affordance. Primary tasks reachable in two steps | Fix the structure, not the label. If the direction never declared a navigation system, that is a phase-4 failure — say so rather than inventing one at audit time. |
| 3.13 | **Nothing touches a container edge.** Every screen, card, modal, cell and button gives its content inset on all four sides — the designed insets, not device chrome | Add the inset from the direction's spacing rules. |
| 3.14 | **Spacing comes from the scale, and proximity groups.** Related items sit closer than unrelated ones; gaps between groups are visibly larger than gaps within them; adjacent interactive elements have a gap | Uniform spacing between every child of a container is a defect — it means nothing was grouped. Apply the two-tier gap from the direction. |
| 3.15 | **Alignment holds.** One dominant alignment edge; body text and forms ranged left, not centered; numeric columns right-aligned with matching headers; icons optically centered against their labels | Fix with layout, not by nudging. A centered paragraph is a FAIL. |
| 3.16 | **Type sizing is legible and ranked**: body ≥16 on mobile, nothing readable below 12, line length 45–75 characters, no more than ~3 type sizes on a simple screen | Consolidate to the scale's steps. A new size needs a new job. |
| 3.17 | **Destructive actions confirm in a modal** (bottom sheet on mobile) shaped per `component-catalog.md`: title names the thing, body states the consequence, destructive button is a verb with the object in the destructive color, Cancel is the safe default. Reversible actions do *not* confirm — they act and offer Undo | A destructive action with no confirmation, or a dialog whose confirm button says "OK"/"Yes", is a FAIL. A confirm dialog on a reversible action is also a FAIL — it trains click-through. |
| 3.18 | **The lightest component that holds the task was used.** No full screen for a confirmation, a quick edit, a short choice or a filter; no modal where a popover or toast would do; no toast carrying an error the user must act on | Cite the catalog ladder (tooltip → popover → menu → toast → sheet → modal → screen) and the right rung. |
| 3.19 | **Every action gives feedback** — a toast on success, inline validation on a field, a blocking dialog only when blocking is warranted; loading shown on the control that was pressed | Add the feedback at the right weight. Silence after an action is a FAIL. |
| 3.20 | **The screen shows all of its content.** The frame is viewport-width and content-height; nothing is clipped, dropped or truncated to fit a device height or to make room for a tab bar; bottom navigation follows the content rather than displacing it | Resize the frame to `fit_content` and restore what was cut. A screen that "looks like a phone" but hides a third of its content is a FAIL — the implementer will build what is visible. |
| 3.21 | **No safe-area bands.** No empty reserved space for status bar, notch, dynamic island or home indicator at the top or bottom of a mobile screen | Remove the band. Safe insets are the implementer's, and `design-spec.md` says so. |

## Level 4 — Completeness

Checked against the screen and state inventory in `design/product-spec.md`.
These are the states that are always missing, because they are the ones nobody
thinks about while designing the happy path.

| # | State | Present for every relevant screen? |
|---|---|---|
| 4.1 | **Empty** — no data yet, with a way forward, not just a shrug |
| 4.2 | **Loading** — and it matches the shape of what is coming |
| 4.3 | **Error** — says what happened and what to do, in the user's language |
| 4.4 | **First run** — the very first time, before anything exists |
| 4.5 | **Long list** — enough items to show pagination, scroll, or virtualization |
| 4.6 | **Long text** — the longest realistic name, label, and body, in the user's language (which may be ~25% longer than English) |
| 4.7 | **Permission denied / restricted** — the user cannot do this, and it says why |

| 4.8 | **Every declared viewport** has the flows and screens the spec lists for it |
| 4.9 | **Every declared theme** has token coverage, and the `Theme Check` set exists |
| 4.10 | **The secondary screens the context requires exist** — for a mobile app that means at least splash, first run, permission request *and* permission denied, and offline where a network is involved; for a web app 404, no-access and session-expired; for a marketing site 404 and form confirmation. Catalog in `screen-craft.md` |
| 4.11 | **The forgotten actions are present** where they apply — create (reachable from the empty state too), edit, delete, duplicate, search, filter, sort, bulk select, share/export, undo, retry, refresh, sign out, help. Checked against the list in `component-catalog.md` per collection and object screen |

FAIL → build the missing state as a variant beside its screen, named per
`canvas-structure.md`.

States are built for the **primary viewport** and only carried to the second
where the state actually differs there — an empty state usually does, a loading
skeleton usually does not. Say which in the audit rather than demanding a full
cross-product.

## What the designer already checked

Before reporting a screen, the designer runs the self-review in section 8 of
`screen-craft.md` — a `Get` pass for clipping, missing fills, literals,
near-miss alignment and overlap, and one screenshot for the obvious. Its report
names anything it left open.

Read that report first. **If you find something mechanical that the self-review
should have caught and the report does not mention, say so explicitly in the
finding** ("not caught by self-review") — that is a process signal worth more
than the defect itself, and it is how the self-review procedure gets tightened.
Do not soften the FAIL because of it.

## The attempt limit

**At most 3 fix cycles per screen.**

Screenshot-based visual critique is good at hierarchy and gross error, and weak
at refinement. Past three cycles it stops converging and starts oscillating —
each pass finds a new subjective complaint and the screen changes without
getting better.

On the third failure: **stop**. Record in the audit report what is still wrong,
what was tried, and why it did not resolve. Then move on. An honest open finding
is worth more than a fourth pass, and a human reading the report can decide in
ten seconds what the loop could not decide in three.

Levels 1, 2, and 4 are **not** subject to this limit. They are objective, they
converge, and they get fixed until they pass.
