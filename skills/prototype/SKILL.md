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

## Step 0 — Mode detection (do this first, always)

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
| 8 | Audit | `design/audits/<YYYY-MM-DD>.md` + fix loop | `prototypen:auditor` |
| 9 | Organization review | final canvas sweep, mandatory | `prototypen:auditor` |
| 10 | Handoff | `design/design-spec.md` mapping tokens and components to code | this skill |

Do not insert approval gates between phases. This pipeline is built for a long
unattended run; the audit phases are the quality control, not the user.

### 1 — Intake

Read the request. Write `design/product-spec.md` from
`templates/product-spec.template.md`: personas, the jobs each one hires the
product for, the screen inventory, and **every state per screen** (empty,
loading, error, first run, long list, long text, permission denied). The state
inventory here is what the completeness audit in phase 8 checks against — if a
state is missing from the spec, nobody will notice it is missing from the canvas.

Ask nothing you can decide. Where the request is silent, decide, and record the
assumption in a "Assumptions" section of the spec.

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

Pick two divergence axes for this project. Produce three directions placed at
genuinely different points on them. Each direction declares a type pairing and a
modular scale with its stated ratio, a palette derived from a concept, a target
density, a grid, a border/radius/shadow treatment, a motion treatment, and a
one-sentence testable personality.

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

Delegate to `prototypen:designer`: create the **named, empty box grid first** —
a region for the design system, a region for the brand, one region per flow —
and nothing inside them yet. Creating elements first and organizing afterward
does not work; the canvas has to be built into a skeleton that already exists.

### 6 — System

Delegate to `prototypen:designer`. Tokens go in as **variables in the `.pen`
file** (`SetVariables`), never as repeated literal values: color, type scale,
spacing, radius, border, shadow, from `design/design-direction.md` and
`design/brand.md`. Then the base components, each placed in the design-system
region with its variants and states laid out beside it.

The designer may not invent a token. If something is needed that the direction
does not define, it stops and reports; you decide and amend the direction file.

### 7 — Screens

One `prototypen:designer` subagent per flow, in parallel. Each gets: the
direction file, the brand file, the token and component names that already
exist, the flow's screens and states from the product spec, its target box in
the canvas grid, and the user's language.

Screens go inside their flow's box in navigation order.

### 8 — Audit

Read `references/audit-rubric.md`. Delegate to `prototypen:auditor` in a fresh
context — never let the agent that drew a screen judge it. Self-review in the
same context approves its own work.

The auditor writes `design/audits/<YYYY-MM-DD>.md` with a binary verdict per
criterion. Failures come back to a `prototypen:designer` as fixes.

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
| `references/canvas-structure.md` | phase 5, and phase 9 always |
| `references/audit-rubric.md` | phases 8 and 9 |
| `references/pencil-mcp.md` | before the first Pencil call of the session |

## Preconditions

The pen.dev app must be running with a `.pen` file open — every Pencil MCP tool
fails without one. If the tools report no open file, say so plainly and stop;
this pipeline cannot produce its main artifact without a canvas. The design
documents in `design/` can still be produced, and are worth producing, but say
which half you delivered.
