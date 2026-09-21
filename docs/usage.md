# Usage

## Prerequisites

- **The pen.dev CLI**, installed and logged in: `npm install -g @pen.dev/cli`,
  then `pen login` (`pen status` should print your account). Every skill
  needs it: it is how the plugin saves the canvas in app mode and how it
  runs at all in headless mode. Note that a `pencil` command in your PATH may
  be the desktop AppImage, not the CLI; the CLI is `pen`.
- A git repository in the project you are designing for.
- For **app mode** only: pen.dev (desktop, or the VS Code extension) running
  with **`design/prototype.pen` open** as the active editor, and the `pencil`
  MCP server connected. Headless mode needs neither.

Full detail, including why no `.mcp.json` is shipped, in
[development.md](development.md).

### Two ways to reach the canvas

Every skill that draws asks you this first, once, and suggests a default:

| | App mode | Headless |
|---|---|---|
| What runs | pen.dev with the file open; edits go through the MCP | the CLI's headless editor; no app needed |
| You see | the canvas changing live | nothing until the run ends; then close and reopen the file |
| Saving | the plugin saves before every commit (`scripts/pen-save.sh`) | automatic |
| Rule | keep `design/prototype.pen` as the active editor | keep the file **closed** in Pencil while the run writes |
| Suggested for | incremental rounds, `/prototypen:brand`, `/prototypen:finalize` | a full `/prototypen:prototype` run |

The result is identical; same engine, same renderer, same fonts. The
difference is who saves and whether you can watch. Two facts drive the
rule: the desktop app does not autosave an existing `.pen` and does not
reload one that changed on disk, so headless writes only show after you
close and reopen the tab, and a Ctrl+S in the meantime would overwrite
them. The headless runner refuses to write while the file is the active
editor of a running app, and tells you to close it.

### Permissions for an unattended run

The pipeline makes hundreds of tool calls without stopping. If each one needs
approval, it is not unattended. Before the first run, either start Claude Code
in a mode that auto-approves (`--permission-mode auto`, or `/permissions` →
auto for the session), or add this allowlist to the project's
`.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "mcp__pencil__execute",
      "mcp__pencil__get_app_state",
      "mcp__pencil__read_skill",
      "Bash(*/scripts/pen-run.sh *)", "Bash(*/scripts/pen-save.sh *)", "Bash(pen status)",
      "Bash(*/scripts/prose-check.py *)",
      "Read", "Glob", "Grep",
      "Write(design/**)", "Edit(design/**)",
      "Write(docs/**)", "Edit(docs/**)",
      "Bash(git add design/*)", "Bash(git add design/)", "Bash(git add docs/)",
      "Bash(git commit *)", "Bash(git checkout -b design/*)",
      "Bash(git branch *)", "Bash(git log *)", "Bash(git status *)",
      "Bash(mkdir -p design/*)", "Bash(mkdir -p docs/*)", "Bash(mv design/*)",
      "Bash(rm design/*)", "Bash(rm -r design/brand/exploration*)", "Bash(rm -r design/screens*)",
      "Bash(uuidgen)", "Bash(python3 -c *)",
      "WebSearch", "WebFetch"
    ]
  }
}
```

The plugin's own hooks (`hooks/`) still apply on top of this: a Pencil write
to any file other than `design/prototype.pen` is denied, and so is reading a
`.pen` file with anything but the MCP. Those two are the rules that matter
most, and they no longer depend on the model remembering them.

## Running it

Load the plugin ([development.md](development.md)). Five skills become
available, in the order you would use them:

| | |
|---|---|
| `/prototypen:discover` | interactive, asks questions, writes `design/product-spec.md`, stops |
| `/prototypen:brand` | interactive, optional: candidates side by side on the canvas, you choose, writes `design/brand.md` |
| `/prototypen:prototype` | the unattended pipeline, phases 1–10 |
| `/prototypen:finalize` | after the last round: consolidates `design/`, deletes what only mattered during the run, writes `design/README.md` |
| `/prototypen:roadmap` | from a finalized design: a business roadmap under `docs/`, every screen placed in a milestone |

```
discover  →  [brand]  →  prototype  (→ prototype again, incremental)  →  finalize  →  roadmap
```

### If the idea is still loose

```
/prototypen:discover
```

It asks in at most three rounds: the job and what it replaces today, who uses
it and how often, viewports and themes, the kind of application, the brand,
whether a landing page is part of this round, scale and content realities,
hard constraints, and what is out of scope. Then it writes
`design/product-spec.md` and stops. Run `/prototypen:prototype` afterward; it
picks the file up and skips its own intake.

Two of those questions open doors:

- **The brand.** If nothing is decided and you would rather see options than
  receive one, say so: the spec records the brand as "to be explored" and
  `/prototypen:brand` is the next step. It puts three candidates (name, mark,
  base palette, a small specimen) side by side in the canvas's Brand region,
  asks which, refines one axis at a time, and writes `design/brand.md` in at
  most three rounds. The pipeline then skips its own brand phase. If you
  start the pipeline with the exploration still pending, its one upfront
  question mentions it and lets you choose.
- **The landing page.** For anything people sign up for, buy or download,
  discovery asks whether this round includes the landing page. If yes, it
  collects the inputs for a structured study (who lands there and from
  where, the one action, the objections, the proof you have) and the
  pipeline builds the page as its own flow, with the confirmation and error
  screens.

Discovery deliberately never asks what you want it to look like. Asked directly,
that question returns "clean, modern, professional" from almost everyone — the
generic default the plugin exists to escape. Visual decisions are made later,
against research and a written direction.

It is optional. Skipping it is not a degraded path — the pipeline writes the spec
itself and records every guess under Assumptions, which you can read afterward.
Use discovery when you would rather answer six questions than audit six
assumptions.

### If you can state it in a paragraph

Just describe what you want built:

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
├── run.md                   what ran, what was skipped, which commit is which
├── product-spec.md          personas, jobs, targets, screen inventory, generic and specific states, navigation map, backlog
├── research.md              competitors, conventions, antipatterns, sources
├── brand.md                 name, positioning, tone, palette, logo rules
├── brand/logo/*.svg         five logo variants (+ preview/*.png)
├── design-direction.md      three directions, the choice, why, and the token inventory
├── changes.md               every decision the run made instead of asking
├── audits/<date>.md         every criterion, PASS or FAIL
├── design-spec.md           the handoff: tokens → code, components, rules, routing
├── tokens.json              every variable, W3C Design Tokens format, all themes
├── tokens.css               the same as CSS custom properties per theme
└── screens/                 NOT versioned (its own .gitignore); regenerated on every handoff
    ├── <flow>/*.png         one image per screen version and per state
    ├── <flow>/index.html    the flow as HTML
    └── design-system/       the components region
```

Plus the `.pen` file: a `Design System` region with tokens and components, a
`Brand` region, and one region per flow. Inside a flow, one column group per
screen in navigation order; the group's first row holds the screen's versions
side by side (desktop, mobile, the dark copy), top-aligned whichever is
taller, and each state and overlay gets its own row below, again with every
version side by side.

The screen exports are for looking at the prototype without pen.dev, and
they are the only part of `design/` that is not committed: they are binary,
they change on every handoff, and the canvas is the source. Run a handoff or
`/prototypen:finalize` to regenerate them.

A run commits after every phase, on a `design/<date>` branch when you were on
`main` (merge it or discard it; your branch is untouched), and only ever
`design/`. `git log -- design/` is a readable record of what happened when;
`design/run.md` is the same record as a table.

## The one time it stops

Before anything else, the pipeline asks one question: which access mode
(headless suggested for a full run, app mode for an incremental one), which
branch gets the commits, and, when it applies, whether to run
`/prototypen:brand` first. It explains why it is asking *now*: the run is
autonomous from that point to handoff and will not stop for input again.

In app mode it then checks which canvas is open. If it is not
`design/prototype.pen` in this project, it asks you to open the file it
created, and re-checks; it will not take your word for it, because the
Pencil `execute` tool does not fail on a path that does not exist, it
silently writes into whatever canvas is active. In headless mode it checks
the opposite: that the file is **not** open in a running app.

### Depth: core or full

The spec's Targets table now carries a **Depth**. `core`, the default, draws
the core loop end to end, the secondary screens the application type needs
(404, session expired, permissions, and so on), and the states only those
screens have; everything else the jobs imply is listed under **Backlog** in
the spec for a later round. `full` draws the whole inventory. Discovery
asks which; the pipeline's own intake picks `core` and says so. A round
draws at most eight flows either way, and flows are organized by what the
user came to do, not by area of the product.

### States are patterns, not screens

The states every screen shares (loading, error, empty, first use, long list,
long text, permission denied) are drawn **once per screen archetype** (list,
object, form, dashboard) as exemplars in the Design System's `Section /
States`, and every screen of that archetype inherits them. A screen gets a
state of its own only when the spec lists a **specific state** with a reason
(a selection mode, a live banner, a locked object). In the first project this
plugin ran on, 265 of 521 screens were the five generic states repeated per
screen; that is what this replaces.

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
  is $color-text-tertiary #8A8A8A on $color-surface #F2F0EA, 2.8:1 at 14px. Needs 4.5:1.
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

**Level 3 — visual — stops after 2 fix cycles per screen.** Screenshot critique
is good at hierarchy and gross error and weak at refinement; past two passes
it stops converging and starts finding a different subjective complaint each
time while the screen changes without improving. On the second failure the
finding is written down as unresolved, carried into `design-spec.md` under Open
findings, and the run continues.

So when you read the report:

| Finding | What to do |
|---|---|
| A resolved FAIL | Nothing — it was fixed. |
| An unresolved level-3 FAIL | Look at it yourself. Ten seconds of human judgment beats a third pass. |
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

`design/run.md` and the per-phase commits make this straightforward.

1. Open `design/run.md` — the first phase not marked done or skipped is where
   it stopped. (`git log --oneline -- design/` says the same thing.)
2. `git status` — if `design/` is dirty, that phase was interrupted mid-way.
   `git checkout -- design/` to drop the partial work; the phase is redone from
   its start.
3. Put the canvas back in the mode `run.md` names: open in pen.dev for app
   mode, closed for headless; on the branch `run.md` names.
4. Say: *"continue"*. The skill reads `run.md` and picks up from that phase.

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

Every change to an existing prototype, whether you asked for it or the
audit did, runs under a verification protocol
(`skills/prototype/references/adjustment-verification.md`): the request is
turned into checks with numbers before anything is touched, the screen is
snapshotted before and after so the diff shows what moved, the mechanical
pass and one screenshot follow, and the report you get back lists each
check as PASS or FAIL. It is written so a mid-tier model can follow it
without judgment; if a report comes back as "done" with no checks, the
skill is supposed to send it back, not to you.

Before any of that, the request is checked against the rules the project
already has: the direction's committed choice and tokens, the brand's
palette and tone, the spec's targets and navigation map, the canvas
structure, the craft rules. If it conflicts with one ("make that button
blue" when the palette has no blue; "remove the confirmation" on a delete;
"drop the tab bar on this screen" when the navigation system says every
screen has it), the round stops and asks you what you want: amend the
rule and apply it everywhere, apply it as a named exception on that
screen, or keep the rule and do the nearest thing inside it. The question
comes from whoever hit the conflict, the skill before touching anything or
the designer while working (relayed word for word, with its
recommendation), and the same agent continues with your answer. It never
picks one for you, and it never applies the change first and asks later.
This only happens after a run has finished; inside the autonomous run
nobody asks, by design.

### Text that reads as written by a person

Every document the plugin writes, and every piece of canvas copy longer
than a label, goes through `scripts/prose-check.py` before it is committed
or reported. It flags the mechanical tells: three short sentences in a row
(ideas separated by periods that belong in one sentence or in a list), em
dashes as connectors, emphasis fragments, "not X, it is Y", bolded-bullet
triads, inflated words. You can run it yourself on anything:
`scripts/prose-check.py design/brand.md`, or `--text "..."` for a string.

### Alignment on both axes

The layout reviewer and the audit (criterion 3.26) check that alignment
was decided on both axes for every container, because generated screens
default to everything ranged left and top: an icon beside a line of text
sits on its center, an empty state is centered in a region with a height,
amounts share a right edge, a title's actions sit on its line. A screen
where every frame carries the default alignment fails unless it is a plain
list or form.

## When the design is done

`/prototypen:finalize` turns the folder a run leaves behind into the folder
a reader wants: it sweeps the canvas (exploration leftovers, unused
components and variables), folds the amendments into the direction and the
brand, drops the two rejected directions to their one-paragraph rationale,
reconciles the spec with what was actually built, keeps only the latest
audit, deletes `run.md`, refreshes the exports and `design-spec.md`, and
writes `design/README.md` as the entry point. Everything deleted is in git
history and the commit names it. Run it again after any later round.

`/prototypen:roadmap` reads a finalized folder and writes `docs/roadmap.md`
plus one file per milestone under `docs/roadmap/`: which flows and screens
land in which milestone, in what order and why, with every state as an
acceptance criterion and every screen placed exactly once. It is written for
whoever decides what gets built, and it asks a question only when the spec
does not settle the cut.

## Which model does what

The expensive model is spent where judgment decides the outcome; execution
runs on the cheaper one. Each agent's model is one line in its file under
`agents/`, and the two orchestrator-side choices are in the prototype skill.

| Work | Model | Where it is set |
|---|---|---|
| Orchestration: intake, direction, component inventory, change decisions | the session's model (opus recommended) | you, when you start Claude Code |
| `researcher` | sonnet | `agents/researcher.md` |
| `brand-designer` | opus, high effort | `agents/brand-designer.md` |
| `designer` (system, screens, fixes) | sonnet, medium effort | `agents/designer.md` |
| `layout-reviewer` | sonnet | `agents/layout-reviewer.md` |
| `auditor`, structural pass (levels 1, 2, 4, 5) | sonnet, via `model` override in the delegation | `skills/prototype/SKILL.md`, phase 8 |
| `auditor`, visual pass (level 3) | opus, high effort | `agents/auditor.md` |

The designer ran on opus until 2026-09-20; the first real project showed the
cost (it is the agent with the most tool calls, run once per flow in
parallel and again on every fix) and no evidence the visual pass needed it.
If a project's exported screens look worse after the change, the line to
revert is `model:` in `agents/designer.md`.

## Troubleshooting

| Symptom | Cause |
|---|---|
| `Failed to access file ""` | App mode with no `.pen` file open in pen.dev. Open `design/prototype.pen`, or answer headless. |
| `prototypen: the pen.dev CLI is not installed` | `npm install -g @pen.dev/cli`, then `pen login`. `pencil` in your PATH may be the desktop app; the CLI is `pen`. |
| `is open as the active editor in the pen.dev desktop app` (exit 75) | Headless refused to write while the file is open in the app. Close that tab and answer "continue"; or restart in app mode. |
| The canvas looks unchanged after a headless run | The desktop app does not reload a file changed on disk. Close the tab and reopen `design/prototype.pen`. |
| `Could not connect to pen.dev desktop app` although it is running | The app's socket file was deleted (running the AppImage a second time does that). Quit the app completely and open it again. |
| `save through the desktop app failed` | The app is not running, or has a different file active. Open `design/prototype.pen` there and rerun; the commit waits for the save. |
| The logo is a plain geometric mark and `brand.md` says it was "built manually" | pen.dev's `Generate` (SVG, AI and stock images) runs on your pen.dev account's credits and returned empty or an error. The run switched to primitives instead of stopping. Top up or wait, then ask for an incremental round that regenerates the mark; the placeholders for photography are listed under open findings. |
| The run stops immediately with a question about access mode and branch | Working as intended; it is the single upfront question. Answer it and the run goes to handoff without stopping again. |
| Elements appeared in a different `.pen` file | The wrong canvas was *active* during a write. The path hook blocks the wrong path, but cannot see which file the editor has in front; the `get_app_state` check was skipped. `git checkout` that file if it is versioned; re-run with `design/prototype.pen` open. |
| `prototypen: execute filePath is …` in the transcript | The hook did its job: a write was aimed at a canvas other than `design/prototype.pen`, or at a file that does not exist. Nothing was written. |
| The run stops at a permission prompt | The environment, not the pipeline. Add the allowlist above, or run in auto mode. |
| The type looks like a default sans | The direction named a family that is not on Google Fonts, or a weight it does not ship, and pen.dev fell back silently. Criterion 3.24 should have caught it; fix `font-*` in the direction and re-run phase 6 onward. |
| Pencil tools missing entirely | The `pencil` MCP server is not configured or not approved. Check `/mcp`. |
| The skill does not trigger | Say what you want built more directly, or invoke it by name: `/prototypen:prototype`. |
| Discovery keeps asking questions | It caps at three rounds. Answer "decide you" to anything you do not care about — it will record it as an assumption. |
| `/prototypen:prototype` re-did the intake | `design/product-spec.md` was missing or in another directory. It skips phase 1 only when that exact path exists. |
| The upfront question mentions a pending brand exploration | The spec says the brand is "to be explored" and `design/brand.md` does not exist. Run `/prototypen:brand` first, or answer that the pipeline may decide the brand itself. |
| `design/screens/` shows as untracked or is missing after a checkout | Working as intended: the exports are not versioned. Run a handoff or `/prototypen:finalize` to regenerate them from the canvas. |
| `/prototypen:roadmap` refuses to start | The folder was not finalized (`design/README.md` missing). Run `/prototypen:finalize` first. |
| Documents read like they were generated | Check that the agent prompts carried the `writing.md` pointer; the skill passes it in every prompt. If a specific file is off, rewrite it with the reference open. |
| Changes to an agent file do nothing | Run `/reload-plugins`. Agents and `.mcp.json` are cached; `SKILL.md` is not. |
| The designer stopped and reported a missing token | Working as intended. Amend `design/design-direction.md` with the missing definition and continue. |
| Everything came out looking generic anyway | Read `design/design-direction.md`. If it does not name a committed choice, the constraint was never declared and the audit had nothing to check against. |
