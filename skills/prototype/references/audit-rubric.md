# Audit rubric

Read this at phase 8 (audit) and phase 9 (organization review).

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
| 3.1 | The screen matches the chosen direction's **testable personality sentence** — hold the sentence next to the image and answer yes or no | Name which of the nine direction items is violated; redo against it. |
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

FAIL → build the missing state as a variant beside its screen, named per
`canvas-structure.md`.

States are built for the **primary viewport** and only carried to the second
where the state actually differs there — an empty state usually does, a loading
skeleton usually does not. Say which in the audit rather than demanding a full
cross-product.

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
