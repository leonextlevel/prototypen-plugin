# prototypen

Autonomous product prototyping on the [Pencil (pen.dev)](https://pen.dev)
canvas. Give it an idea and its requirements; it produces a navigable prototype,
a complete design system, and the design documents that hand off to
implementation.

## What it is for

AI-generated design has a recognizable face: Inter, blue `#3b82f6`, a white card
with a soft shadow, a centered hero with two CTAs, a purple gradient, an icon in
a pastel circle. Not because models are bad at design — because that is the
statistical center of everything they were trained on.

Asking for creativity does not move it. `prototypen` moves it by **declaring
constraint before generation** — research, then brand, then a design direction
chosen out of three genuine alternatives — and then **auditing the result in a
separate context** against that written constraint.

It runs unattended, end to end, and commits after every phase.

## Prerequisites

1. **pen.dev running, with a `.pen` file open in the editor.** Every Pencil MCP
   tool fails without one — this is the most common cause of a dead run.
2. **The `pencil` MCP server configured.** This plugin deliberately ships no
   `.mcp.json`: the server is registered by the pen.dev editor extension itself,
   its launch command is an absolute, platform- and version-pinned path, and
   duplicating it in project scope would only add an approval prompt. Check that
   it is connected with `/mcp`. See [docs/decisions.md](docs/decisions.md).
3. **A git repository** in the project you are designing for.

## Workflow

The working model is **one long first round, then short ones**. The first round
establishes the constraints — research, brand, direction, tokens — and everything
after it is executed within them.

### 1. Open the canvas and start the session

Open pen.dev with a `.pen` file, then from the project you are designing for:

```bash
cd ~/projects/my-product
claude --plugin-dir /home/leandro/projects/personal/prototypen-plugin
```

The project needs to be a git repository — the pipeline commits after each
phase, and that is what makes step 5 possible.

Two skills become available, both invocable by name or triggered from a plain
request: **`/prototypen:discover`** (interactive, collects requirements) and
**`/prototypen:prototype`** (the unattended pipeline).

### 2. Describe what you want built

Two entry points, depending on how settled the idea is.

**If you can state the product in a paragraph**, just say it — you do not need
to name the skill or say "prototype":

> Design an app for a small logistics company to track shipments: a list of
> active shipments with status, carrier, cost and ETA, a detail view per
> shipment, and a weekly cost report. Three dispatchers use it all day on
> desktop.

Include **who uses it, in what context, and how often**. The direction phase
chooses between dense and airy on exactly that, and without it the choice
defaults.

**If the idea is still loose** — the requirements are in your head rather than in
a paragraph — run discovery first:

```
/prototypen:discover
```

It asks the questions worth asking, in at most three rounds, and writes
`design/product-spec.md`. Then `/prototypen:prototype` picks that file up and
skips its own intake. This is the only interactive step in the plugin; it is
optional, and it is where a human's knowledge of the domain actually gets in.

One thing it deliberately never asks is what you want it to look like — asked
directly, that question produces "clean, modern, professional", which is the
generic default this plugin exists to escape. The visual decisions are made
later, against evidence.

Write in whatever language you want to work in. The plugin's own files are
English; everything it *produces* — documents, audit reports, and the copy inside
the prototype — follows your language. Filenames and canvas layer names stay
English so they are stable between rounds.

### 3. Let it run

**This first round is long and takes no input.** There are no approval gates by
design: research, brand, three design directions, the token system, every screen
with its states, then the audit loop. Start it and come back.

You can watch it happen — the canvas updates live, and `git log` fills in one
commit per phase.

### 4. Read two files, not everything

When it stops:

- **`design/design-direction.md`** — does the chosen direction commit to
  something? It names one non-neutral decision it made. If that section is vague,
  everything downstream had nothing to be held to, and that is the one problem
  worth fixing before anything else.
- **`design/audits/<date>.md`** — findings the loop resolved are already fixed.
  What needs you are the **unresolved** ones: the visual-level failures that hit
  the 3-cycle limit and were written down instead. Ten seconds of your judgment
  beats a fourth pass.

An audit with zero failures on a first run means the rubric is not biting — not
that the work was perfect.

### 5. Correct, then iterate

**A wrong detail** — say it back in plain language: *"the error states are too
loud, they compete with the primary action"*. It runs incrementally.

**A wrong phase** — do not patch on top. Go back to that phase's commit and redo
it, or a bad direction leaks into every screen built after it:

```bash
git log --oneline        # each commit names its phase
git reset --hard <sha>
```

**More product** — just ask. From here on every round is incremental: it skips
research, brand, and direction, loads the existing tokens and components first,
and builds only what you asked.

> Add bulk actions to the shipment list — select several shipments and change
> their status at once.

In this mode a hardcoded value where a token exists, or a new component
duplicating an existing one, is a hard audit failure rather than a choice. That
is what stops round eight from being a third design system.

### 6. Hand off to code

`design/design-spec.md` is the implementation contract: every token with its
canvas variable name and its intended code name, every component with variants,
states and props, and the rules a canvas cannot show — focus order, responsive
behavior, motion, copy tone. It closes with the open findings from the audit.

Point your implementation work at that file rather than at screenshots.

Full detail — reading an audit, resuming an interrupted round, troubleshooting —
in [docs/usage.md](docs/usage.md).

## What you get

```
design/
├── product-spec.md      personas, jobs, screen and state inventory
├── research.md          competitors, conventions, antipatterns, sources
├── brand.md             name, positioning, tone, palette, logo rules
├── brand/logo/*.svg     five logo variants
├── design-direction.md  three directions, the choice, and why
├── design-spec.md       the handoff: tokens → code, components, rules
└── audits/<date>.md     every criterion, PASS or FAIL
```

Plus the `.pen` file, organized into a `Design System` region, a `Brand` region,
and one region per flow with its screens in navigation order.

## Reloading after edits

`skills/prototype/SKILL.md` and everything under `references/` is read fresh on
each use — **edits apply immediately**.

Changes to `agents/*.md`, `.claude-plugin/plugin.json`, or `.mcp.json` are
cached. Run **`/reload-plugins`** after touching those.

## Documentation

| | |
|---|---|
| [docs/architecture.md](docs/architecture.md) | the pieces, what each decides, and why the audit is isolated |
| [docs/pipeline.md](docs/pipeline.md) | the ten phases, their artifacts, conditionals, and commit points |
| [docs/usage.md](docs/usage.md) | running it, reading an audit, resuming an interrupted round |
| [docs/contributing.md](docs/contributing.md) | how to evolve it without making it worse |
| [docs/decisions.md](docs/decisions.md) | decisions taken while building it, with reasons |
| [evals/README.md](evals/README.md) | the reference cases to run after any significant change |

## License

MIT
