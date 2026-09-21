# prototypen

A [Claude Code](https://claude.com/claude-code) plugin that turns an idea
with requirements into a navigable prototype on the
[Pencil (pen.dev)](https://pen.dev) canvas, with a design system, a brand
and the documents that hand off to implementation.

It exists because AI-generated design has a recognizable face (Inter, blue
`#3b82f6`, the soft-shadowed white card, the centered hero), and asking for
creativity does not change it. The plugin declares constraints before it
draws anything (research, brand, a written design direction chosen from
three) and audits the result against those constraints in a separate
context. The full reasoning is in [docs/architecture.md](docs/architecture.md).

## Requirements

- [Claude Code](https://claude.com/claude-code).
- The pen.dev CLI, installed and logged in:
  `npm install -g @pen.dev/cli`, then `pen login`. It is how the plugin
  saves the canvas, and how it runs when no editor is open. (`pencil` in
  your PATH may be the desktop app; the CLI is `pen`.)
- A git repository in the project you are designing for. The plugin commits
  after every phase, only under `design/`, on a `design/<date>` branch when
  you are on the default branch.
- For watching the canvas live: pen.dev desktop or the VS Code extension,
  with its `pencil` MCP server connected to Claude Code. Optional; see
  "App mode or headless" below.

## Install

```bash
claude plugin marketplace add leonextlevel/prototypen-plugin
claude plugin install prototypen@prototypen
```

Or from a local clone: `claude --plugin-dir /path/to/prototypen-plugin`.

The pipeline makes hundreds of tool calls without stopping, so pre-approve
them: run Claude Code in auto mode, or add the allowlist from
[docs/usage.md](docs/usage.md#permissions-for-an-unattended-run) to the
project's `.claude/settings.json`.

## Use

Describe what you want built, in whatever language you work in:

> Design an app for a small logistics company to track shipments: a list of
> active shipments with status, carrier, cost and ETA, a detail view per
> shipment, and a weekly cost report. Three dispatchers use it all day on
> desktop.

That triggers `/prototypen:prototype`. It asks one question up front (which
way to reach the canvas, which branch gets the commits, whether to explore
the brand first), then runs to handoff without stopping: intake, research,
brand, direction, design system, screens, layout review, audit with a fix
loop, exports and the handoff spec. Everything it produces follows your
language; file names and canvas layer names stay English.

The five skills, in the order you would use them:

| Skill | What it does |
|---|---|
| `/prototypen:discover` | Optional. Asks the questions worth asking, in at most three rounds, and writes `design/product-spec.md`. Skip it and the pipeline writes the spec itself, recording every guess under Assumptions. |
| `/prototypen:brand` | Optional. Puts three brand candidates side by side on the canvas (name, mark, palette, a specimen), refines the one you pick, writes `design/brand.md`. For when the identity matters and you want to see options. |
| `/prototypen:prototype` | The pipeline. Also the entry point for later rounds: "add bulk actions to the shipment list" runs incrementally on the existing design. |
| `/prototypen:finalize` | When the design is done: consolidates `design/` into a standard folder with a `README.md` entry point, folds amendments into the documents, refreshes the exports. |
| `/prototypen:roadmap` | From a finalized design: a business roadmap under `docs/`, every screen placed in exactly one milestone with its states as acceptance criteria. |

### App mode or headless

Every skill that draws asks this first, once, with a suggested default:

- **Headless** (suggested for a full run): the plugin drives pen.dev's
  engine through the CLI, with no editor open. It saves by itself and cannot
  write into the wrong file. Keep `design/prototype.pen` closed in Pencil
  while it runs; when it says the run is done, open the file.
- **App mode** (suggested for incremental rounds, `brand` and `finalize`):
  pen.dev is open with `design/prototype.pen` as the active editor and you
  watch the canvas change. The plugin saves before every commit; you never
  need Ctrl+S.

The result is the same either way. The desktop app does not autosave an
existing `.pen` and does not reload one changed on disk, which is why the
two modes are kept apart and the headless runner refuses to write while the
file is open in the app.

### How much it draws

By default a round draws the **core path**: the core loop end to end, the
secondary screens the application type requires (404, session expired,
permissions, and so on) and the states only those screens have. The states
every screen shares (loading, empty, error, long list, long text, first
use, permission denied) are built once per screen archetype as exemplars in
the design system, and every screen inherits them. What the jobs imply
beyond that is listed under Backlog in the spec for the next round. Ask for
`full` in discovery to draw the whole inventory at once.

### Adjusting an existing prototype

Any request after a finished run is applied under a verification protocol:
the request becomes checks with numbers before the canvas is touched, the
screen is snapshotted before and after so the diff shows what moved, and the
report lists each check as PASS or FAIL. If the request conflicts with a
rule the project already has (a color outside the palette, a delete without
confirmation, a screen without the navigation), you are asked what you want
before anything changes: amend the rule everywhere, make a named exception
on that screen, or keep the rule and do the nearest thing inside it.

## What you get

```
design/
├── README.md            after finalize: the entry point
├── product-spec.md      personas, jobs, targets, screen inventory, states, navigation map, backlog
├── research.md          competitors, conventions, antipatterns, sources
├── brand.md             name, positioning, tone, palette, logo rules
├── brand/logo/*.svg     five logo variants
├── design-direction.md  the chosen direction, the token inventory, the component list
├── changes.md           every decision the run made instead of asking, and why
├── audits/<date>.md     every criterion, PASS or FAIL
├── design-spec.md       the handoff: tokens to code, components, screens, rules, routes
├── tokens.json          every variable, W3C Design Tokens format, all themes
├── tokens.css           the same as custom properties, per theme
├── prototype.pen        the canvas
└── screens/             one PNG per screen version and state, each flow as HTML (not versioned)
```

The canvas has a `Design System` region (tokens, components, the state
exemplars), a `Brand` region and one region per flow. Inside a flow, one
column group per screen in navigation order; the group's first row holds
the screen's versions side by side (desktop, mobile, a dark copy), and each
specific state and overlay gets a row below.

## Cost

The expensive model is spent where judgment decides the outcome
(direction, brand, the visual audit) and the cheaper one on execution (the
designer, the structural audit, the layout review). Which agent runs on
what, and where to change it, is one table in
[docs/usage.md](docs/usage.md#which-model-does-what). A full first run on a
real product is still long; start it and come back.

## Documentation

| | |
|---|---|
| [docs/usage.md](docs/usage.md) | running it, permissions, reading an audit, resuming, troubleshooting |
| [docs/pipeline.md](docs/pipeline.md) | the phases in detail, artifacts, commit points |
| [docs/architecture.md](docs/architecture.md) | the pieces, what each decides, why the audit is isolated |
| [docs/development.md](docs/development.md) | installing from source, hooks, scripts, validation, repository layout |
| [docs/contributing.md](docs/contributing.md) | how to change the plugin without making it worse |
| [docs/decisions.md](docs/decisions.md) | every decision taken while building it, with the reason |
| [evals/README.md](evals/README.md) | the reference cases to run after any significant change |

## License

[MIT](LICENSE)
