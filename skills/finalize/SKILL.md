---
name: finalize
description: Consolidates a finished design into a standard, minimal design/ folder — removes exploration leftovers and stale files, folds amendments and rejected alternatives into the documents, refreshes the exports and the handoff spec against the final canvas, and writes design/README.md as the single entry point. Invoke it as /prototypen:finalize when the prototype is done (after one or more /prototypen:prototype rounds) and before /prototypen:roadmap or implementation. Also for "clean up the design folder", "consolidate the design docs", "standardize what the pipeline produced".
---

# Finalize

Turn the folder a run leaves behind into the folder a reader wants: one entry
point, every document current, nothing that only mattered while the run was
in progress.

A pipeline optimizes for recoverability while it runs: dated audits, a run
log, amendments appended instead of applied, three directions where one was
chosen. That is right during the run and wrong afterward, when an
implementer or a stakeholder opens `design/` and has to work out which of
four files is current. This skill makes that decision once and writes it
down.

## Preconditions

- `design/design-spec.md` exists (a run reached handoff). If not, say so and
  stop; there is nothing final to consolidate.
- `git status` is clean under `design/`. If it is not, a run was interrupted;
  point at `design/run.md` and stop.
- The access mode (`skills/prototype/references/canvas-access.md`): ask
  once, **app mode suggested first** when the user has the canvas open,
  headless otherwise. App mode: the canvas is the active editor
  (`get_app_state`) and `scripts/pen-save.sh` runs before the commit.
  Headless: the file is not open in an app; `scripts/pen-run.sh` saves.
- Read `skills/prototype/references/writing.md`; every document you touch
  ends up in that voice, in the user's language, and passes
  `scripts/prose-check.py` before the commit (run it over `design/*.md` and
  the kept audit; fix what it flags, including in text you did not write
  this time, since this is the last pass a reader gets).

Nothing here asks a second question. Everything deleted is in git history
and the commit message names it.

## What it does, in order

### 1. The canvas

Run the organization sweep from `skills/prototype/references/canvas-structure.md`
yourself (it is structural; no design judgment is involved) and fix what it
finds. Then remove what has no reader:

- `Brand Candidate *` or variation boxes left by an exploration;
- nodes with `placeholder: true` that hold nothing;
- reusable components in the Design System region with **no instance
  anywhere** on the canvas (a `Get` visitor collecting every `ref` target) and
  not in the direction's component set; report them rather than deleting if
  the direction names them, since a later round may need them;
- variables no node references and the inventory does not require (`Print(GetVariables())`
  against a `Get` over every `$` reference).

Never touch a screen's content. This is housekeeping, not design.

### 2. The documents

**`design/design-direction.md`.** Collapse it to the chosen direction: keep
the axes, the full spec of the chosen direction, the token inventory, the
selection criteria, the committed choice, the anti-generic justifications
and the brand compatibility. Replace the full specs of the two rejected
directions with the existing "why rejected" paragraphs (one each). Apply
every entry in `## Amendments` to the text it amends and replace the section
with a short `## History` list: date, what changed, why, in one line each.
The original values live in git.

**`design/brand.md`.** Same treatment for amendments. Keep the Exploration
section if `/prototypen:brand` wrote one.

**`design/product-spec.md`.** Reconcile with what was built: every `extend`
decision in `design/changes.md` is now in the inventory, the navigation map
matches the one verified in `design-spec.md`, and assumptions that a change
decision confirmed or reversed say so. The spec should describe the delivered
prototype, not the plan.

**`design/audits/`.** Keep the latest report; delete the earlier ones. The
open findings are already in `design-spec.md`.

**`design/run.md`, `design/changes.md`.** The run summary and the change
titles are already in `design-spec.md`. Delete `run.md`; keep `changes.md`,
since it holds the reasoning behind each decision and is the file a reader
opens when they disagree with one.

**`design/research.md`.** Unchanged.

### 3. The exports and the handoff

Re-run the export procedure in `skills/prototype/references/handoff.md`
against the final canvas so `design/screens/`, `design/tokens.json` and
`design/tokens.css` reflect it (screens stay unversioned; the `.gitignore`
inside the folder is kept), **skipping the exports when
`design/screens/.exported` already names the current canvas commit**. Then
refresh `design/design-spec.md`: the token tables, the component list and
the screen table are regenerated from the canvas (the screen table with the
snippet in `handoff.md`, never by hand), the run summary section is replaced
by a `## History` that lists the rounds (from `git log --oneline --
design/`) in one line each, and the open findings are carried from the
latest audit.

### 4. The entry point

Write `design/README.md` from `templates/design-readme.template.md`, in the
user's language. It is the one file a newcomer reads: what the product is and
for whom (from the spec), the brand in three lines, the direction's
personality sentence and committed choice, how the canvas is organized and
how to open it, what each file in the folder is for and in which order to
read them, the status (open findings, what is out of scope), and how to
continue (an incremental `/prototypen:prototype` request, `/prototypen:roadmap`).

## The finalized folder

```
design/
├── README.md              the entry point
├── product-spec.md        the product as delivered
├── research.md
├── brand.md
├── brand/logo/*.svg
├── design-direction.md    the chosen direction, history folded in
├── design-spec.md         the handoff
├── changes.md             the reasoning behind each decision made during the runs
├── audits/<latest>.md
├── tokens.json
├── tokens.css
├── prototype.pen
└── screens/               unversioned; regenerate with /prototypen:finalize or a handoff
```

`/prototypen:roadmap` reads this shape and nothing else, so a folder that
has not been finalized is finalized first.

## Commit

Save in app mode (`scripts/pen-save.sh`), then one commit, `design: finalize
— <what was removed, in a few words>`, on the current branch (the run
protocol's branch rule applies if you are on the default branch). Then say
what was deleted, what was folded, where the entry point is, and the canvas
notice from `canvas-access.md`.
