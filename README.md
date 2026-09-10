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

## Loading it during development

```bash
claude --plugin-dir /home/leandro/projects/personal/prototypen-plugin
```

Then just describe what you want built — you do not need to say "prototype":

> Design an app for a small logistics company to track shipments: a list of
> active shipments with status, carrier, cost and ETA, a detail view per
> shipment, and a weekly cost report.

Write in whatever language you want to work in. The plugin's own files are
English; everything it *produces* — documents, audit reports, and the copy
inside the prototype — follows your language. Filenames and canvas layer names
stay English so they are stable between rounds.

## Reloading after edits

`skills/prototype/SKILL.md` and everything under `references/` is read fresh on
each use — **edits apply immediately**.

Changes to `agents/*.md`, `.claude-plugin/plugin.json`, or `.mcp.json` are
cached. Run **`/reload-plugins`** after touching those.

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
