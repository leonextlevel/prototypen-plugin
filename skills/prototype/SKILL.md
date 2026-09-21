---
name: prototype
description: Autonomous product prototyping on the Pencil (pen.dev) canvas. Use this skill whenever the user wants to turn an idea, a feature request, or a set of requirements into screens, a navigable prototype, a design system, a brand, or design documentation — including when they never say the word "prototype". Trigger it for "design an app for X", "mock up this screen", "create a design system", "build the UI for this idea", "make a landing page", "draw this in Pencil", "set up tokens and components", "name and brand this product", "design the onboarding flow", "add a screen to the existing design", or any request that would otherwise be answered by inventing UI on the fly. It is the default path for visual product work, not a specialist tool held in reserve.
---

# Prototype

Turn an idea plus requirements into a navigable prototype and a complete design
system on the Pencil canvas, plus the documents that hand off to
implementation.

AI-generated design has a recognizable generic face: Inter, blue `#3b82f6`,
the soft-shadowed white card, the centered hero, the purple gradient. Asking
for creativity does not fix it. Declaring constraint before generation and
auditing against that declaration afterward does. Every phase below either
produces a constraint or is judged against one.

## Two rules that apply everywhere

**Language.** Detect the user's language from their messages and work in it:
conversation, every document in `design/`, and every piece of text on the
canvas. File names, canvas node names, variable names and component names
stay English so they are stable across rounds. Templates in `templates/` are
English; translate their headings when you instantiate one. Every subagent
runs isolated and cannot see the user's message, so **state the language in
every subagent prompt**.

**Voice.** Read `references/writing.md` before writing any document or
prompting any agent that writes one, and pass the pointer along in the
prompt. The output should read as if a person on the team wrote it. Before
every commit that includes a document, run `scripts/prose-check.py
design/*.md` (and the files under `design/audits/`) and fix what it flags;
commit when it exits 0. The auditor runs the same check on the canvas copy
(criterion 3.9).

## Step 0 — The access mode, the canvas, the brand, the branch

The canvas is always `design/prototype.pen`. Read `references/canvas-access.md`
and `references/run-protocol.md`, then, before anything else:

1. If the file does not exist, create it (the four-line empty document in
   `references/pencil-mcp.md`, fresh UUID `fileToken`).
2. Read `design/product-spec.md` if it exists. If its Targets table says the
   brand is **to be explored** and there is no `design/brand.md`, the user
   asked for `/prototypen:brand` before this run.
3. Check `pen status` (the pen.dev CLI). Without it there is no saving in
   either mode; say so with the two commands and stop.
4. **Ask once**, in one `AskUserQuestion`, in the user's language:
   - **the access mode** (`canvas-access.md`): for a bootstrap run suggest
     **headless** first ("close the file in Pencil; reopen it when I say the
     run is done"); for an incremental round suggest **app mode** first
     ("keep `design/prototype.pen` as the active editor; I save before every
     commit");
   - that the brand exploration has not happened, when that is the case, and
     that they can run `/prototypen:brand` first or let this run decide;
   - which branch will receive the commits (`run-protocol.md`) and that only
     `design/` is committed;
   - that once they answer, the run goes to handoff without further questions.
5. On the answer, verify: app mode → `get_app_state` reports the file as the
   active editor (ask again if not; never open it yourself with `code`);
   headless → `scripts/pen-run.sh` will refuse while the file is the active
   editor, so relay its message if it does.
6. Create the branch if the protocol calls for one, write `design/run.md`
   with the mode under `Access:`, and continue.

This is the only place a bootstrap run stops for input. An adjustment
after a finished run may stop again, once per conflict or ambiguity, from
the orchestrator or from the designer through it
(`references/adjustment-verification.md` §0a). **State the mode in every agent prompt**; agents cannot see this
conversation.

## Step 1 — Mode

**Bootstrap**: `design/design-direction.md` does not exist. Full pipeline.

**Incremental**: it exists. Skip Research and Direction. Before touching
anything, load `design/brand.md`, `design/design-direction.md`,
`design/design-spec.md`, `Print(GetVariables())` and a `Get` over the Design
System region, so you know what exists by name. Go to the phase the request
needs. The audit adds two hard failures: a hardcoded value where a variable
exists, and a new component that duplicates an existing one.

**Every change to an existing prototype follows
`references/adjustment-verification.md`**, whoever applies it: you first
check the request against the rules that exist (direction, brand, spec,
canvas structure, craft) and, **when it conflicts with one, the user is
asked** which they want: amend the rule and propagate, apply it as a named
exception on that screen, or keep the rule and reshape the request. In
**adjustment mode** (the previous run reached handoff) the question comes
from whoever found the conflict: you, before touching anything, or the
designer while working, in which case it ends its turn with a `QUESTION`
block that you relay **verbatim** with `AskUserQuestion` and answer back to
the **same** agent with `SendMessage`, so it continues with its context.
You do not summarize the question, you do not answer it yourself, and you
do not restart the agent. State `adjustment mode` in every prompt of such a
round; an agent that does not know the mode cannot know whether it may ask. Then the request
is turned into checks before the canvas is touched, the touched screens are
snapshotted before and after, the diff is read against the checks, the
mechanical pass and one screenshot follow, and the report has the fixed
shape with a PASS or FAIL per check. Put the pointer in every designer,
reviewer and auditor prompt of an incremental round and of every fix cycle,
and do not accept a report without the checks section; a "done" without
numbers goes back to the agent, not to the user.

**Brand** is a separate condition: phase 3 runs whenever there is no
`design/brand.md` and the user supplied no brand, in either mode.

## Pipeline

| # | Phase | Output | By |
|---|---|---|---|
| 1 | Intake | `design/product-spec.md` | this skill (skipped when discover ran) |
| 2 | Research | `design/research.md` | `prototypen:researcher` |
| 3 | Brand *(conditional)* | `design/brand.md`, `design/brand/logo/*.svg` | `prototypen:brand-designer` |
| 4 | Direction | `design/design-direction.md` | this skill |
| 5 | Component inventory | the component list in the direction | this skill |
| 5–6 | Structure and system | region grid, token variables, base components, state exemplars | `prototypen:designer`, one task |
| 7 | Screens | one designer per flow, in parallel | `prototypen:designer` |
| 7b | Layout review | geometry fixed per flow, base screens | `prototypen:layout-reviewer` |
| 8–9 | Audit, fix loop, organization sweep | `design/audits/<date>.md` | `prototypen:auditor`, structural pass on sonnet, visual pass on opus |
| 10 | Handoff | exports, `design/design-spec.md` | this skill |

No approval gates between phases. The audit is the quality control, not the
user's attention. Commit at the end of every phase (`references/run-protocol.md`).

### 1 — Intake

If `design/product-spec.md` exists, read it and go to phase 2; it holds
answers a person gave. Otherwise write it from
`templates/product-spec.template.md`: the **Targets** table (viewports,
themes, application type, brand status; decide them, never leave them
unstated), personas, jobs, core loop, the screen inventory per flow, the
**navigation map** (every screen and overlay: what opens it, every way out),
the secondary screens the application type requires (catalog in
`references/screen-craft.md` §5), and the two state tables: which **generic
states** (loading, error, empty, first use, long list, long text, permission
denied) each screen inherits from the system's exemplars, and the
**specific states** a screen needs of its own, each with its reason. Only
the second table produces screens; the first is checked against the
exemplars.

**Depth.** The Targets table declares it: **`core`** (the default) draws the
core loop end to end, the secondary screens the application type requires,
and every specific state; everything else the jobs imply is listed under
**Backlog** in the spec, not drawn. **`full`** draws the whole inventory.
Flows are organized by the user's job, not by area of the product, and a
round draws at most eight flows; the rest goes to the backlog with a note.

If the product is something people sign up for or buy, decide whether this
round includes a **landing page**. When it does, write the landing study from
`references/landing-page.md` into the spec and add `Flow — Landing Page` to
the inventory with its confirmation and error screens.

Ask nothing you can decide; record every guess under Assumptions. If the
request is so thin that assumptions would outnumber facts, say in one line
that `/prototypen:discover` would collect them, then proceed anyway.

### 2 — Research

Delegate to `prototypen:researcher`: competitors, domain conventions,
antipatterns, and the brand territory already occupied, with sources. When a
landing page is in scope, the prompt asks for the landing-page section too.
Research feeds brand; do not reorder.

### 3 — Brand (conditional)

Read `references/brand.md`. Delegate to `prototypen:brand-designer`. The brand
enters phase 4 as a constraint. If `/prototypen:brand` already ran, the file
exists and this phase is skipped like any supplied brand.

### 4 — Direction

Read `references/design-direction.md` and `references/anti-generic.md`. Pick
two divergence axes, produce three directions at genuinely different points,
each specified for every declared viewport and theme and declaring the twelve
items the reference lists. Choose one in writing against criteria tied to the
audience and the job, fill the **token inventory** (Step 3b of the reference,
every role by its fixed name, a value per theme), and write
`design/design-direction.md`. If none of the three can live with the brand,
regenerate the directions, never the brand. Everything on the ban list is
forbidden downstream unless this file justifies it by name.

### 5 — Component inventory

Read `references/component-catalog.md` and walk the screen inventory: for
each screen, which jobs it does and which component does each job, which
overlays it opens, which navigation the direction declared. Write the
resulting **component list** (name, job, variants, states, which screens use
it) as a section of `design/design-direction.md`. This is what the designer
builds from in phase 6, and what makes phase 7 discover components instead
of inventing them. It takes you ten minutes; done by the flow designers it
took the brasario run nine system rounds.

### 5–6 — Structure and system

Read `references/canvas-structure.md`. In app mode re-check `get_app_state`
(the user may have switched tabs during the document phases). Then one
`prototypen:designer` task, in this order:

1. The empty region grid: `Design System`, `Brand`, one `Flow — <Name>` per
   flow, placed with `FindEmptySpace`, nothing inside yet.
2. Tokens as `.pen` variables under exactly the inventory's names, every color
   with a value per declared theme.
3. The base components from the component list, with variants and
   interaction states.
4. The **state exemplars** in `Section / States`: one per archetype the
   inventory uses (list, object, form, dashboard) and per generic state, for
   the primary viewport and for any viewport where the state differs
   (`canvas-structure.md` §3b).

One commit when the task reports, covering both phases. The designer may not
invent a token. If it reports a gap, decide it under
"Changes during the run" and amend the direction.

### 7 — Screens

One `prototypen:designer` per flow, in parallel. Each prompt carries: the
access mode; the language and the `writing.md` pointer; the direction and
brand files; the existing token and component names and the state
exemplars; the flow's screens, specific states, overlays and navigation rows
from the spec; its region; the viewport to build and that viewport's density
and grid; and, for the landing flow, `references/landing-page.md`.

Build the **primary viewport for every flow first**, through the audit, then
derive the other viewports into the same rows. Every version of a screen sits
in its row, side by side, top-aligned, per `canvas-structure.md` §4. When a
second theme is declared, the theme copies (two or three representative
screens) are made after the audit passes.

The designer reads `references/designer-brief.md` and self-reviews every
screen and every flow before reporting. It **may add a component** the
screen needs and the system lacks, built from existing tokens, and reports
it; you ratify the additions once, in one entry, when the phase's designers
have all reported. Only a definition the direction lacks (a token, a
navigation system) or a conflict with the direction comes to you as a change
request. A **single propagation** of ratified components into other flows
happens after the last designer reports, in one batch, and only for
components that changed shape; a run has at most two system rounds after
phase 6.

### 7b — Layout review

After each flow's designer reports (and after any audit fix that touched
layout), delegate that flow to `prototypen:layout-reviewer` in a fresh
context, with the access mode. It reviews the **base screens and the
specific states** of the flow (the exemplars were reviewed once with the
system), checks composition intent, alignment, distribution and space with
`ctx.bounds` first, fixes mechanical geometry in place, and returns what it
could not fix as change requests.

### 8–9 — Audit, fixes, sweep

Read `references/audit-rubric.md`. The audit is two delegations to
`prototypen:auditor`, both in a fresh context, both carrying the access mode;
never let the agent that drew a screen judge it.

1. **The structural pass**, delegated with `model: sonnet`: levels 1, 2, 4
   and 5 over everything, no screenshots. They are mechanical and converge.
2. **The visual pass**, on the agent's own model (opus): level 3 over the
   **base screens, the specific states and the state exemplars**. The
   generic states of a screen are not screenshotted; they are the exemplar.

Each writes into `design/audits/<YYYY-MM-DD>.md` with a binary verdict per
criterion and every FAIL classified:

- `execution` goes back to a `prototypen:designer` as a fix under
  `references/adjustment-verification.md` (the finding is the request; its
  correct state is the check), then the layout reviewer if layout moved,
  then the auditor re-checks that screen. **At most two fix cycles per
  screen** at the visual level; past that the finding is recorded as open
  and the run moves on.
- `direction` and `spec` come to you as change requests (below). Handle them
  before sending anything back to a designer; they do not count against the
  screen.

When a second viewport is declared, phases 7, 7b and 8 run again for it once
the primary viewport passes, into the same rows. The theme copies come last:
a designer adds them, and the auditor checks them (3.11) in its final pass.

The **organization sweep** (the checklist at the end of `canvas-structure.md`)
is that final pass: the structural auditor runs it once more after the last
fix or the last theme copy lands; when neither happened, its first level-2
result stands. Nothing found there is filed for later; it is fixed before
handoff.

### 10 — Handoff

Read `references/handoff.md`. Export first (every screen version and variant
as PNG, each flow as HTML, the Design System and Brand regions, the variables
as `tokens.json` and `tokens.css`), skipping what is already exported from
an unchanged canvas; `design/screens/` is written with its own `.gitignore`
and is never committed. Then write `design/design-spec.md` from the
template: tokens, components, the **screen table generated from the canvas**
(the snippet in `handoff.md`, never typed by hand), the verified navigation
map, the rules the canvas cannot show, open findings, and the run summary.
Commit. End with the canvas notice from `canvas-access.md` (headless: close
and reopen the file; app mode: saved at `<sha>`), and say, in one line, that
`/prototypen:finalize` consolidates the folder when the design is done and
`/prototypen:roadmap` turns it into a business roadmap.

## Changes during the run

Read `references/change-protocol.md` the first time an agent raises something
it cannot do or the audit returns a `direction` or `spec` failure. Agents
raise; only you decide. Three kinds: **add** a missing definition (derive it
from what exists, put it in the owning artifact), **amend** a direction or
brand decision (the smallest change, in a dated `## Amendments` section, never
in place; twice on the same area in one round means the phase-4 decision was
wrong, so reset to that commit and redo it), **extend** the scope (if the
existing jobs imply it, add it to the spec and build it; if it needs a new
job, write it under Out of scope and stop). Every decision propagates in order
(spec → direction → variables → system → screens → re-review), commits, and
gets an entry in `design/changes.md` plus a line in `design/run.md`.

## Branch, commits, run state

`references/run-protocol.md`. On the default branch, work on
`design/<date>`; in app mode `scripts/pen-save.sh` before every commit;
`git add design/` (the path, never `-A`); one commit per phase and per change
decision; keep `design/run.md` current. When the audit
condemns a phase, reset to that phase's commit and redo it rather than
patching on top.

## References

| File | Read it when |
|---|---|
| `references/writing.md` | before the first document, and in every writing agent's prompt |
| `references/canvas-access.md` | Step 0, and in every agent prompt (the mode) |
| `references/pencil-mcp.md` | before the first Pencil call of the session |
| `references/run-protocol.md` | Step 0, every commit, any resume |
| `references/brand.md` | phase 3, or when the user brings a brand |
| `references/design-direction.md`, `references/anti-generic.md` | phase 4 |
| `references/canvas-structure.md` | phases 5–6, and the sweep |
| `references/component-catalog.md` | phase 5, the component inventory |
| `references/landing-page.md` | intake and phase 7 when a landing page is in scope |
| `references/change-protocol.md` | the first change request |
| `references/adjustment-verification.md` | every incremental round and every fix cycle, and in those prompts |
| `references/audit-rubric.md` | phase 8 |
| `references/handoff.md` | phase 10 |

`designer-brief.md` is the designer's; `layout.md` the reviewer's; the
long craft files are consulted by section. Point to them in prompts rather
than reading them here.

## Preconditions

The pen.dev CLI installed and logged in; in app mode, pen.dev running with
`design/prototype.pen` open (Step 0 asks once). Tool calls pre-approved for
an unattended run: `mcp__pencil__*`, `scripts/pen-*.sh`, `git` under
`design/`, writes to `design/`; the allowlist is in `docs/usage.md`. A
permission prompt mid-run is the environment, not a gate: note it in
`design/run.md` and continue when approved. If the canvas cannot be made
available at all, produce the documents in `design/` and say which half you
delivered.
