# Pipeline

Ten phases, run as eight steps: 5 and 6 are one designer task, and 9 is the
audit's final pass. Three are conditional or mode-dependent. All of them
commit. Around the pipeline sit four other skills: `discover` before it,
`brand` between discovery and the run when the user wants to choose the
identity, `finalize` after the last round, and `roadmap` after that
([usage.md](usage.md)).

## Step 0 — The access mode and the canvas file (before everything)

The canvas is always `design/prototype.pen`. Before mode detection, before
reading the request in detail, the skill creates the file if it is missing
(the editor's own four-line empty document), checks that the pen.dev CLI is
installed and logged in, and reads the spec's Targets table: a brand marked
"to be explored" with no `design/brand.md` means the user asked for
`/prototypen:brand` first. Then it **stops once and asks**, in one message
(`references/canvas-access.md`): which access mode, **headless** (the CLI,
no app open, saves itself; suggested for a bootstrap run) or **app mode**
(the MCP with pen.dev open, the plugin saves before every commit; suggested
for an incremental round); run the brand skill first or let this run decide
the brand; here is the branch the commits go to; from here to handoff there
are no more questions. On the answer it verifies rather than trusting: in
app mode `get_app_state` must report the file as the active editor; in
headless the runner refuses while the file is open in an app. It writes
`design/run.md` with the mode, creates the branch if the run protocol calls
for one, then continues.

The app-mode check exists because of a verified property of the Pencil MCP:
`execute` against a path that does not exist does not fail; it silently
writes into whatever canvas is active. A plugin hook denies any `execute`
whose path is not `<project>/design/prototype.pen`; the *active editor*
half it cannot see, so every canvas-writing agent repeats the
`get_app_state` check at the start of its task. Headless has no active
editor: the path is an argument, and the whole class of error goes away,
at the price of no live view. Both modes need the CLI, because the MCP has
no save and the desktop app does not autosave.

## Mode detection (after the canvas check, before phase 1)

The skill inspects `design/` before doing anything else.

| Condition | Mode | Effect |
|---|---|---|
| `design/design-direction.md` absent | **Bootstrap** | Full pipeline, phases 1–10 |
| `design/design-direction.md` present | **Incremental** | Skip phases 2 and 4; load existing constraints first; audit gains criteria 1.9 and 1.10 |

**Incremental mode loads before it touches anything:** `design/brand.md`,
`design/design-direction.md`, `design/design-spec.md`, the canvas variables via
`Print(GetVariables())`, and the design-system region via a `Get` visitor. It
needs to know what exists by name before it can avoid duplicating it.

Without this split, every round redesigns the product from scratch and the
`.pen` file becomes a patchwork of three different design systems.

**Discovery is a third, separate condition.** `/prototypen:discover` is an
optional interactive step that runs *before* the pipeline and produces
`design/product-spec.md`. It is not a phase and not a gate — it is an alternative
source for phase 1's output. When it has run, phase 1 is skipped; when it has
not, phase 1 writes the spec itself.

**The brand condition is separate and independent of the mode.** Phase 3 runs
when there is no `design/brand.md` *and* the user supplied no brand — including
in a project that already has research, direction, and screens. If a brand
exists in either form, it is loaded as a constraint and the phase is skipped.

## The Targets contract

`design/product-spec.md` carries a **Targets** table — declared viewports
(desktop, mobile, or both) and themes (light, dark, or both), each with a primary
named. `/prototypen:discover` always asks for both in its first round; when it
has not run, phase 1 decides and records the decision.

**No phase may narrow that table.** Phase 4 declares a density and grid per
viewport and a palette per theme, phase 6 writes themed variables, phase 7 builds
a screen set per viewport, and phase 8 checks contrast in each theme separately.

The cost is kept linear rather than combinatorial by treating the two axes
differently:

| Axis | Handling | Why |
|---|---|---|
| **Viewport** | one screen version per viewport, side by side in the same row | a desktop table and a mobile card list are different designs, not one design at two widths |
| **Theme** | themed variables, one screen set, plus two or three linked theme copies beside their source | pen.dev variables theme natively, so one frame renders in every theme, provided no color is ever a literal |

Every version of a screen lives in a row that is a horizontal layout frame
(`alignItems: "start"`), so the versions sit side by side and top-aligned
whichever is taller; states and overlays go in the rows below, one per row,
again every version side by side. The layout engine guarantees the
arrangement; the sweep only confirms it
(`skills/prototype/references/canvas-structure.md` §4).

Primary viewport is built and audited **first**; the second is derived from a
design that has already been judged, so a failed audit throws away half as much.

## Phase 1 — Intake *(skipped when discovery has run)*

| | |
|---|---|
| **In** | The user's request, or `design/product-spec.md` if it already exists |
| **Out** | `design/product-spec.md` |
| **By** | The skill, or `/prototypen:discover` beforehand |
| **Template** | `product-spec.template.md` |

**If `design/product-spec.md` exists, this phase is skipped.** The `discover`
skill produces that file interactively, and redoing the intake would discard
answers a human actually gave.

Personas, jobs, core loop, screen inventory, the **navigation map** (per screen
and overlay: what opens it, every way out — written before anything is drawn so
orphans and dead ends cost a row to prevent instead of a fix cycle to find),
the **depth** of the round (`core`, the default: the core loop, the required
secondary screens and the specific states, with the rest under Backlog;
`full`: everything; flows by job, at most eight per round), and the two
**state tables**. The generic states (empty, loading, error, first run, long
list, long text, permission denied) are inherited from one exemplar per
screen archetype, so that table names each screen's archetype and which
apply. The **specific states** table lists only what a screen has of its
own, with the reason; each row there becomes a screen row on the canvas,
and nothing else does. Phase 8's completeness level checks both tables.

When the product is something people sign up for, buy or download, intake
decides whether the round includes a **landing page**; when it does, the spec
carries the landing study (`references/landing-page.md`: the visitor, the one
action, the objections, the proof, the section order) and the landing flow
joins the inventory with its confirmation and submit-error screens.

Anything the request left silent is decided, not asked, and recorded under
Assumptions — with one exception, and it is a mention rather than a question. If
the request is thin enough that assumptions would outnumber facts, the skill says
in one line that `/prototypen:discover` would collect that first, then **proceeds
anyway** under its own assumptions. It never waits for an answer; that would be
an approval gate in a pipeline built not to have any.

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

When the user chose to explore the brand in discovery, `/prototypen:brand`
runs the same agent in candidate mode before the pipeline starts: three
candidates side by side in the `Brand` region, at most three rounds of
choosing and refining, the same `design/brand.md` at the end. The phase is
then skipped like any supplied brand.

## Phase 4 — Direction *(skipped in incremental mode)*

| | |
|---|---|
| **In** | `design/product-spec.md`, `design/research.md`, `design/brand.md`, `references/design-direction.md`, `references/anti-generic.md` |
| **Out** | `design/design-direction.md` |
| **By** | The skill |
| **Template** | `design-direction.template.md` |

Two divergence axes chosen for this project. Three directions placed at
genuinely different points on them, each declaring twelve things: testable
personality sentence, type pairing (Google Fonts families only — nothing else
renders), modular scale with its ratio, palette from a concept, density and
spacing with application rules, grid, edge treatment, motion, navigation system
per viewport, alignment posture, iconography system, and what it rejects. The
chosen direction also fills the **token inventory** — every required semantic
role by its fixed name, with a value per theme — so phase 6 has nothing to
guess and phase 7 nothing to stop on.

Then a written choice against criteria tied to the audience and the job — never
to taste — plus a paragraph on why each of the other two was rejected, the
explicit justification for any ban-list item used, and the named **committed
choice** the audit will look for in a screenshot.

If none of the three can live with the brand, the directions are wrong.
Regenerate them; never loosen the brand.

**This file is the constraint every later phase is audited against.** A vague
direction file is a worse failure than a bad one, because it makes the audit
unfalsifiable.

## Phase 5 — Component inventory (the skill)

Before the canvas is touched, the skill walks the screen inventory against
`references/component-catalog.md`: which jobs each screen does, which
component does each job, which overlays it opens, which navigation the
direction declared. The resulting component list (name, job, variants,
states, which screens use it) goes into `design/design-direction.md`. It
exists so that phase 7 finds components instead of inventing them: in the
first real project, the list was discovered flow by flow, and each discovery
became an amendment, a system round and a propagation across every flow.

## Phases 5 and 6 — Structure, then system (one designer task)

| | |
|---|---|
| **In** | `design/product-spec.md`, `design/design-direction.md` with its component list, `design/brand.md`, `references/canvas-structure.md` |
| **Out** | The region frames, then `.pen` variables, base components and the state exemplars in the `Design System` region |
| **By** | `prototypen:designer`, once, in that order; one commit when it reports |

Structure first: the **empty named skeleton only**, a `Design System` region
at the top, a `Brand` region, and one `Flow — <Name>` region per flow,
placed with `FindEmptySpace` so nothing overlaps. Creating elements first and
organizing afterward does not work: by the time there is something to
organize, moving it costs more than placing it right would have. The two
phases share a task because the order is what matters, not the handoff; a
second agent invocation for three empty frames bought nothing.

Then the system. Tokens go in as **variables** via `SetVariables` — the direction's inventory
under exactly its names — never as repeated literals. Then base components as
`reusable: true` frames, each with its variants and its **interaction states**
(default, hover, focus, pressed, disabled; error and filled for inputs, loading
for buttons, selected for options) laid out beside it and named accordingly.
Then the **state exemplars** in `Section / States`: for each screen
archetype the inventory uses (list, object, form, dashboard) and each
generic state, one screen-shaped frame built from those components, for the
primary viewport and for any viewport where the state differs. Every screen
of that archetype inherits them (`canvas-structure.md` §3b).

The designer cannot invent a token. If the direction does not define something,
it stops and reports; the direction file is amended by decision, never extended
by improvisation.

## Phase 7 — Screens

| | |
|---|---|
| **In** | Everything above, plus the flow's screens and states |
| **Out** | Screens inside their flow regions |
| **By** | `prototypen:designer`, **one subagent per flow, in parallel** |

Each subagent receives the access mode, the direction file with its
component list, the brand file, the names of existing tokens, components
and exemplars, its flow's screens with their specific states and overlays,
its target region, the viewport to build, the user's language and the
writing reference; it reads `references/designer-brief.md`, one file that
condenses the craft references. Inside the region it builds one column
group per screen in navigation order; the base row holds the screen's
versions side by side, each **specific** state gets its own row below, and
the overlay the screen is the first to open is shown in context in its row
(once per product). Generic states are not drawn; they are the exemplars.

A designer that needs a component the system lacks builds it from existing
tokens and reports it; the skill ratifies the phase's additions once and
propagates the ones that changed shape once, in one batch. At most two
system rounds after phase 6.

Parallelism is per-flow because flows are the natural isolation boundary — they
never share a region, so two designers cannot collide.

## Phase 7b — Layout review

| | |
|---|---|
| **In** | A finished flow, `references/layout.md`, the direction's alignment posture and spacing rules |
| **Out** | Geometry fixed in place; open items as change requests |
| **By** | `prototypen:layout-reviewer`, **in a fresh context**, per flow |

States each screen's composition intent from its archetype, checks it with
`ctx.bounds` — left edges, center axis, gaps, widths, dead space, row heights —
before any screenshot, fixes what is mechanical (a parent's `alignItems`, a
`gap`, a sizing mode, never a nudged `x`), and reports what is not as a change
request. Covers the flow's base screens and specific states; the exemplars
were reviewed with the system. Runs again after any audit fix that touched
layout.

Cheap and narrow by design. It does not judge; it verifies that centered is
centered, one edge is one edge, and equal is equal.

## Phase 8 — Audit

| | |
|---|---|
| **In** | The canvas, `references/audit-rubric.md`, and every constraint file |
| **Out** | `design/audits/<YYYY-MM-DD>.md`, plus fixes |
| **By** | `prototypen:auditor`, **in a fresh context** |

Two passes, two contexts. The **structural pass**, delegated with `model:
sonnet`, runs levels 1, 2, 4 and 5 over everything with no screenshot:
structure, canvas organization, completeness (the exemplars against the
generic-state table, the rows against the specific-state table, depth
against the backlog) and navigation integrity (the spec's navigation map
walked against the canvas for orphan screens and dead ends: every screen
with a visible way in and out, every overlay with a dismiss and a completion
path, every flow wired at both ends). The **visual pass**, on opus, runs
level 3 over the base screens, the specific states and the exemplars only;
a screen's generic states are the exemplar. Binary PASS/FAIL, every FAIL
naming the node and the fix.

Every FAIL is classified. `execution` failures go back to a `prototypen:designer`;
`direction` and `spec` failures go to the orchestrator as change requests (see
Changes, below) and do not count against the screen. **At most 2 fix cycles per
screen** at the visual level — past two it oscillates rather than converges. On
the second failure the finding is written down as unresolved and the run
moves on. Levels 1, 2, 4 and 5 are objective, converge, and are fixed until
they pass.

Incremental mode adds two hard failures: a hardcoded value where a token exists,
and a new component duplicating an existing one.

## Phase 9 — Organization sweep (the audit's last pass)

| | |
|---|---|
| **In** | The canvas, `references/canvas-structure.md` |
| **Out** | A clean canvas |
| **By** | `prototypen:auditor`, as the final pass of phase 8 |

**Mandatory at the end of every round**, including an incremental round that
touched a single screen. It is the rubric's level 2 in full, fourteen
structural checks (loose elements at the root, bleeding, overlaps, unnamed
or duplicate names, groups out of order, flows sharing a region, the
region/group/row layouts, a viewport missing from a base row, a version out
of its row, a `placeholder: true` left anywhere, exploration leftovers) plus
one `TakeScreenshot(["document"])` for whether the canvas reads as an
organized document to someone opening it cold.

It used to be a separate auditor invocation. It is now the first audit's
level 2, run once more after the last fix lands; when nothing needed fixing,
the first result stands. Same checks, one fewer context.

Everything found is **fixed before handoff**, never filed as a note.

## Phase 10 — Handoff

| | |
|---|---|
| **In** | The canvas, every constraint file, the latest audit |
| **Out** | `design/design-spec.md`, `design/tokens.json`, `design/tokens.css`, `design/screens/**` |
| **By** | The skill |
| **Template** | `design-spec.template.md`; procedure in `references/handoff.md` |

**Exports first**, because the `.pen` file is readable only inside pen.dev:
every screen version and state as PNG under `design/screens/<flow>/`, each
flow as HTML, the design-system and brand regions as images (the exemplars
with the design system), and the variables as `design/tokens.json` (W3C
Design Tokens, all themes) and `design/tokens.css`. Skipped when
`design/screens/.exported` names the current canvas commit. `design/screens/`
is written with its own `.gitignore` and never committed: the exports are
for validation, are regenerated on every handoff, and would bloat the
repository. Procedure in `references/handoff.md`.

Then `design-spec.md`: every token with its canvas variable name and intended
code name, every component with variants, states, props, and the behavior the
canvas cannot show, the screen table generated from the canvas by the
snippet in `handoff.md` (never typed), the verified navigation map, focus order, responsive behavior, motion,
copy tone, accessibility decisions, the fonts and icon library to load, the
**open findings** carried over from the audit, and the **run summary** from
`design/run.md`.

## Changes during the run

Any agent can raise a change; only the skill decides. Three kinds — **add** a
missing definition, **amend** a direction decision, **extend** the scope — each
with an owning artifact, a propagation order (spec → direction → variables →
system region → screens → re-review), a commit, and an entry in
`design/changes.md`. Amendments are dated entries at the end of the direction
file, never edits to the original; a second amendment to the same area in one
round means the phase-4 decision was wrong and the answer is `git reset` to
that phase, not a third patch. Full procedure in
`skills/prototype/references/change-protocol.md`.

## Commit points

`.pen` files are JSON, so they diff in git. **Commit at the end of every phase**,
canvas and documents together — `git add design/`, never `-A` — with the phase
in the message, on a `design/<date>` branch when the run started on the
default branch, and with `design/run.md` updated in the same commit:

```
design: phase 6 — system tokens and base components
```

Full procedure, including resume and rollback, in
`skills/prototype/references/run-protocol.md`.

This is what makes the recovery rule possible. **When the audit condemns a
phase, go back to that phase's commit and redo it** — do not patch on top. A
patched direction or a patched token set leaks into every screen built
afterward, and the cost of unwinding it grows with each subsequent phase.

## Flow

```
     /prototypen:discover  (optional, interactive)
                       │
                       ▼
             design/product-spec.md
                       │
          /prototypen:brand  (optional, interactive; when the spec says "to be explored")
                       │
                       │
          0  canvas check ── design/prototype.pen open?
                       │      (asks once if not; the only stop)
                 mode detection
                       │
        ┌──────────────┴──────────────┐
   bootstrap                    incremental
        │                             │
   1 Intake  (skipped if              │
      the spec exists)         load brand + direction
        │                       + spec + tokens
   2 Research                          │
        │                              │
   3 Brand ◄── conditional: no brand ──┤
        │                              │
   4 Direction                         │
        │                              │
   5–6 Structure, then system          │
        └──────────────┬───────────────┘
                       │
                  7 Screens  (parallel, one per flow; self-review per screen)
                       │
                 7b Layout review  (per flow, fresh context, geometry first)
                       │
                  8 Audit ──► [execution] ──► fix ──┐ max 3 cycles per screen
                       │◄───────────────────────────┘
                       ├──► [direction] / [spec] ──► change request ──► amend, propagate, log, commit
                  9 Organization sweep  (the audit's last pass, always)
                       │
                 10 Handoff  (exports unversioned; design-spec.md)
                       │
          /prototypen:finalize  →  /prototypen:roadmap   (after the last round)
```
