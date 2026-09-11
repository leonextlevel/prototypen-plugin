---
name: prototype
description: Autonomous product prototyping on the Pencil (pen.dev) canvas. Use this skill whenever the user wants to turn an idea, a feature request, or a set of requirements into screens, a navigable prototype, a design system, a brand, or design documentation — including when they never say the word "prototype". Trigger it for "design an app for X", "mock up this screen", "create a design system", "build the UI for this idea", "make a landing page", "draw this in Pencil", "set up tokens and components", "name and brand this product", "design the onboarding flow", "add a screen to the existing design", or any request that would otherwise be answered by inventing UI on the fly. It is the default path for visual product work, not a specialist tool held in reserve.
---

# Prototype

Turn an idea plus requirements into a navigable prototype and a complete design
system on the Pencil canvas, plus the design documents that hand off to
implementation.

The problem this exists to solve: AI-generated design has a recognizable generic
face — Inter, blue `#3b82f6`, soft-shadowed white card, centered hero, purple
gradient, pastel circle icon. This is not fixed by asking for creativity. It is
fixed by **declaring constraint before generation** and auditing against that
declaration afterward. Every phase below either produces a constraint or is
judged against one.

## Language rule

Detect the user's language from their own messages and work in it.

- **In the user's language:** everything you say in conversation, and every
  artifact this pipeline produces — `design/product-spec.md`, `research.md`,
  `brand.md`, `design-direction.md`, audit reports, `design-spec.md` — plus all
  text inside the canvas: labels, headings, microcopy, button text, sample
  content, empty-state copy.
- **In English, always:** artifact file names, directory names, canvas box and
  layer names, variable/token names, component names. These stay stable across
  rounds and across whoever is running the plugin.
- Templates in `templates/` are written in English. When you instantiate one,
  translate the section headings into the user's language; do not copy English
  headings into a Portuguese document.
- Every subagent runs in an isolated context and cannot see the user's original
  message. **State the detected language explicitly in every subagent prompt**
  (e.g. "The user's language is Brazilian Portuguese; write all prose and all
  canvas copy in it"). Without this the auditor hands a Portuguese-speaking user
  an English report.

## Targets are a contract

`design/product-spec.md` carries a **Targets** table: which viewports (desktop,
mobile, or both) and which themes (light, dark, or both), with a primary named
for each. `/prototypen:discover` always asks; when it has not run, phase 1
decides and records the decision.

**Every phase is bound by that table and none may narrow it.** The direction
declares a density and grid per viewport and a palette per theme; the tokens are
themed variables; the canvas carries a screen set per viewport; the audit checks
contrast in every declared theme.

Two rules keep this from multiplying the work:

- **Viewport duplicates screens.** A desktop table and a mobile card list are
  different designs, not one design at two widths. Build the primary viewport
  first and completely, through the audit; derive the second from a design that
  has already been judged.
- **Theme does not duplicate screens.** pen.dev variables are themed natively, so
  one screen renders in every theme *provided every color is a variable*. A
  hardcoded hex is the single defect that silently breaks a whole theme. Verify
  with a small `Theme Check` set of two or three representative screens, not a
  duplicated canvas.

Details in `references/canvas-structure.md`.

## Step 0 — The canvas file (before thinking about anything else)

The canvas for a project is **always `design/prototype.pen`**, relative to the
project root. Fixed name, fixed place, so every round and every agent finds it
without being told.

Do this before mode detection, before reading the request in detail, before any
other tool call:

1. Call `get_app_state` and read the **currently active canvas editor** path.
2. If it is `<project>/design/prototype.pen` — proceed.
3. If it is anything else — a different file, or no file open — **stop here, once,
   and ask the user** in their language to create `design/prototype.pen` (if it
   does not exist yet) and open it in the Pencil editor. Say all of this in the
   same message:
   - what to do: create the file at that exact path and open it as a Pencil
     canvas, in the VS Code window of this project;
   - **why now**: this is a long autonomous run that will not stop for input
     again — the canvas has to be right before it starts, because there is no
     safe place to fix it in the middle;
   - what happens next: once they confirm, the run goes from here to handoff
     without further questions.
4. When the user confirms, call `get_app_state` **again** and re-check the path.
   Do not take their word for it — the check is free and the failure is not.
5. Only then continue.

**Never proceed with a different file active.** This is not caution for its own
sake: `execute` with a `filePath` that does not exist **silently redirects to
whatever canvas is active** — it returns OK and writes there. A pipeline that
skipped this check could build the entire prototype into the wrong document
without a single error. Verified on the live server; details in
`references/pencil-mcp.md`.

This is the **only** place the pipeline stops for input. It is at the very
beginning precisely so it never has to be in the middle.

Do not try to open the file yourself with `code <path>`: it can land in another
VS Code window, and it triggers a trust prompt the user has to click through —
either way the active canvas may not be the one you need, and you cannot see
which. Ask, then verify.

## Step 1 — Mode detection (right after the canvas check)

Look at `design/` in the current project before anything else.

**Bootstrap mode** — `design/design-direction.md` does not exist. Run the full
pipeline below.

**Incremental mode** — `design/design-direction.md` exists. Then:

1. Skip Research and Direction.
2. **Before touching anything**, load into context: `design/brand.md`,
   `design/design-direction.md`, `design/design-spec.md`, and the existing
   canvas — read the token variables (`GetVariables`) and the component region
   of the canvas hierarchy (`Get`) so you know what already exists by name.
3. Go straight to the phase the request needs (usually Screens).
4. The audit gains one extra pass/fail criterion: **a hardcoded value where a
   variable exists, or a new component that duplicates an existing one, is a
   failure — not a creative choice.**

Without this split, every round redesigns the product and the `.pen` file turns
into a patchwork.

**Brand is a separate conditional, independent of the mode above.** The brand
phase runs whenever there is no `design/brand.md` *and* the user supplied no
existing brand — even in a project that already has research, direction, and
screens. If brand assets exist, load them as a constraint and skip the phase.

## Pipeline

| # | Phase | Output | Executed by |
|---|---|---|---|
| 1 | Intake | `design/product-spec.md` — personas, jobs, screen and state inventory | this skill |
| 2 | Research | `design/research.md` — domain conventions, antipatterns, sources | `prototypen:researcher` |
| 3 | Brand *(conditional)* | `design/brand.md` + `design/brand/logo/*.svg` | `prototypen:brand-designer` |
| 4 | Direction | 3 directions on opposed axes + a justified choice → `design/design-direction.md` | this skill |
| 5 | Canvas structure | named, empty box grid in the `.pen` file, before any element | `prototypen:designer` |
| 6 | System | tokens as `.pen` file variables, base components | `prototypen:designer` |
| 7 | Screens | one subagent per flow, in parallel | `prototypen:designer` |
| 7b | Layout review | composition, alignment, distribution, space — per flow, geometry first | `prototypen:layout-reviewer` |
| 8 | Audit | `design/audits/<YYYY-MM-DD>.md` + fix loop | `prototypen:auditor` |
| 9 | Organization review | final canvas sweep, mandatory | `prototypen:auditor` |
| 10 | Handoff | `design/design-spec.md` mapping tokens and components to code | this skill |

Do not insert approval gates between phases. This pipeline is built for a long
unattended run; the audit phases are the quality control, not the user.

### 1 — Intake

**If `design/product-spec.md` already exists, read it and skip to phase 2.**
`/prototypen:discover` produces that file interactively; when it has run, the
intake is done and redoing it would discard answers a human actually gave.

Otherwise, write it yourself from `templates/product-spec.template.md`: the
**Targets** table (viewports and themes — decide them, never leave them
unstated), personas,
the jobs each one hires the product for, the core loop, the screen inventory, and
**every state per screen** (empty, loading, error, first run, long list, long
text, permission denied). The state inventory here is what the completeness audit
in phase 8 checks against — if a state is missing from the spec, nobody will
notice it is missing from the canvas.

The spec also carries the **navigation map**: one row per screen and overlay,
what opens it and every way out. It is written here, before anything is drawn,
because an orphan screen or a dead end costs a row to prevent and a fix cycle to
find. Every screen needs an entry and an exit; every overlay needs a dismiss and
a completion path; every flow has a wired first screen and a last screen that
returns somewhere.

The inventory covers the flows **and the secondary screens the context requires**
— a mobile app needs a splash, a first run, a permission request and its denied
state; a web app needs 404, no-access and session-expired; a marketing site needs
404 and a form confirmation. Nobody lists these as features, so nobody notices
they are missing until they are. The catalog is in `references/screen-craft.md`;
decide from context which apply rather than building all of them.

Ask nothing you can decide. Where the request is silent, decide, and record the
assumption in an "Assumptions" section of the spec.

One exception to the no-questions rule, and it is a mention rather than a
question: if the request is thin enough that the assumptions would outnumber the
facts — no stated users, no context of use, no frequency — say in **one line**
that `/prototypen:discover` would collect that first, and then **proceed anyway**
under your own assumptions. Never wait for an answer. This is a long unattended
run; a spec built on recorded guesses is worth more than a pipeline stopped at
phase 1.

### 2 — Research

Delegate to `prototypen:researcher`. It returns `design/research.md`: how
products in this domain actually behave, what users of this domain already
expect, the antipatterns specific to it, the competitor set, and — critically
for phase 3 — the **brand territory already occupied**: competitor names, tone,
palettes, archetypes. Sources cited.

Research feeds brand. Do not reorder these.

### 3 — Brand (conditional)

Read `references/brand.md` before running this phase.

Runs only when there is no brand. Delegate to `prototypen:brand-designer`, which
produces `design/brand.md` (name, name rationale, availability check,
one-sentence positioning, tone of voice, archetype, primary palette, brand
typography, and what the brand is *not*) and the logo SVGs in
`design/brand/logo/` with all required variants.

The brand enters phase 4 as a **constraint, not a suggestion**.

### 4 — Direction

Read `references/design-direction.md` before running this phase, and
`references/anti-generic.md` alongside it.

Read the Targets table first. Pick two divergence axes for this project. Produce
three directions placed at genuinely different points on them, each one specified
for **every declared viewport and theme** — a direction that only works at one
viewport, or in one theme, is not a candidate. Each direction declares eleven
things: a type pairing, a modular scale with its stated ratio, a palette derived
from a concept, a target density with its spacing scale, a grid, a
border/radius/shadow treatment, a motion treatment, a **navigation system per
viewport**, an **alignment posture**, what it rejects, and a one-sentence testable
personality.

The last two additions are the ones most often skipped and the most expensive to
skip. Navigation decided here once — pattern, destinations, current-location
indicator, back behavior, primary action placement — is executed identically
everywhere; left undecided, every screen invents its own and the audit catches it
only after all of them are drawn. Same for the spacing application rules (edge
inset, component padding, gap within a group vs. between groups): a scale nobody
knows how to apply produces evenly-spaced mush.

Then choose one, in writing, against criteria tied to the audience and the job —
not to taste. If none of the three can live with the brand, the directions are
wrong; regenerate them. Write the chosen direction, and why the other two were
rejected, to `design/design-direction.md`.

This file is the constraint every later phase is audited against. Everything on
the ban list in `references/anti-generic.md` is forbidden unless this file
explicitly justifies it.

### 5 — Canvas structure

Read `references/canvas-structure.md` before this phase. It is the whole
specification for this step.

This is the first canvas write. **Re-check `get_app_state` first**: the active
canvas must still be `design/prototype.pen`. The user may have switched tabs
during the document phases, and a write to the wrong file is silent.

Delegate to `prototypen:designer`: create the **named, empty box grid first** —
a region for the design system, a region for the brand, and one region per flow
**per declared viewport** (`Flow — Checkout / Mobile`) — and nothing inside them
yet. Creating elements first and organizing afterward
does not work; the canvas has to be built into a skeleton that already exists.

### 6 — System

Delegate to `prototypen:designer`. Tokens go in as **variables in the `.pen`
file** (`SetVariables`), never as repeated literal values: color, type scale,
spacing, radius, border, shadow, from `design/design-direction.md` and
`design/brand.md`. **Every color token carries a value for every declared
theme**, as a `{value, theme}` array — a token with one value in a two-theme
project breaks that theme everywhere it is used. Then the base components, each placed in the design-system
region with its variants and states laid out beside it. **Decide the set by
walking the screen inventory against `references/component-catalog.md`**: for
each screen, which jobs does it do — confirm, choose, input, act, navigate,
disclose, show a collection, show status — and which component does each job.
That produces the subset this product needs, and it surfaces the overlays
(modal, sheet, drawer, popover, toast) a screen-by-screen build would forget to
make.

The designer may not invent a token. If something is needed that the direction
does not define, it stops and reports; you decide and amend the direction file.

### 7 — Screens

One `prototypen:designer` subagent per flow, in parallel. Each gets: the
direction file, the brand file, the token and component names that already
exist, the flow's screens and states from the product spec, its target box in
the canvas grid, **its viewport and that viewport's density and grid**, and the
user's language.

Run the **primary viewport for every flow first**, audit it, and only then derive
the second viewport. Building both at once doubles the work that a failed audit
throws away.

When dark is in scope, finish by building the `Theme Check` set — two or three
representative screens (the densest, one carrying imagery, one with an error or
destructive state) in the design-system region.

Screens go inside their flow's box in navigation order.

Each designer reads `references/screen-craft.md` first — the baseline of
established practice, and the source of audit criteria 3.12–3.16. Building content
first and placing navigation after it, keeping every screen content-height so
nothing is cut to fit a device, insetting content from every container edge,
grouping by proximity instead of spacing uniformly, and holding one alignment
edge are what most findings would otherwise be about.

**Every screen shows all of its content.** Frames are viewport-width and
`fit_content` in height — never a device height, never clipped. The prototype is
what the implementing agents will read; what is cut off will not be built. And
**no safe-area bands**: status bar, notch and home indicator are the
implementer's, and the handoff says so. Handing the
designer that standard up front is cheaper than discovering it in the audit.

**Every screen is self-reviewed before it is reported done, and every flow
after its last screen** — the procedure is section 7 of `screen-craft.md`. This
is a mechanical pass for the obvious: a `Get` visitor for clipping, missing
fills, color literals, near-miss alignment and overlap, then one screenshot read
as a stranger would for crowding, edge contact, wrong color, contrast, text
problems and confusion. Two self-fix passes at most. It is not the audit — the
designer cannot judge its own taste — and it exists so the auditor never spends
one of a screen's three fix cycles on something a visitor could have caught.

**Not every task is a screen.** Confirmations, quick edits, short choices and
filters belong in an overlay on the screen the user is already on; the catalog's
ladder — tooltip → popover → menu → toast → sheet → modal → screen — picks the
lightest that holds it. Destructive actions always confirm in a modal; reversible
ones act immediately and offer Undo.

### 7b — Layout review

After each flow's designer reports done (and after any audit fix that touched
layout), delegate that flow to `prototypen:layout-reviewer` in a fresh context.
It reads `references/layout.md` and only the alignment posture and spacing
rules from the direction, states each screen's composition intent, checks it
with `ctx.bounds` before any screenshot, **fixes mechanical geometry in place**
(a parent's `alignItems`, a `gap`, a sizing mode — never a nudged `x`), and
reports what it could not fix as change requests.

It exists because the defects it targets — a centered screen that is centered
only in its heading, a form with three field widths, a 3px offset, a column
hugging one side of a wide screen — are the ones a viewer feels instantly and
cannot name, and the ones every other reviewer's attention skips past. Cheap,
narrow, numeric. It does not judge design; anything it has an opinion about
outside geometry is one line for you and nothing more.

### 8 — Audit

Read `references/audit-rubric.md`. Delegate to `prototypen:auditor` in a fresh
context — never let the agent that drew a screen judge it. Self-review in the
same context approves its own work.

Five levels: structural, canvas organization and **navigation integrity** first
(no screenshot — the last one walks the spec's navigation map against the
canvas: every screen has a visible way in and a way out, every overlay a dismiss
and a completion path, every flow a wired start and an end that returns
somewhere), then visual, then completeness.

The auditor writes `design/audits/<YYYY-MM-DD>.md` with a binary verdict per
criterion, and **every FAIL classified**: `execution` (the constraint is right,
the screen is wrong) goes back to a `prototypen:designer` as a fix;
`direction` (the designer followed the direction and it is still wrong) and
`spec` (the product needs something the spec never listed) come to **you** as
change requests, and do not count against the screen's fix cycles. Handle them
under "Changes during the run" below before sending anything back to a
designer — a `direction` failure sent to the designer as `execution` burns three
cycles on a constraint that cannot be satisfied.

**Attempt limit: at most 3 fix cycles per screen.** Screenshot-based visual
critique is good at hierarchy and gross error and weak at refinement; past three
cycles it stops converging. Record the unresolved problem in the audit report
and move on.

### 9 — Organization review

Mandatory, at the end of every round of interactions, including incremental
rounds that touched one screen. Delegate to `prototypen:auditor` with the
organization section of `references/canvas-structure.md`: loose elements outside
any box, overlapping elements, overlapping boxes, screens out of flow order,
elements bleeding past their box bounds, unnamed or duplicate-named boxes,
flows mixed into one region. Use `Get` with `ctx.bounds` / `ctx.problems`, plus
one overview screenshot for the macro arrangement.

Everything found is **fixed before handoff**, not noted for later.

### 10 — Handoff

Write `design/design-spec.md` from `templates/design-spec.template.md`: every
token with its canvas variable name and its intended code name, every component
with its variants, states, and props, the screen inventory with its flows, and
the rules an implementer needs that the canvas cannot show (focus order,
responsive behavior, motion, copy tone).

## Changes during the run

Read `references/change-protocol.md` the first time any of these happens; it is
the full procedure. The short form:

Agents **raise**; only you **decide**. Three kinds:

- **Add** — a missing token, component, state or screen. Derive it from what
  exists (the palette's concept, the catalog, the direction's edge treatment),
  put it in the owning artifact, propagate down.
- **Amend** — a direction or brand decision that did not survive the real
  content. Change the smallest thing that resolves it, in a dated
  `## Amendments` section at the end of the file — never edit the original in
  place. **Twice on the same area in one round means the phase-4 decision was
  wrong: go back to that commit and redo it**, do not patch a third time.
- **Extend** — something the product needs that the spec did not ask for. If
  the existing jobs imply it, add it to the spec and build it. If it needs a
  new job or persona, write it under Out of scope and stop; new jobs are the
  user's.

Every decision propagates in order — spec → direction → variables → system
region → screens → re-review and re-audit of what it touched — then commits
with the change in the message, and gets an entry in **`design/changes.md`**
(kind, raised by, problem, decision, why, propagated to, commit). That log is
the user's window into a run that did not stop to ask; every entry should let
them disagree with one decision and know exactly what to revert.

What is *not* a change: a designer that did not follow the direction (fix the
screen), a geometry deviation the layout reviewer can fix (fixed), taste.

## Commit per phase

`.pen` files are JSON, so they diff in git. At the end of every phase, commit —
the canvas file and the design artifacts together, with the phase name in the
message (`design: phase 6 — system tokens and base components`).

When the audit condemns a phase, **go back to the previous commit and redo it**.
Do not patch a bad foundation on top of itself; a patched direction or a patched
token set leaks into every screen built after it.

## References

Read these when the phase that needs them starts — not up front, not all at once.

| File | Read it when |
|---|---|
| `references/brand.md` | phase 3, and any time the user brings an existing brand |
| `references/design-direction.md` | phase 4 |
| `references/anti-generic.md` | phase 4, phase 6, and every audit |
| `references/component-catalog.md` | phase 6 (choosing the base set), phase 7 |
| `references/screen-craft.md` | phases 6 and 7, and every audit fix |
| `references/layout.md` | phase 7 (designer), phase 7b (layout reviewer) |
| `references/change-protocol.md` | the first time an agent raises something it cannot do, or the audit returns a `direction`/`spec` failure |
| `references/canvas-structure.md` | phase 5, and phase 9 always |
| `references/audit-rubric.md` | phases 8 and 9 |
| `references/pencil-mcp.md` | before the first Pencil call of the session |

## Preconditions

The pen.dev editor must be running with `design/prototype.pen` open — that is
Step 0, and it is the single place this pipeline waits for the user. If the
canvas cannot be made available at all, say so plainly. The design documents in
`design/` can still be produced, and are worth producing, but say which half you
delivered.
