# Usage

## Prerequisites

1. **pen.dev running, with a `.pen` file open in the editor.** Every Pencil MCP
   tool — including the ones that just read state — fails with
   `Failed to access file ""` when nothing is open. This is the most common
   cause of a run that dies at phase 5.
2. **The `pencil` MCP server configured and connected.** This plugin does not
   ship an `.mcp.json`; see the README for why. Check with `/mcp`.
3. **A git repository** in the project you are designing for. The pipeline
   commits after every phase.

## Running it

Load the plugin (see the README), then just describe what you want built:

> Design an app for a small logistics company to track shipments — a list of
> active shipments with status, carrier, cost and ETA, a detail view per
> shipment, and a weekly cost report. Three dispatchers use it all day on
> desktop.

You do not need to say "prototype", or name the skill. It triggers on requests
to design, mock up, build a UI for, create a design system for, brand, or draw
in Pencil.

**Answer in whatever language you want to work in.** The plugin's own files are
English; everything it produces — documents, audit reports, and the copy inside
the prototype — follows you. Filenames and canvas layer names stay English so
they are stable between rounds.

## What you get

After a full bootstrap run:

```
design/
├── product-spec.md          personas, jobs, screen and state inventory
├── research.md              competitors, conventions, antipatterns, sources
├── brand.md                 name, positioning, tone, palette, logo rules
├── brand/logo/*.svg         five logo variants
├── design-direction.md      three directions, the choice, and why
├── design-spec.md           the handoff: tokens → code, components, rules
└── audits/<date>.md         every criterion, PASS or FAIL
```

Plus the `.pen` file: a `Design System` region with tokens and components, a
`Brand` region, and one region per flow with its screens in navigation order.

A run commits after every phase, so `git log` is a readable record of what
happened when.

## How long it takes

A bootstrap run is long — research, brand, three design directions, a full
system, every screen with its states, and an audit loop. It is built to run
unattended; there are no approval gates by design. Start it and come back.

An incremental run ("add a settings screen") is much shorter: it skips research,
brand, and direction entirely.

## Reading an audit report

`design/audits/<date>.md` is grouped by screen, one line per criterion:

```
## 03 Payment Method
- [PASS] 1.1 No overflow or clipping
- [FAIL] 3.6 Contrast AA — the secondary label (`03 Payment — Helper`, id Xk9f2)
  is $text-tertiary #8A8A8A on $surface #F2F0EA, 2.8:1 at 14px. Needs 4.5:1.
  Fix the token, not the instance.
```

Verdicts are binary on purpose. There is no "mostly" — a rubric that admits
degrees grades everything B+ and nothing gets fixed.

## When the audit fails

**It is supposed to.** An audit report with no FAILs on a first run means the
rubric is not biting, not that the work was perfect.

The pipeline handles most failures itself: findings go back to a designer, get
fixed, and get re-checked. Levels 1, 2 and 4 (structural, organization,
completeness) are objective and get fixed until they pass.

**Level 3 — visual — stops after 3 fix cycles per screen.** Screenshot critique
is good at hierarchy and gross error and weak at refinement; past three passes
it stops converging and starts finding a different subjective complaint each
time while the screen changes without improving. On the third failure the
finding is written down as unresolved, carried into `design-spec.md` under Open
findings, and the run continues.

So when you read the report:

| Finding | What to do |
|---|---|
| A resolved FAIL | Nothing — it was fixed. |
| An unresolved level-3 FAIL | Look at it yourself. Ten seconds of human judgment beats a fourth pass. |
| Many FAILs against the direction | The direction file is probably vague. Vague constraints cannot be audited. Sharpen it and rerun phase 4 onward. |
| A FAIL you disagree with | Check the direction file. If it justifies the choice, the auditor was wrong to flag it — the fix goes in the rubric, not the design. See `contributing.md`. |

### When a whole phase is wrong

Do not patch it. **Go back to that phase's commit and redo it.**

```bash
git log --oneline          # find the phase commit
git reset --hard <sha>     # go back to it
```

A patched direction or a patched token set leaks into every screen built after
it, and the cost of unwinding grows with each phase that followed.

## Resuming an interrupted run

The per-phase commits make this straightforward.

1. `git log --oneline` — the last commit names the last completed phase.
2. `git status` — if the working tree is dirty, that phase was interrupted
   mid-way. `git reset --hard HEAD` to drop the partial work.
3. Make sure the `.pen` file is open in pen.dev again.
4. Say: *"continue from phase N"*, naming the phase after the last commit.

Mode detection handles the rest. If `design/design-direction.md` already exists,
the skill will not redo research or direction — it loads them and continues.

If the interruption left half-built frames on the canvas, they will carry
`placeholder: true`. Phase 9's organization sweep catches them; you can also
just ask for the organization review on its own.

## Working incrementally

Once a project has a `design-direction.md`, every later request runs in
incremental mode:

> Add bulk actions to the shipment list — select several shipments and change
> their status at once.

It loads the brand, direction, spec, existing tokens and existing components
first, then builds only what was asked. The audit adds two hard failures in this
mode: **a hardcoded value where a token already exists**, and **a new component
that duplicates an existing one**. Both are drift, not creative choices.

The organization review still runs, even for a one-screen change.

## Troubleshooting

| Symptom | Cause |
|---|---|
| `Failed to access file ""` | No `.pen` file open in pen.dev. Open one. |
| Pencil tools missing entirely | The `pencil` MCP server is not configured or not approved. Check `/mcp`. |
| The skill does not trigger | Say what you want built more directly, or invoke it by name. |
| Changes to an agent file do nothing | Run `/reload-plugins`. Agents and `.mcp.json` are cached; `SKILL.md` is not. |
| The designer stopped and reported a missing token | Working as intended. Amend `design/design-direction.md` with the missing definition and continue. |
| Everything came out looking generic anyway | Read `design/design-direction.md`. If it does not name a committed choice, the constraint was never declared and the audit had nothing to check against. |
