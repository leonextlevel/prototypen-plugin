# Change protocol

Read this whenever an agent reports something it could not do, whenever the
audit returns a failure it classifies as `direction` or `spec`, and whenever
you — the orchestrating skill — are about to edit a `design/` artifact after
phase 4.

The pipeline declares constraints up front and then executes within them. That
only works if the constraints can be **corrected when they turn out wrong**
without being **quietly eroded** every time they are inconvenient. This file is
the difference between the two: a change is a decision, made once, by the
orchestrator, written down, and propagated — never a fix applied in place by
whoever hit the problem.

## Who may raise, who decides

| Role | May raise | May decide |
|---|---|---|
| `designer` | a missing definition; something unbuildable as specified; a screen or state the spec did not list | nothing — it cannot write files, by design |
| `layout-reviewer` | an ambiguous composition intent; a fix that needs restructuring | nothing beyond mechanical geometry |
| `auditor` | any failure it classifies as `direction` or `spec` rather than `execution` | nothing — it never fixes |
| `brand-designer` | a brand constraint that no direction can satisfy | nothing after its phase |
| **the skill** | — | **everything** |

The orchestrator decides. Not the user — this is an unattended run and the
change log is how the user reviews the decisions afterward. Not the agent that
hit the problem — the agent with the problem is the one most motivated to solve
it the easy way.

## The three kinds of change

### 1. Missing definition — *add*

Something needed that the owning artifact does not define: a token (a state
color that was never specified), a component (a pattern with no precedent in
the system), a screen or state (discovered while building the flow), a
secondary screen the context turned out to need.

**Owner artifact:** tokens and components → `design/design-direction.md` (and
then the canvas variables and design-system region); screens and states →
`design/product-spec.md` (and then the canvas grid).

**Decide:** derive it from what exists. A missing state color comes from the
palette's concept and the semantic set, not from a picker. A missing component
comes from the catalog and the direction's edge treatment. A missing screen
gets its states inventoried like every other. If it cannot be derived — the
direction genuinely has no basis for it — that is a *correction*, below.

### 2. Direction correction — *amend*

A decision in `design-direction.md` or `design/brand.md` that does not survive
contact with the real content: the palette fails AA in dark; the declared
density cannot hold the primary view's actual data; the navigation pattern does
not fit the destination count that emerged; the type scale's step 3 is too
close to step 2 at the mobile viewport; the composition intent for an archetype
produces the partial-alignment failure on every screen of that kind.

The tell is the auditor's classification: a FAIL where the designer followed
the direction and the result is still wrong is a `direction` failure, not an
`execution` one, and sending it back to the designer produces three wasted fix
cycles.

**Decide:** amend the **smallest** thing that resolves it, in the direction
file's own terms — a dark-theme token value, a density number for one viewport,
one navigation pattern. Never re-open the three-directions choice for a single
finding.

**Never edit the original decision in place.** Add a dated entry to an
**`## Amendments`** section at the end of the direction (or brand) file: what
changed, from what to what, why, and which finding triggered it. The original
stays readable above it. A direction file whose history is visible can be
audited; one that has been silently rewritten cannot.

**The second-amendment rule.** If the same area of the direction — the palette,
the density, the navigation, the type scale — needs amending **twice in one
round**, stop amending. That is the signal that the phase-4 decision was wrong,
not the detail: go back to the phase-4 commit and redo the direction with what
is now known. Two patches on a bad foundation is how a direction file becomes a
list of exceptions.

### 3. Scope change — *extend*

The work reveals that the product needs something the spec did not ask for: a
flow that the jobs imply, a screen the user will obviously look for, a state
that the content makes unavoidable.

**Owner artifact:** `design/product-spec.md`.

**Decide:** if it follows from the jobs and personas already in the spec, add it
— to the spec, then to the canvas grid, then build it, then audit it. If it
would need a new job or persona, it is out of scope for this round: write it
into the spec's **Out of scope** section with a note that it was identified,
and stop there. The user decides on new jobs, not the pipeline.

## Propagation — every time

A change to an upstream artifact is not done until everything downstream of it
agrees. The order is fixed:

```
product-spec.md → design-direction.md → canvas variables → design-system region → screens → audit
```

- Amend a token → `SetVariables` on the canvas → every instance already
  references `$name`, so screens update; **re-audit the affected screens**
  (contrast in every declared theme if it was a color).
- Add a component → build it in the design-system region with its variants and
  states → instance it where the change request came from → self-review, layout
  review, audit for those screens.
- Add a screen or state → spec → grid box → build → the full review chain for
  it.
- Amend navigation, density or alignment posture → every screen of the affected
  viewport is re-reviewed by the layout reviewer, then re-audited.

Then **commit**, with the change in the message:

```
design: amend direction — dark surface token for AA on secondary text (audit 2026-09-11 §3.6)
```

## The change log

`design/changes.md`, in the user's language, one entry per decision, newest
last:

```
## 2026-09-11 — <one-line title>
- **Kind:** add | amend | extend
- **Raised by:** designer | layout-reviewer | auditor | brand-designer, with the finding or report reference
- **Problem:** what was observed, where (screen, node)
- **Decision:** what was changed, from what to what
- **Why:** the reasoning, in the direction's own terms
- **Propagated to:** the artifacts and screens updated
- **Commit:** <sha>
```

The log is the user's window into a run that did not stop to ask. Every entry
should let them disagree with a specific decision and know exactly what to
revert.

## What is not a change

- A designer that did not follow the direction → `execution` failure → fix the
  screen. No log entry.
- A layout deviation the reviewer can fix with geometry → fixed in place. No log
  entry.
- A token that exists under a different name → use it. No log entry, but a
  note in the audit if the name was hard to find.
- Taste. "I think the accent would look better warmer" is not a finding and not
  a change. The direction chose; the audit checks adherence; the user reads the
  result.
