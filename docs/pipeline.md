# Pipeline

Ten phases. Three of them are conditional or mode-dependent. All of them commit.

## Mode detection (before phase 1)

The skill inspects `design/` before doing anything else.

| Condition | Mode | Effect |
|---|---|---|
| `design/design-direction.md` absent | **Bootstrap** | Full pipeline, phases 1–10 |
| `design/design-direction.md` present | **Incremental** | Skip phases 2 and 4; load existing constraints first; audit gains criteria 1.7 and 1.8 |

**Incremental mode loads before it touches anything:** `design/brand.md`,
`design/design-direction.md`, `design/design-spec.md`, the canvas variables via
`Print(GetVariables())`, and the design-system region via a `Get` visitor. It
needs to know what exists by name before it can avoid duplicating it.

Without this split, every round redesigns the product from scratch and the
`.pen` file becomes a patchwork of three different design systems.

**The brand condition is separate and independent of the mode.** Phase 3 runs
when there is no `design/brand.md` *and* the user supplied no brand — including
in a project that already has research, direction, and screens. If a brand
exists in either form, it is loaded as a constraint and the phase is skipped.

## Phase 1 — Intake

| | |
|---|---|
| **In** | The user's request |
| **Out** | `design/product-spec.md` |
| **By** | The skill |
| **Template** | `product-spec.template.md` |

Personas, jobs, core loop, screen inventory, and — the part that matters most —
the **state inventory**: for every screen, which of empty / loading / error /
first run / long list / long text / permission denied apply, and what each
shows. Phase 8's completeness level checks against this table. A state missing
here is a state nobody will notice is missing from the canvas.

Anything the request left silent is decided, not asked, and recorded under
Assumptions.

## Phase 2 — Research *(skipped in incremental mode)*

| | |
|---|---|
| **In** | `design/product-spec.md` |
| **Out** | `design/research.md` |
| **By** | `prototypen:researcher` |

Competitor set, domain conventions, domain antipatterns, and the **brand
territory already occupied** — competitor naming patterns, tone, palettes,
archetypes, visual register — closing with which positions look unoccupied. All
sources cited; gaps in the evidence reported as gaps.

The last section exists entirely to feed phase 3. **Research must precede brand**,
because a brand invented from the idea alone lands where everyone else already
is: the same idea suggests the same associations to everyone.

## Phase 3 — Brand *(conditional)*

| | |
|---|---|
| **In** | `design/research.md`, `references/brand.md` |
| **Out** | `design/brand.md`, `design/brand/logo/*.svg` |
| **By** | `prototypen:brand-designer` |
| **Template** | `brand.template.md` |

Name, name rationale, availability check (explicitly not a legal clearance),
one-sentence positioning, tone of voice with do/don't examples, archetype,
primary palette, brand typography, and what the brand is not.

Five logo SVG variants — primary, horizontal, symbol, mono, inverse — plus clear
space, minimum size, and misuse rules. The mark is generated **once** with
`Generate(frameId, "svg", …)` and the variants are built from it; generating
five times produces five different logos.

Output enters phase 4 as a **constraint, not a suggestion**.

## Phase 4 — Direction *(skipped in incremental mode)*

| | |
|---|---|
| **In** | `design/product-spec.md`, `design/research.md`, `design/brand.md`, `references/design-direction.md`, `references/anti-generic.md` |
| **Out** | `design/design-direction.md` |
| **By** | The skill |
| **Template** | `design-direction.template.md` |

Two divergence axes chosen for this project. Three directions placed at
genuinely different points on them, each declaring nine things: testable
personality sentence, type pairing, modular scale with its ratio, palette from a
concept, density, grid, edge treatment, motion, and what it rejects.

Then a written choice against criteria tied to the audience and the job — never
to taste — plus a paragraph on why each of the other two was rejected, the
explicit justification for any ban-list item used, and the named **committed
choice** the audit will look for in a screenshot.

If none of the three can live with the brand, the directions are wrong.
Regenerate them; never loosen the brand.

**This file is the constraint every later phase is audited against.** A vague
direction file is a worse failure than a bad one, because it makes the audit
unfalsifiable.

## Phase 5 — Canvas structure

| | |
|---|---|
| **In** | `design/product-spec.md`, `references/canvas-structure.md` |
| **Out** | Named, empty region frames in the `.pen` file |
| **By** | `prototypen:designer` |

The **empty named skeleton only**: a `Design System` region at the top, a
`Brand` region, and one `Flow — <Name>` region per flow, placed with
`FindEmptySpace` so nothing overlaps. Nothing inside them yet.

Creating elements first and organizing afterward does not work: by the time
there is something to organize, moving it costs more than placing it right would
have.

## Phase 6 — System

| | |
|---|---|
| **In** | `design/design-direction.md`, `design/brand.md` |
| **Out** | `.pen` variables and base components in the `Design System` region |
| **By** | `prototypen:designer` |

Tokens go in as **variables** via `SetVariables` — color, type, spacing, radius,
border, shadow — never as repeated literals. Then base components as
`reusable: true` frames, each with its variants and states laid out beside it
and named accordingly.

The designer cannot invent a token. If the direction does not define something,
it stops and reports; the direction file is amended by decision, never extended
by improvisation.

## Phase 7 — Screens

| | |
|---|---|
| **In** | Everything above, plus the flow's screens and states |
| **Out** | Screens inside their flow regions |
| **By** | `prototypen:designer`, **one subagent per flow, in parallel** |

Each subagent receives the direction file, the brand file, the names of existing
tokens and components, its flow's screens and states, its target region, and the
user's language. Screens go in navigation order with a constant gap.

Parallelism is per-flow because flows are the natural isolation boundary — they
never share a region, so two designers cannot collide.

## Phase 8 — Audit

| | |
|---|---|
| **In** | The canvas, `references/audit-rubric.md`, and every constraint file |
| **Out** | `design/audits/<YYYY-MM-DD>.md`, plus fixes |
| **By** | `prototypen:auditor`, **in a fresh context** |

Four levels, in order: structural (no screenshot), canvas organization (no
screenshot), visual (screenshot), completeness. Binary PASS/FAIL, every FAIL
naming the node and the fix.

Failures go back to a `prototypen:designer`. **At most 3 fix cycles per screen**
at the visual level — past three it oscillates rather than converges. On the
third failure the finding is written down as unresolved and the run moves on.
Levels 1, 2, and 4 are objective, converge, and are fixed until they pass.

Incremental mode adds two hard failures: a hardcoded value where a token exists,
and a new component duplicating an existing one.

## Phase 9 — Organization review

| | |
|---|---|
| **In** | The canvas, `references/canvas-structure.md` |
| **Out** | A clean canvas |
| **By** | `prototypen:auditor` |

**Mandatory at the end of every round**, including an incremental round that
touched a single screen. Nine checks: loose elements at the root, elements
bleeding past bounds, overlapping elements, overlapping regions, unnamed boxes,
duplicate names, screens out of flow order, flows sharing a region, inconsistent
gaps.

Eight of the nine are structural and run through `Get` visitors with
`ctx.bounds` and `ctx.problems`. One `TakeScreenshot(["document"])` covers the
macro arrangement — whether the canvas reads as an organized document to someone
opening it cold.

Everything found is **fixed before handoff**, never filed as a note.

## Phase 10 — Handoff

| | |
|---|---|
| **In** | The canvas, every constraint file, the latest audit |
| **Out** | `design/design-spec.md` |
| **By** | The skill |
| **Template** | `design-spec.template.md` |

Every token with its canvas variable name and intended code name. Every
component with variants, states, props, and the behavior the canvas cannot show.
The screen inventory with flows and built states. Focus order, responsive
behavior, motion, copy tone, accessibility decisions. And the **open findings**
carried over from the audit — what failed three cycles and needs a human.

## Commit points

`.pen` files are JSON, so they diff in git. **Commit at the end of every phase**,
canvas and documents together, with the phase in the message:

```
design: phase 6 — system tokens and base components
```

This is what makes the recovery rule possible. **When the audit condemns a
phase, go back to that phase's commit and redo it** — do not patch on top. A
patched direction or a patched token set leaks into every screen built
afterward, and the cost of unwinding it grows with each subsequent phase.

## Flow

```
                 mode detection
                       │
        ┌──────────────┴──────────────┐
   bootstrap                    incremental
        │                             │
   1 Intake                    load brand + direction
        │                       + spec + tokens
   2 Research                          │
        │                              │
   3 Brand ◄── conditional: no brand ──┤
        │                              │
   4 Direction                         │
        │                              │
   5 Canvas structure                  │
        │                              │
   6 System                            │
        └──────────────┬───────────────┘
                       │
                  7 Screens  (parallel, one per flow)
                       │
                  8 Audit ──► fix ──┐ max 3 cycles per screen
                       │◄───────────┘
                  9 Organization review  (always)
                       │
                 10 Handoff
```
